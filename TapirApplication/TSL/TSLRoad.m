//
//  TSLRoad.m
//  TapirApplication
//
//  Created by Vojtech Micka on 07.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLRoad.h"
#import "TSLWaypoint.h"

#import "TSLCar.h"
#import "TSLBody.h"
#import "TSLZone.h"
#import "TSLIntersection.h"
#import "TSLPath.h"
#import "TSLSemaphore.h"

#import <TGL/TGL.h>

#import "Vectors.h"

#define NIL ([NSNull null])

@interface TSLRoad ()

@property (nonatomic) CGFloat anglePrev;
@property (nonatomic) CGFloat angleNext;

@property (nonatomic) NSVector vectorPerp;
@property (nonatomic) CGFloat  offset;

- (TSLPath *) createPathForRoadLine:(NSUInteger) lineNumber atDirection:(eTSLRoadDirection) dir;
- (NSPoint) cornerPointFromDirection:(eTSLRoadDirection) dir withWidthOfRoad:(CGFloat) roadWidth;

@end

@implementation TSLRoad {
    TSLWaypoint *waypoints [kMAX_LINECOUNT * 2];
}

#pragma mark - Inititalization & Creation

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithStart:(NSPoint) startPoint andEnd:(NSPoint) endPoint
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super initWithPosition:startPoint];
    if (self) {
        self.pathsPositive = [NSMutableArray array];
        self.pathsNegative = [NSMutableArray array];
        
        self.startPoint = startPoint;
        self.endPoint   = endPoint;
        
        self.lineCountPositiveDir = 1;
        self.lineCountNegativeDir = 1;
        
        // Linked roads
        self.next   = nil;
        self.prev   = nil;
        self.active = NO;
        
        for (int i = 0; i < kMAX_LINECOUNT * 2; i++) {
            waypoints[i] = nil;
        }
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) road
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLRoad alloc] initWithStart:NSZeroPoint andEnd:NSZeroPoint];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) roadWithStart:(NSPoint) startPoint andEnd:(NSPoint) endPoint
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLRoad alloc] initWithStart:startPoint andEnd:endPoint];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) roadWithStartPoint:(NSPoint) startPoint andConnectToRoadObject:(TSLRoadObject *) next
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSPoint endPoint = next.position;
    
    if ([next isKindOfClass:[TSLIntersection class]]) {
        TSLIntersection *intersection = (TSLIntersection *) next;
        
        NSVector dir = NSVectorResize(NSVectorNormalize(NSVectorMake(intersection.position, startPoint)), intersection.radius);
        endPoint     = NSVectorAdd(intersection.position, dir);
    }
    
    TSLRoad *road = [TSLRoad roadWithStart:startPoint andEnd:endPoint];
    road.next = next;
    
    return road;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) roadConnectToRoadObject:(TSLRoadObject *) prev andEndPoint:(NSPoint) endPoint
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSPoint startPoint = prev.position;
    
    if ([prev isKindOfClass:[TSLRoad class]]) {
        TSLRoad *roadPrev = (TSLRoad *) prev;
        startPoint = roadPrev.endPoint;
    } else if ([prev isKindOfClass:[TSLIntersection class]]) {
        TSLIntersection *intersection = (TSLIntersection *) prev;
        
        NSVector dir = NSVectorResize(NSVectorNormalize(NSVectorMake(intersection.position, endPoint)), intersection.radius);
        startPoint     = NSVectorAdd(intersection.position, dir);
        
    }
    
    TSLRoad *road = [TSLRoad roadWithStart:startPoint andEnd:endPoint];
    road.prev = prev;
    
    return road;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) roadBetweenRoadObjectA:(TSLRoadObject *) roadA andRoadObjectB:(TSLRoadObject *) roadB
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSPoint startPoint = roadA.position;
    NSPoint endPoint   = roadB.position;
    
    if ([roadA isKindOfClass:[TSLRoad class]]) {
        TSLRoad *roadPrev = (TSLRoad *) roadA;
        startPoint = roadPrev.endPoint;
    } else if ([roadA isKindOfClass:[TSLIntersection class]]) {
        TSLIntersection *intersection = (TSLIntersection *) roadA;
        
        NSVector dir = NSVectorResize(NSVectorNormalize(NSVectorMake(intersection.position, roadB.position)), intersection.radius);
        startPoint   = NSVectorAdd(intersection.position, dir);
    }
    
    if ([roadB isKindOfClass:[TSLIntersection class]]) {
        TSLIntersection *intersection = (TSLIntersection *) roadB;
        
        NSVector dir = NSVectorResize(NSVectorNormalize(NSVectorMake(intersection.position, startPoint)), intersection.radius);
        endPoint     = NSVectorAdd(intersection.position, dir);
    }
    
    TSLRoad *road = [TSLRoad roadWithStart:startPoint andEnd:endPoint];
    road.prev = roadA;
    road.next = roadB;
    return road;
}

