//
//  TSLPath.m
//  TapirApplication
//
//  Created by Vojtech Micka on 09.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLPath.h"
#import "Vectors.h"

#import "TSLCar.h"
#import "TSLBody.h"

#define NIL ([NSNull null])

@interface TSLPath ()

@property (nonatomic, strong) NSMutableDictionary *crossConnectedPaths;
@property (nonatomic, strong) NSMutableSet *linearCconnectedPaths;

@end

@implementation TSLPath {
    id tempObjAfter, tempObjBefore;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        static int count = 0;
        _name = [NSString stringWithFormat:@"Path#%d", count++];
        tempObjAfter = NIL;
        tempObjBefore = NIL;
    }
    return self;
}

#pragma mark - Creation

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) pathFromPoint:(NSPoint) pointA toPoint:(NSPoint) pointB
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLPath *path = [[TSLPath alloc] init];
    
    path.pointA = pointA;
    path.pointB = pointB;
    
    NSVector vecAB = NSVectorMake(pointA, pointB);
    path.length    = ceil(NSVectorSize(vecAB));
    path.carCount  = 0;
    path.direction = NSVectorNormalize(vecAB);
    
    path.cars                  = [NSMutableArray arrayWithCapacity:path.length];
    path.crossConnectedPaths   = [NSMutableDictionary dictionary];
    path.linearCconnectedPaths = [NSMutableSet set];
    
    for (int i = 0; i < path.length; i++) {
        [path.cars addObject:NIL];
    }
    
    return path;
}

#pragma mark - Object handling

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) putCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (car.path == self) return;
    
    car.path           = self;
    car.sensorProvider = self;
    
    NSAssert(self.cars[car.pathPositionMomentum] == NIL, @"The cars storage should be empty on putting the car.");
    
    self.cars[car.pathPositionMomentum] = car;
    self.carCount++;
    
    [car didStart];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) canPutCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self canPutCar:car onPathPosition:car.pathPositionMomentum];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) canPutCar:(TSLCar *) car onPathPosition:(NSUInteger) pathPostion
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (pathPostion >= self.length || self.carCount == 0) return YES;
    if (self.cars[pathPostion] != NIL) return NO;
    
    CGFloat carLength = car.body.size.width / 2.0f;
    
    for (NSUInteger i = 1; i < ceil(carLength) && (i + pathPostion) < self.length; i++) {
        if (self.cars[pathPostion + i] != NIL) return NO;
    }
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (id) objectAtPathPosition:(NSUInteger) pathPosition
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return self.cars[pathPosition];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) removeCarLeftover:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (self.cars[car.pathPosition] == car) {
        self.cars[car.pathPosition] = NIL;
        self.carCount--;
        car.path = nil;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSPoint) getPositionForPathPosition:(NSUInteger) pathPosition
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return NSVectorAdd(self.pointA, NSVectorResize(self.direction, pathPosition));
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) shouldExitCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if ([car shouldExit] == NO) return NO;
    if ([self.road shouldExitCar:car] == NO) return NO;
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didExitCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [car didExit];
    [self.road didExitCar:car];
    
    [self removeCarLeftover:car];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) moveCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger newPosition = MAX(car.pathPosition + car.speed, 0);
    if ([self canPutCar:car onPathPosition:newPosition]) {
        car.pathPosition = newPosition;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) updateCarPosition:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    // Reset temp objects
    tempObjAfter  = NIL; // !! Most important
    tempObjBefore = NIL; // !! Most important
    
    NSUInteger oldPathPosition = car.pathPosition;
    
    [self moveCar:car];
    
    if (oldPathPosition == car.pathPosition) return;
    
    NSAssert(self.cars[oldPathPosition] == car, @"Wrong car or position!");
    self.cars[oldPathPosition] = NIL;
    
    if (car.pathPosition >= self.length) {
        if ([self shouldExitCar:car] == NO) {
            car.pathPosition = self.length-1;
        } else {
            car.pathPositionMomentum = car.pathPosition - self.length;
            car.pathPosition = oldPathPosition;
            [self didExitCar:car];
            return;
        }
    }
    
    NSAssert(self.cars[car.pathPosition] == NIL, @"New position is occupied!");
    self.cars[car.pathPosition] = car;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addCrossConnectedPath:(NSSet *) set
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
        TSLPath *path = (TSLPath *) obj;
        
        // Calculate cross point
        NSUInteger indexOfCross = 0;
        
        
        NSVector w = NSVectorMake(self.pointA, path.pointA);
        NSVector u = self.direction;
        NSVector v = path.direction;
        
        CGFloat cwu = NSVectorCross(w, u);
        CGFloat cuv = NSVectorCross(u, v);
        
        CGFloat k = cwu / cuv;
        
        // Not a cross point
        if (k > path.length || k < 0) return;
        NSAssert(k != 0, @"Given path is not cross connected but it's linear connected!");
        
        NSVector z = NSVectorAdd(NSVectorResize(v, k), w);

        // Add path to connected paths
        path.crossConnectedPaths[[self value]] = @((NSUInteger) k);
        self.crossConnectedPaths[[path value]] = @((NSUInteger) NSVectorSize(z));
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addLinarConnectedPath:(NSSet *) set
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.linearCconnectedPaths addObjectsFromArray:[set allObjects]];
}

