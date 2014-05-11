//
//  TSLPlan.m
//  TapirApplication
//
//  Created by Vojtech Micka on 10.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLPlan.h"

#import "TSLZone.h"
#import "TSLRoad.h"
#import "TSLRoadObject.h"
#import "TSLIntersection.h"

#import "Vectors.h"

#define NIL [NSNull null]

@interface Node : NSObject
@property (nonatomic) CGFloat cost;
@property (nonatomic) CGFloat heuristic;
@property (nonatomic, strong) Node *last;
@property (nonatomic, weak) TSLRoadObject *current;
+ (instancetype) nodeForNode:(Node *) last withRoad:(TSLRoadObject *) current andCost:(CGFloat) cost andTarget:(TSLZone *) target;
@end

@implementation Node
////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) nodeForNode:(Node *) last withRoad:(TSLRoadObject *) current andCost:(CGFloat) cost andTarget:(TSLZone *) target
////////////////////////////////////////////////////////////////////////////////////////////////
{
    Node *node = [[Node alloc] init];
    node.cost = last.cost + cost;
    node.heuristic = NSVectorSize(NSVectorMake(current.position, target.position));
    node.last = last;
    node.current = current;
    return node;
}

- (BOOL) isEqual:(id) object
{
    if ([object isKindOfClass:[Node class]] == NO) return NO;
    Node *node = (Node *) object;
    return self.current == node.current;
}
@end

@interface TSLPlan ()

@property (nonatomic, strong) NSMutableArray *plan;
@property (nonatomic) NSInteger currentIndex;

- (void) processRoadObject:(TSLRoadObject *) roadObject withCurrentNode:(Node *) curNode andClosedList:(NSMutableArray *) closedList andOpenList:(NSMutableArray *) openList andTarget:(TSLZone *) target;
- (TSLRoadObject *) getRoadObjectAfterRoad:(TSLRoad *) road fromRoadObject:(TSLRoadObject *) roadObject withCost:(CGFloat *) cost;
- (void) buildPathReverseFromNode:(Node *) node;
- (void) addRoadFromRoadObject:(TSLRoadObject *) roadObjectA toRoadObject:(TSLRoadObject *) roadObjectB;

@end