#pragma mark - Getters

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray *) pathsInDirection:(eTSLRoadDirection) dir
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return dir ? self.pathsPositive : self.pathsNegative;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger) lineCountInDirection:(eTSLRoadDirection) dir
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return dir ? self.lineCountPositiveDir : self.lineCountNegativeDir;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLRoadObject *) prevInDirection:(eTSLRoadDirection) dir
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return dir ? self.prev : self.next;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLRoadObject *) nextInDirection:(eTSLRoadDirection) dir
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return dir ? self.next : self.prev;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSVector) directionInDirection:(eTSLRoadDirection) dir
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return dir ? self.direction : NSVectorOpossite(self.direction);
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) shouldExitCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if ([car shouldExit] == NO) return NO;
    
    TSLRoadObject *ro = [self nextInDirection:car.roadDirection];
    
    if ([ro isKindOfClass:[TSLRoad class]]) {
        TSLRoad *road = (TSLRoad *) ro;
        
        if ([road isFreeLine:car.roadLine inDir:[road getDirectionFromRoadObject:self] forCar:car] == NO) {
            return NO;
        }
    }
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didExitCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [car didExit];
    
    TSLRoadObject *ro = [self nextInDirection:car.roadDirection];
    
    [ro takeCar:car fromRoadObject:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLPath *) pathForExitingCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLRoadObject *ro = [self nextInDirection:car.roadDirection];
    
    return [car pathForRoadObject:ro];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) takeCar:(TSLCar *) car fromRoadObject:(TSLRoadObject *) roadObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(roadObject != nil, @"Road object cannot be nil.");
    
    [car arriveToNewRoadObject:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isFreeLine:(NSUInteger) line inDir:(eTSLRoadDirection) dir forCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSMutableArray *paths = [self pathsInDirection:dir];
    TSLPath *path = paths[line];
    
    return [path canPutCar:car];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) getFreeLineInDirection:(eTSLRoadDirection) dir forCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger lineCount = [self lineCountInDirection:dir];
    
    NSUInteger randIndex = rand() % lineCount;
    
    for (NSUInteger i = randIndex; i < (lineCount + randIndex); i++) {
        if ([self isFreeLine:(i % lineCount) inDir:dir forCar:car]) {
            return i % lineCount;
        }
    }
    
    return -1;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLPath *) getFreePathInDirection:(eTSLRoadDirection) dir forCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger lineCount = [self lineCountInDirection:dir];
    NSUInteger randIndex = rand() % lineCount;
    
    NSMutableArray *paths = [self pathsInDirection:dir];
    
    for (NSUInteger i = randIndex; i < (lineCount + randIndex); i++) {
        TSLPath *path = paths[i % lineCount];
        if ([path canPutCar:car]) {
            return path;
        }
    }
    
    return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (eTSLRoadDirection) getDirectionToRoadObject:(TSLRoadObject *) roadObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(roadObject == _prev || roadObject == _next, @"Road object has to be one of connecting objects!");
    return roadObject == _next ? TSLRoadDirectionPositive : TSLRoadDirectionNegative;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (eTSLRoadDirection) getDirectionFromRoadObject:(TSLRoadObject *) roadObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(roadObject == _prev || roadObject == _next, @"Road object has to be one of connecting objects!");
    return roadObject == _prev ? TSLRoadDirectionPositive : TSLRoadDirectionNegative;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLPath *) pathForLine:(NSUInteger) lineNumber andDirection:(eTSLRoadDirection) dir
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(lineNumber < [self lineCountInDirection:dir], @"Wrong number of line in the given direction.");
    
    NSMutableArray *paths = [self pathsInDirection:dir];
    
    if (paths.count <= lineNumber || paths[lineNumber] == NIL) {
        return [self createPathForRoadLine:lineNumber atDirection:dir];
    } else {
        return paths[lineNumber];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSSet *) pathsForPath:(TSLPath *) path fromRoadObject:(TSLRoadObject *) roadObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [NSSet setWithObject:[self pathForLine:path.roadLine andDirection:path.roadDirection]];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSSet *) pathsNextForPath:(TSLPath *) path
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLRoadObject *ro = [self nextInDirection:path.roadDirection];
    
    return [ro pathsForPath:path fromRoadObject:self];
}