#pragma mark - TSLSensorsProtocol

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) getDistanceToCarAfter:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger objIndex = 0;
    
    id closestObj = [self getClosestObjectInDirection:TSLPathDirectionAfter toCar:car objectIndex:&objIndex];
    
    if (closestObj == NIL) return CGFLOAT_MAX;
    
    if ([closestObj isKindOfClass:[TSLCar class]]) {
        return [car getDistanceToCar:(TSLCar *) closestObj];
    }
    
    return objIndex - car.pathPosition;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) getSpeedToCarAfter:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    id closestObj = [self getClosestObjectInDirection:TSLPathDirectionAfter toCar:car objectIndex:NULL];
    
    if (closestObj == NIL) return CGFLOAT_MAX;
    
    if ([closestObj isKindOfClass:[TSLCar class]]) {
        return ((TSLCar *)closestObj).speed;
    }
    
    return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (id) getClosestObjectAfterCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self getClosestObjectInDirection:TSLPathDirectionAfter toCar:car objectIndex:NULL];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) getDistanceToCarBefore:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger objIndex = 0;
    
    id closestObj = [self getClosestObjectInDirection:TSLpathDirectionBefore toCar:car objectIndex:&objIndex];
    
    if (closestObj == NIL) return CGFLOAT_MAX;
        
    if ([closestObj isKindOfClass:[TSLCar class]]) {
        return [car getDistanceToCar:(TSLCar *) closestObj];
    }
    
    return objIndex - car.pathPosition;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) getSpeedToCarBefore:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    id closestObj = [self getClosestObjectInDirection:TSLpathDirectionBefore toCar:car objectIndex:NULL];
    
    if (closestObj == NIL) return CGFLOAT_MAX;
        
    if ([closestObj isKindOfClass:[TSLCar class]]) {
        return ((TSLCar *) closestObj).speed;
    }
    
    return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (id) getClosestObjectBeforeCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self getClosestObjectInDirection:TSLpathDirectionBefore toCar:car objectIndex:NULL];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (id) getClosestObjectInDirection:(eTSLPathDirection) dir toCar:(TSLCar *) car objectIndex:(NSUInteger *) objectIndex
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (car.pathPosition + 1 + car.maxRange < self.length && self.carCount <= 1) return NIL;
    
    switch (dir) {
        case TSLPathDirectionAfter:
            if (tempObjAfter != NIL) return tempObjAfter;
            if (car.pathPosition == self.length - 1) return NIL;
            break;
        case TSLpathDirectionBefore:
            if (tempObjBefore != NIL) return tempObjBefore;
            if (car.pathPosition == 0) return NIL;
            break;
    }
    
    id obj = self.cars[car.pathPosition];
    NSAssert(obj == car, @"Weird! The object on pathPosition is not car.");

    id foundObj = [self getClosestObjectInDirection:dir forIndex:car.pathPosition + 1 withLimit:car.maxRange objectIndex:objectIndex];
    
    switch (dir) {
        case TSLPathDirectionAfter:
            tempObjAfter = foundObj;
            break;
        case TSLpathDirectionBefore:
            tempObjBefore = foundObj;
            break;
    }
    
    return foundObj;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (id) getClosestObjectInDirection:(eTSLPathDirection) dir forIndex:(NSUInteger) index withLimit:(NSInteger) limit objectIndex:(NSUInteger *) objectIndex
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (limit <= 0) return NIL;
    
    NSUInteger n = 0;
    __block id nextObj = NIL;
    
    if (self.carCount > 0 && index < self.length) {
        NSUInteger loc = index;
        NSUInteger len = limit;
        NSEnumerationOptions options = 0;
        
        switch (dir) {
            case TSLPathDirectionAfter:
                if (self.length < index + limit) {
                    len = self.length - index;
                }
                break;
            case TSLpathDirectionBefore:
                options = NSEnumerationReverse;
                if (limit > index) {
                    loc = 0;
                    len = index;
                } else {
                    loc = index - limit;
                }
                break;
        }
        
        __block NSUInteger nextIdx = 0;

        [[self.cars subarrayWithRange:NSMakeRange(loc, len)] enumerateObjectsWithOptions:options usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            nextIdx = idx;
            if (obj != NIL) {
                nextObj = obj;
                *stop = YES;
            }
        }];
        
        n = dir ? nextIdx : len - nextIdx;
        
//        [self.cars enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc, len)] options:options usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            if (obj != NIL) {
//                nextObj = obj;
//                nextIdx = idx;        
//                *stop = YES;
//            }
//        }];
//        
//        n = labs(nextIdx - index);
        
