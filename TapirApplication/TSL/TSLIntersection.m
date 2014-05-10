//
//  TSLIntersection.m
//  TapirApplication
//
//  Created by Vojtech Micka on 08.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLIntersection.h"
#import "TSLRoad.h"
#import "TSLPath.h"
#import "TSLCar.h"

struct Indexes {
    NSUInteger a;
    NSUInteger b;
};
typedef struct Indexes Indexes;

@interface TSLIntersection ()
- (Indexes) getRoadIndexesForRoadA:(TSLRoadObject *) roadA andRoadB:(TSLRoadObject *) roadB;
- (NSIndexSet *) getRoadIndexSetForRoadIdxFrom:(NSUInteger) roadIdxFrom andLineNumber:(NSInteger) lineNumber;
- (void) addAllPathToPath:(TSLPath *) path;
- (void) setNewPath:(TSLPath *) path;
@end

@implementation TSLIntersection {
    NSInteger roadLine [kMAX_ROADS][kMAX_ROADS];
    TSLPath   *paths   [kMAX_ROADS][kMAX_ROADS];
    
    NSMutableArray *tempPaths;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithPosition:(NSPoint)position
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super initWithPosition:position];
    if (self) {
        self.roads = [NSMutableArray arrayWithCapacity:kMAX_ROADS];
        tempPaths = [NSMutableArray array];
        
        for (NSUInteger i = 0; i < kMAX_ROADS; i++) {
            for (NSUInteger j = 0; j < kMAX_ROADS; j++) {
                roadLine[i][j] = -1;
                paths   [i][j] = nil;
            }
        }
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) intersectionAtPoint:(NSPoint) position andRadius:(CGFloat) radius
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLIntersection *intersection = [[TSLIntersection alloc] initWithPosition:position];
    intersection.radius = radius;
    return intersection;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger) count
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [_roads count];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addRoad:(TSLRoadObject *) road
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(self.count < kMAX_ROADS, @"Number of roads is limited to %d.", kMAX_ROADS);
    [self.roads addObject:road];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (Indexes) getRoadIndexesForRoadA:(TSLRoadObject *) roadA andRoadB:(TSLRoadObject *) roadB
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger idxA = [self.roads indexOfObjectIdenticalTo:roadA];
    NSUInteger idxB = [self.roads indexOfObjectIdenticalTo:roadB];
    
    NSAssert(idxA < self.count && idxB < self.count, @"Index is larger then count: idxA: %lu, idxB: %lu", idxA, idxB);
    
    return (Indexes) {idxA, idxB};
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) getLineNumberPathFromRoad:(TSLRoadObject *) roadA toRoad:(TSLRoadObject *) roadB
////////////////////////////////////////////////////////////////////////////////////////////////
{
    Indexes idxs = [self getRoadIndexesForRoadA:roadA andRoadB:roadB];
    
    return roadLine [idxs.a][idxs.b];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addAllPathToPath:(TSLPath *) path
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSUInteger i = 0; i < self.roads.count; i++) {
        for (NSUInteger j = 0; j < self.roads.count; j++) {
            TSLPath *p = paths [i][j];
            
            if (p != nil && p != path) {
                [set addObject:p];
            }
        }
    }
    
    [path addCrossConnectedPath:set];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setNewPath:(TSLPath *) path