#pragma mark - Setters

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPathsPositive:(NSMutableArray *) pathsPositive
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _pathsPositive = pathsPositive;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPathsNegative:(NSMutableArray *) pathsNegative
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _pathsNegative = pathsNegative;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setDirection:(NSVector) direction
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _direction = direction;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setLength:(CGFloat) length
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _length = length;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setLineCountNegativeDir:(NSUInteger) lineCountNegativeDir
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(lineCountNegativeDir <= kMAX_LINECOUNT, @"Line count has to be smaller the MAX_LINECOUNT!");
    _lineCountNegativeDir = lineCountNegativeDir;

    if (self.pathsNegative.count < lineCountNegativeDir) {
        NSUInteger offset = self.pathsNegative.count;
        
        for (int i = 0; i < (lineCountNegativeDir - offset); i++) {
            TSLPath *path = [self pathForLine:(i + offset) andDirection:TSLRoadDirectionNegative];
            [self.pathsNegative addObject:path];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setLineCountPositiveDir:(NSUInteger) lineCountPositiveDir
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(lineCountPositiveDir <= kMAX_LINECOUNT, @"Line count has to be smaller the MAX_LINECOUNT!");
    _lineCountPositiveDir = lineCountPositiveDir;
    
    if (self.pathsPositive.count < lineCountPositiveDir) {
        NSUInteger offset = self.pathsPositive.count;
        
        for (int i = 0; i < (lineCountPositiveDir - offset); i++) {
            TSLPath *path = [self pathForLine:(i + offset) andDirection:TSLRoadDirectionPositive];
            [self.pathsPositive addObject:path];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setStartPoint:(NSPoint) startPoint
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _startPoint = startPoint;
    
    NSVector tmp    = NSVectorMake(_startPoint, _endPoint);
    self.length     = NSVectorSize(tmp);
    self.direction  = NSVectorNormalize(tmp);
    self.vectorPerp = NSVectorPerp(self.direction);
    self.offset     = NSVectorDot(_vectorPerp, self.startPoint);
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setEndPoint:(NSPoint) endPoint
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _endPoint = endPoint;
    
    NSVector tmp    = NSVectorMake(_startPoint, _endPoint);
    self.length     = NSVectorSize(tmp);
    self.direction  = NSVectorNormalize(tmp);
    self.vectorPerp = NSVectorPerp(self.direction);
    self.offset     = NSVectorDot(_vectorPerp, self.startPoint);
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setNext:(TSLRoadObject *) next
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (_next == next) return;
 
    _next = next;

    if (next == nil) return;
    
    if ([next isKindOfClass:[TSLRoad class]]) {
        TSLRoad *nextRoad = (TSLRoad *) next;
        self.endPoint             = nextRoad.startPoint;
        self.lineCountNegativeDir = nextRoad.lineCountNegativeDir;
        
        nextRoad.prev = self;
    } else if ([next isKindOfClass:[TSLZone class]]) {
        TSLZone *zone = (TSLZone *) next;
        zone.road = self;
    } else if ([next isKindOfClass:[TSLIntersection class]]) {
        TSLIntersection *intersection = (TSLIntersection *) next;
        [intersection addRoad:self];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPrev:(TSLRoadObject *) prev
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (_prev == prev) return;
    
    _prev = prev;
    
    if (prev == nil) return;
    
    if ([prev isKindOfClass:[TSLRoad class]]) {
        TSLRoad *prevRoad = (TSLRoad *) prev;
        
        self.startPoint           = prevRoad.endPoint;
        self.lineCountPositiveDir = prevRoad.lineCountPositiveDir;
        
        prevRoad.next = self;
    } else if ([prev isKindOfClass:[TSLZone class]]) {
        TSLZone *zone = (TSLZone *) prev;
        zone.road = self;
    } else if ([prev isKindOfClass:[TSLIntersection class]]) {
        TSLIntersection *intersection = (TSLIntersection *) prev;
        [intersection addRoad:self];
    }
}

#pragma mark - Corner points

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLPath *) createPathForRoadLine:(NSUInteger) lineNumber atDirection:(eTSLRoadDirection) dir
////////////////////////////////////////////////////////////////////////////////////////////////
{
    CGFloat width = kTSLRoadWidth * lineNumber + kTSLRoadWidth / 2.0f;
    
    if (dir == TSLRoadDirectionNegative) {
        width *= -1;
    }
    
    NSPoint pointA = [self cornerPointFromDirection:dir withWidthOfRoad:width];
    NSPoint pointB = [self cornerPointFromDirection:!dir withWidthOfRoad:width];
                      
    TSLPath *path = [TSLPath pathFromPoint:pointA toPoint:pointB];
    
    [path setRoadObject:self roadLine:lineNumber andRoadDirection:dir];
    [path addLinarConnectedPath:[self pathsNextForPath:path]];
    
    return path;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSPoint) cornerPointFromDirection:(eTSLRoadDirection) dir withWidthOfRoad:(CGFloat) roadWidth
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSPoint point;

    
    TSLRoadObject *tmp = dir ? _next : _prev;
    TSLRoad *road = nil;
    
    if ([tmp isKindOfClass:[TSLRoad class]]) {
        road = (TSLRoad *) road;
    }
    
    NSVector A1 = NSVectorResize (_vectorPerp, roadWidth);
    CGFloat  C1 = _offset + NSVectorDot (A1, _vectorPerp);
    
    if (road != nil) {
        
        NSVector A2 = NSVectorResize (road.vectorPerp, roadWidth);
        CGFloat  C2 = road.offset + NSVectorDot(A2, road.vectorPerp);
        A2 = road.vectorPerp;
        
        CGFloat detP = NSVectorCross(_vectorPerp, A2);
        if (detP == 0) {
            // Lines are parallel
        } else {
            point = NSMakePoint((A2.y * C1 - _vectorPerp.y * C2) / detP, (_vectorPerp.x * C2 - A2.x * C1) / detP);
        }
        
    } else {
        point = NSVectorAdd (A1, dir ? _startPoint : _endPoint);
    }
    
    return point;
}

#pragma mark - TSLSemaphore

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLSemaphore *) createSemaphoreAtLine:(NSUInteger) lineNumber inDirection:(eTSLRoadDirection) dir
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLPath *pathForSemaphore  = [self pathForLine:lineNumber andDirection:dir];
    TSLSemaphore *semaphore    = [TSLSemaphore semaphoreAtPathPosition:pathForSemaphore.length];

    pathForSemaphore.semaphore = semaphore;
    return semaphore;
}