//        while (nextObj == NIL && n + index < self.length && n < limit) {
//            nextObj = self.cars[n + index];
//            n += dir ? 1 : -1;
//            if (index + n == 0) break;
//        }
        
    }
    
    if (self.crossConnectedPaths.count > 0) {
    
        NSMutableSet *pathToScan = [NSMutableSet set];
        
        [[self.crossConnectedPaths allKeys] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            TSLPath *path = ((NSValue *) obj).nonretainedObjectValue;
            NSUInteger pathIndex = ((NSNumber *) self.crossConnectedPaths[[path value]]).unsignedIntegerValue; // index
            
            switch (dir) {
                case TSLPathDirectionAfter:
                    if (((nextObj != NIL && pathIndex < n + index) || nextObj == NIL) && pathIndex > index && pathIndex < index + limit) {
                        @synchronized(pathToScan) {
                            [pathToScan addObject:path];
                        }
                    }
                    break;
                case TSLpathDirectionBefore:
                    if (((nextObj != NIL && pathIndex > index - n) || nextObj == NIL) && pathIndex < index && pathIndex > index - limit) {
                        @synchronized(pathToScan) {
                            [pathToScan addObject:path];
                        }
                    }
                    break;
            }
        }];
        
        if (pathToScan.count > 0) {
            
            __block NSUInteger minIndex = NSUIntegerMax;
            __block NSUInteger minDist = NSUIntegerMax;
            __block id minObj = NIL;
            
            [pathToScan enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                
                TSLPath *path = obj;
                NSUInteger pathIndex = [path indexForConnectedPath:self]; // index
                
                id nextObj, prevObj;
                NSUInteger nextIndex = 0, prevIndex = 0;
                
                nextObj = [path getClosestObjectInDirection:TSLPathDirectionAfter forPath:self withLimit:kTSLCarMaxLength/2.0f objectIndex:&nextIndex];
                prevObj = [path getClosestObjectInDirection:TSLpathDirectionBefore forPath:self withLimit:kTSLCarMaxLength/2.0f objectIndex:&prevIndex];
                
                NSUInteger nextDist = labs(nextIndex - pathIndex);
                NSUInteger prevDist = labs(prevIndex - pathIndex);
                
                if (nextObj != NIL && nextDist < prevDist && nextDist < minDist) {
                    minIndex = nextIndex;
                    minDist = nextDist;
                    minObj = nextObj;
                } else if (prevObj != NIL && prevDist < minDist) {
                    minIndex = prevIndex;
                    minDist = prevDist;
                    minObj = prevObj;
                }
                
            }];
            
            if (minObj != NIL) {
                nextObj = minObj;
            }
        }
    }
    
    if (nextObj == NIL && self.length - index < limit) {
        
        __block NSUInteger minIndex = NSUIntegerMax;
        __block id minObj = NIL;
        
        [self.linearCconnectedPaths enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, BOOL *stop) {
            
            TSLPath *path = obj;
            
            id nextObj = NIL;
            NSUInteger nextIndex = 0;
            
            nextObj = [path getClosestObjectInDirection:TSLPathDirectionAfter forIndex:0 withLimit:MAX(limit - n, 0) objectIndex:&nextIndex];
            
            if (nextIndex < minIndex) {
                minObj = nextObj;
            }
            
        }];
        
        if (minObj != NIL) {
            nextObj = minObj;
        }
    }
    
    if (objectIndex != NULL && nextObj != NIL) {
        switch (dir) {
            case TSLPathDirectionAfter:
                *objectIndex += n + index;
                break;
            case TSLpathDirectionBefore:
                *objectIndex += index - n;
                break;
        }
    }
    
    return nextObj;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (id) getClosestObjectInDirection:(eTSLPathDirection) dir forPath:(TSLPath *) path withLimit:(NSInteger) limit objectIndex:(NSUInteger *) objectIndex
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self getClosestObjectInDirection:dir forIndex:[self indexForConnectedPath:path] withLimit:limit objectIndex:objectIndex];
}

#pragma mark - Getters

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSValue *) value
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [NSValue valueWithNonretainedObject:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger) indexForConnectedPath:(TSLPath *) path
////////////////////////////////////////////////////////////////////////////////////////////////
{
    
    id num = self.crossConnectedPaths[[path value]];
    if (num == nil) {
        return NSNotFound;
    }
    
    return ((NSNumber *) num).unsignedIntegerValue;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isPathCrossConnected:(TSLPath *) path
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return self.crossConnectedPaths[[path value]] != nil;
}

#pragma mark - Private setters

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setRoadObject:(TSLRoadObject *) roadObject roadLine:(NSUInteger) roadLine andRoadDirection:(eTSLRoadDirection) roadDirection
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _road          = roadObject;
    _roadLine      = roadLine;
    _roadDirection = roadDirection;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setCars:(NSMutableArray *) cars
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _cars = cars;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPointA:(NSPoint) pointA
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _pointA = pointA;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPointB:(NSPoint) pointB
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _pointB = pointB;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setLength:(CGFloat) length
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _length = length;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setDirection:(NSVector) direction
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _direction = direction;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setCarCount:(NSUInteger) carCount
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _carCount = carCount;
}

@end