@implementation TSLPlan

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        self.plan = [NSMutableArray array];
        self.currentIndex = -1;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) plan
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLPlan alloc] init];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) planFromZone:(TSLZone *) start toZone:(TSLZone *) target
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLPlan *plan = [TSLPlan plan];
    [plan searchPathFromZone:start toZone:target];
    return plan;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLRoad *) moveNext
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.currentIndex++;
    
    self.current  = self.plan [self.currentIndex];
    
    if (self.currentIndex + 1 < self.plan.count) {
        self.nextRoad = self.plan [self.currentIndex + 1];
    } else {
        self.nextRoad = nil;
    }
    
    return self.current;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addRoad:(TSLRoad *) road
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.plan addObject:road];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) searchPathFromZone:(TSLZone *) start toZone:(TSLZone *) target
////////////////////////////////////////////////////////////////////////////////////////////////
{
    
    NSMutableArray *openList   = [NSMutableArray array];
    NSMutableArray *closedList = [NSMutableArray array];
    
    Node *curNode = [Node nodeForNode:nil withRoad:start andCost:0 andTarget:target];
    
    [openList addObject:curNode];
    
    while (openList.count > 0) {
        
        curNode = [openList firstObject];
        [openList removeObject:curNode];
        [closedList addObject:curNode.current];
        
        
        TSLRoadObject *curRoadObject = curNode.current;
        
        if (curRoadObject == target) {
            // END
            // Build path
            [self buildPathReverseFromNode:curNode];
            break;
        }
        
        [self processRoadObject:curRoadObject withCurrentNode:curNode andClosedList:closedList andOpenList:openList andTarget:target];
        
        // Sort open list?
        [openList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Node *node1 = obj1;
            Node *node2 = obj2;
            
            CGFloat g1 = node1.cost + node1.heuristic;
            CGFloat g2 = node2.cost + node2.heuristic;
            
            if (g1 < g2) {
                return NSOrderedAscending;
            } else if (g1 > g2) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
    }
    
//    NSLog(@"Plan was found!");
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) buildPathReverseFromNode:(Node *) node
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (node.last == nil) return;
    [self buildPathReverseFromNode:node.last];
    [self addRoadFromRoadObject:node.last.current toRoadObject:node.current];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addRoadFromRoadObject:(TSLRoadObject *) roadObjectA toRoadObject:(TSLRoadObject *) roadObjectB
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if ([roadObjectA isKindOfClass:[TSLZone class]]) {
        TSLZone *zone = (TSLZone *) roadObjectA;
        
        TSLRoad *road = zone.road;
        [self addRoad:road];
        
        TSLRoadObject *ro = [road nextInDirection:[road getDirectionFromRoadObject:roadObjectA]];
        TSLRoadObject *prev = road;
        
        while ([ro isKindOfClass:[TSLRoad class]]) {
            TSLRoad *r = (TSLRoad *) ro;
            [self addRoad:road];
            ro = [r nextInDirection:[r getDirectionFromRoadObject:prev]];
            prev = r;
        }
        
    } else if ([roadObjectA isKindOfClass:[TSLIntersection class]]) {
        TSLIntersection *intersection = (TSLIntersection *) roadObjectA;
        
        [intersection.roads enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            CGFloat cost = 0;
            TSLRoadObject *ro = [self getRoadObjectAfterRoad:obj fromRoadObject:intersection withCost:&cost];
            
            if (ro == roadObjectB) {
                TSLRoad *road = (TSLRoad *) obj;
                [self addRoad:road];
                
                TSLRoadObject *ro = [road nextInDirection:[road getDirectionFromRoadObject:roadObjectA]];
                TSLRoadObject *prev = road;
                
                while ([ro isKindOfClass:[TSLRoad class]]) {
                    TSLRoad *r = (TSLRoad *) ro;
                    [self addRoad:road];
                    ro = [r nextInDirection:[r getDirectionFromRoadObject:prev]];
                    prev = r;
                }
            }
            
        }];
        
        
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////
- (void) processRoadObject:(TSLRoadObject *) roadObject withCurrentNode:(Node *) curNode andClosedList:(NSMutableArray *) closedList andOpenList:(NSMutableArray *) openList andTarget:(TSLZone *) target
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if ([roadObject isKindOfClass:[TSLZone class]]) {
        TSLZone *zone = (TSLZone *) roadObject;
        
        CGFloat cost = 0;
        
        TSLRoadObject *ro = [self getRoadObjectAfterRoad:zone.road fromRoadObject:zone withCost:&cost];
        
        Node *roadNode = [Node nodeForNode:curNode withRoad:ro andCost:cost andTarget:target];
        
        if ([closedList containsObject:roadNode.current] == NO && [openList indexOfObject:roadNode] == NSNotFound) {
            [openList addObject:roadNode];
        }
        
    } else if ([roadObject isKindOfClass:[TSLIntersection class]]) {
        TSLIntersection *intersection = (TSLIntersection *) roadObject;
        
        [intersection.roads enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (obj == curNode.current) return;
            
            CGFloat cost = 0;
            
            TSLRoadObject *ro = [self getRoadObjectAfterRoad:obj fromRoadObject:intersection withCost:&cost];
            
            Node *roadNode = [Node nodeForNode:curNode withRoad:ro andCost:cost andTarget:target];

            if ([closedList containsObject:roadNode.current] == NO && [openList indexOfObject:roadNode] == NSNotFound) {
                [openList addObject:roadNode];
            }
            
        }];
        
        
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLRoadObject *) getRoadObjectAfterRoad:(TSLRoad *) road fromRoadObject:(TSLRoadObject *) roadObject withCost:(CGFloat *) cost
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLRoadObject *ro = [road nextInDirection:[road getDirectionFromRoadObject:roadObject]];
    *cost += road.length;
    
    if ([ro isKindOfClass:[TSLRoad class]]) {
        TSLRoad *r = (TSLRoad *) ro;
        return [self getRoadObjectAfterRoad:r fromRoadObject:road withCost:(CGFloat *) cost];
    }
    
    return ro;
}


@end