#pragma mark - TSLObject

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super updateWithTimeSinceLastUpdate:deltaTime];
    return;
    // Not an active object
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didCreatedAtUniverse:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super didCreatedAtUniverse:universe];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didDeleted
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super didDeleted];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) visualize
////////////////////////////////////////////////////////////////////////////////////////////////
{
    // Draw road
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithColor:[SKColor lightGrayColor]
                                                      size:CGSizeMake(self.length, 1.0f)];
    
    node.position = NSVectorAdd(NSVectorResize(NSVectorMake(self.startPoint, self.endPoint), 0.5f), self.startPoint);
    node.zRotation = NSVectorAngle(self.direction);
    
    [TGLSceneManager registerLayerWithNode:node];
    
    CGFloat width = kTSLRoadWidth * _lineCountPositiveDir;
    
    NSPoint pointA = [self cornerPointFromDirection:TSLRoadDirectionPositive withWidthOfRoad:width];
    NSPoint pointB = [self cornerPointFromDirection:TSLRoadDirectionNegative withWidthOfRoad:width];
    
    node = [SKSpriteNode spriteNodeWithColor:[SKColor darkGrayColor]
                                        size:CGSizeMake(NSVectorSize(NSVectorMake(pointA, pointB)), 1.0f)];
    
    node.position = NSVectorAdd(NSVectorResize(NSVectorMake(pointA, pointB), 0.5f), pointA);
    node.zRotation = NSVectorAngle(self.direction);
    
    [TGLSceneManager registerLayerWithNode:node];
    
    pointA = [self cornerPointFromDirection:TSLRoadDirectionPositive withWidthOfRoad:-width];
    pointB = [self cornerPointFromDirection:TSLRoadDirectionNegative withWidthOfRoad:-width];
    
    node = [SKSpriteNode spriteNodeWithColor:[SKColor darkGrayColor]
                                        size:CGSizeMake(NSVectorSize(NSVectorMake(pointA, pointB)), 1.0f)];
    
    node.position = NSVectorAdd(NSVectorResize(NSVectorMake(pointA, pointB), 0.5f), pointA);
    node.zRotation = NSVectorAngle(self.direction);
    
    [TGLSceneManager registerLayerWithNode:node];
}

@end