////////////////////////////////////////////////////////////////////////////////////////////////
{
    paths [path.indexFrom][path.indexTo] = path;
    [tempPaths addObject:path];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) createPathFromRoad:(TSLRoad *) roadA fromToLine:(NSUInteger) line toRoad:(TSLRoad *) roadB
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self createPathFromRoad:roadA fromLine:line toRoad:roadB toLine:line];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) createPathFromRoad:(TSLRoad *) roadA fromLine:(NSUInteger) lineA toRoad:(TSLRoad *) roadB toLine:(NSUInteger) lineB
////////////////////////////////////////////////////////////////////////////////////////////////
{
    Indexes idxs = [self getRoadIndexesForRoadA:roadA andRoadB:roadB];
    
    roadLine [idxs.a][idxs.b] = lineA;
    
    eTSLRoadDirection dirA = [roadA getDirectionToRoadObject:self];
    eTSLRoadDirection dirB = [roadB getDirectionFromRoadObject:self];
    
    TSLPath *pathA = [roadA pathForLine:lineA andDirection:dirA];
    TSLPath *pathB = [roadB pathForLine:lineB andDirection:dirB];
    
    TSLPath *path = [TSLPath pathFromPoint:pathA.pointB toPoint:pathB.pointA];
    
    [pathA addLinarConnectedPath:[NSSet setWithObject:path]];
    [path addLinarConnectedPath:[NSSet setWithObject:pathB]];
    
    [path setRoadObject:self roadLine:lineB andRoadDirection:dirB];
    
    path.indexFrom = idxs.a;
    path.indexTo   = idxs.b;
    
    [self setNewPath:path];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) createPath:(TSLPath *) path fromRoadObject:(TSLRoadObject *) roadObjectA toRoadObject:(TSLRoadObject *) roadObjectB
////////////////////////////////////////////////////////////////////////////////////////////////
{
    Indexes idxs = [self getRoadIndexesForRoadA:roadObjectA andRoadB:roadObjectB];
    
    roadLine [idxs.a][idxs.b] = path.roadLine;
    
    path.indexFrom = idxs.a;
    path.indexTo   = idxs.b;
    
    [self setNewPath:path];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLPath *) pathFromRoad:(TSLRoad *) roadFrom toRoad:(TSLRoad *) roadTo
////////////////////////////////////////////////////////////////////////////////////////////////
{
    Indexes idxs = [self getRoadIndexesForRoadA:roadFrom andRoadB:roadTo];
    return [self pathFromRoadIdx:idxs.a toRoadIdx:idxs.b];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLPath *) pathFromRoadIdx:(NSUInteger) roadIdxFrom toRoadIdx:(NSUInteger) roadIdxTo
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return paths [roadIdxFrom][roadIdxTo];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexSet *) getRoadIndexSetForRoadIdxFrom:(NSUInteger) roadIdxFrom andLineNumber:(NSInteger) lineNumber
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < self.roads.count; i++) {
        if (roadLine [roadIdxFrom][i] == lineNumber) {
            [indexSet addIndex:i];
        }
    }

    return indexSet;
}

#pragma mark - TSLRoadObject

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) takeCar:(TSLCar *) car fromRoadObject:(TSLRoadObject *) roadObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(roadObject != nil, @"Road object cannot be nil.");
    
    [car arrivedToRoadObject:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) shouldExitCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didExitCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLRoadObject *roadNext = self.roads [car.path.indexTo];
    
    [roadNext takeCar:car fromRoadObject:self];
    
    return;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSSet *) pathsForPath:(TSLPath *) path fromRoadObject:(TSLRoadObject *) roadObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger idxA = [self.roads indexOfObjectIdenticalTo:roadObject];
    NSIndexSet *idxsB = [self getRoadIndexSetForRoadIdxFrom:idxA andLineNumber:path.roadLine];
    
    NSMutableSet *set = [NSMutableSet set];
    
    [idxsB enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [set addObject:[self pathFromRoadIdx:idxA toRoadIdx:idx]];
    }];
    
    return set;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSSet *) pathsNextForPath:(TSLPath *) path
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLRoadObject *ro = self.roads[path.indexTo];
    
    return [ro pathsForPath:path fromRoadObject:self];
}

#pragma mark - TSLObject

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didCreatedAtUniverse:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super didCreatedAtUniverse:universe];
    
    if (tempPaths != nil && tempPaths.count > 0) {
        [tempPaths enumerateObjectsUsingBlock:^(id path, NSUInteger idx, BOOL *stop) {
            [self addAllPathToPath:path];
        }];
        
        tempPaths = nil;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didDeleted
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super didDeleted];
}

@end