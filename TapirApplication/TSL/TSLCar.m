//
//  TSLCar.m
//  TapirApplication
//
//  Created by Vojtech Micka on 08.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLCar.h"
#import "TSLRoad.h"
#import "TSLBody.h"
#import "TSLPath.h"
#import "Vectors.h"
#import "TSLDriverAgent.h"
#import "TSLWaypoint.h"
#import "TSLSemaphore.h"
#import "TSLIntersection.h"

#import <TGL/TGL.h>

@interface TSLCar ()

- (void) setupWithType:(eTSLCarType) carType;

@end

@implementation TSLCar {
    TSLRoadObject *_tempRoadObject;
    NSUInteger _tempRoadLine;
    eTSLRoadDirection _tempRoadDirection;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setupWithType:(eTSLCarType) carType
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.active = NO;
    self.carType = carType;
    
    self.maxRange = 30;
    
    // default values
    switch (carType) {
        case TSLCarTypePassenger:
            self.maxSpeed     = 36;
            self.acceleration = 1.5;
            self.body         = [TSLBody bodyWithSize:NSMakeSize(kTSLCarMinLength, 4)];
            break;
        case TSLCarTypeTruck:
            self.maxSpeed     = 27;
            self.acceleration = 1.0;
            self.body         = [TSLBody bodyWithSize:NSMakeSize(12, 4)];
            break;
        case TSLCarTypeBus:
            self.maxSpeed     = 22;
            self.acceleration = 0.5;
            self.body         = [TSLBody bodyWithSize:NSMakeSize(kTSLCarMaxLength, 4)];
            break;
        default:
            ERROR(@"No such car type!");
            break;
    }
    
    self.maxSpeed /= 3;
    self.body.car = self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        [self setupWithType:TSLCarTypePassenger];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithType:(eTSLCarType) carType
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        [self setupWithType:carType];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLCar alloc] init];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) carWithType:(eTSLCarType) carType
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLCar alloc] initWithType:carType];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) speedUp
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (self.speed + self.acceleration <= self.maxSpeed) {
        self.speed += self.acceleration;
    } else {
        self.speed = self.maxSpeed;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) slowDown
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (self.speed >= self.acceleration) {
        self.speed -= self.acceleration;
    } else {
        self.speed = 0.0f;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//- (BOOL) isArrivedToWaypoint:(TSLWaypoint *) waypoint withAccurancy:(CGFloat) accurancy
//////////////////////////////////////////////////////////////////////////////////////////////////
//{
//    BOOL res = NSVectorsEqualWithAccurancy(self.body.position, waypoint.position, accurancy);
//    if (res && waypoint.nextWaypoint == nil) {
//        if ([self.currentRoad.next isKindOfClass:[TSLRoad class]]) {
//            [self.currentRoad carIsExiting:self];            
//            
//            TSLRoad *road = (TSLRoad *) self.currentRoad.next;
//            [self setCurrentRoad:road
//                         onLine:self.roadLine
//                  withDirection:[road getDirectionFromRoadObject:self.currentRoad]];
//        }
//    }
//    return res;
//}

#pragma mark - Setters

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setDriver:(TSLDriverAgent *) driver
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _driver = driver;
    if (_driver.car != self) {
        _driver.car = self;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPath:(TSLPath *) path
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (path == nil) {
        _tempRoadDirection = _path.roadDirection;
        _tempRoadLine      = _path.roadLine;
        _tempRoadObject    = _path.road;
    }
    
    _path = path;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPathPosition:(NSUInteger) pathPosition
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _pathPosition = pathPosition;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) moveToPosition:(NSPoint) position
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.body.position = position;
}

#pragma mark - Getters

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLBody *) body
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.direction  = self.path.direction;
    _body.position  = [self.path getPositionForPathPosition:self.pathPosition];
    _body.zRotation = NSVectorAngle(self.path.direction);
    
    return _body;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLRoadObject *) road
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return self.path == nil ? _tempRoadObject : self.path.road;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger) roadLine
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return self.path == nil ? _tempRoadLine : self.path.roadLine;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (eTSLRoadDirection) roadDirection
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return self.path == nil ? _tempRoadDirection : self.path.roadDirection;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) getDistanceToCar:(TSLCar *) otherCar
////////////////////////////////////////////////////////////////////////////////////////////////
{
    CGFloat dist;
    
    if (self.path == otherCar.path) {
        dist = otherCar.pathPosition - self.pathPosition;
        // Substract the body size
        dist -= self.body.size.width / 2.0f + otherCar.body.size.width / 2.0f;
        
    } else {
        if ([self.path isPathCrossConnected:otherCar.path]) {
            NSUInteger myDistToCross    = labs([self.path indexForConnectedPath:otherCar.path] - self.pathPosition);
            NSUInteger otherDistToCross = labs([otherCar.path indexForConnectedPath:self.path] - otherCar.pathPosition);

            CGFloat otherDist = otherDistToCross - otherCar.body.size.width / 2.0f;
            
            if (otherDist <= 0) {
                dist = myDistToCross;
                dist -= self.body.size.width / 2.0f + otherCar.body.size.width / 2.0f;
            } else {
                dist = CGFLOAT_MAX;
            }
            
        } else {
            dist = otherCar.pathPosition + self.path.length - self.pathPosition;
            // Substract the body size
            dist -= self.body.size.width / 2.0f + otherCar.body.size.width / 2.0f;
        }
    }
    
    return dist;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) getDistanceToSemaphore
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (self.path.semaphore == nil) {
        return CGFLOAT_MAX;
    }
    return self.path.semaphore.pathPosition - self.pathPosition - self.body.size.width / 2.0f;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLSemaphore *) getClosestSemaphore
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return self.path.semaphore;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSColor *) color
////////////////////////////////////////////////////////////////////////////////////////////////
{
    switch (self.carType) {
        case TSLCarTypePassenger:
            return [NSColor whiteColor];
        case TSLCarTypeTruck:
            return [NSColor cyanColor];
        case TSLCarTypeBus:
            return [NSColor yellowColor];
        default:
            return [NSColor whiteColor];
    }
}

#pragma mark - Delegation

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didStart
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.driver didStartCar:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) shouldExit
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self.driver shouldExitCar:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didExit
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.driver didExitCar:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLPath *) pathForRoadObject:(TSLRoadObject *) roadObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self.driver pathForCar:self andRoadObject:roadObject];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) arriveToNewRoadObject:(TSLRoadObject *) roadObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.driver arriveToNewRoadObject:roadObject];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger) getLineForDesiredRoad:(TSLRoad *) desiredRoad
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (desiredRoad == nil) return NSNotFound;
    
    if ([self.road isKindOfClass:[TSLRoad class]]) {
        TSLRoad *currentRoad = (TSLRoad *) self.road;
        TSLRoadObject *nextRoadObject = [currentRoad nextInDirection:self.roadDirection];
        
        if ([nextRoadObject isKindOfClass:[TSLIntersection class]]) {
            
            TSLIntersection *nextIntersection = (TSLIntersection *) nextRoadObject;
            
            return [nextIntersection getLineNumberPathFromRoad:currentRoad toRoad:desiredRoad];
        }
    }
    
    return NSNotFound;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isPossibleToChangeLine:(eTSLCarLineChange) lineChange
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (self.speed != 0 && [self.road isKindOfClass:[TSLRoad class]]) {
        TSLRoad *currentRoad = (TSLRoad *) self.road;
        NSUInteger desiredLine = self.roadLine;

        switch (lineChange) {
            case TSLCarLineChangeNO:
                return NO;
                break;
            case TSLCarLineChangeLEFT:
                if (desiredLine == 0) {
                    return NO;
                }
                desiredLine--;
                break;
            case TSLCarLineChangeRIGHT:
                if (desiredLine == [currentRoad lineCountInDirection:self.roadDirection]) {
                    return NO;
                }
                desiredLine++;
                break;
        }
        
        TSLPath *desiredPath = [currentRoad pathForLine:desiredLine andDirection:self.roadDirection];
        
        CGFloat calcSpeed = self.speed - kTSLRoadWidth/2;
        if (calcSpeed < 0) return NO;
        
        if ([desiredPath canPutCar:self onPathPosition:(self.pathPosition + calcSpeed)]) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) changeLine:(eTSLCarLineChange) lineChange
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert([self.road isKindOfClass:[TSLRoad class]], @"You should call 'isPossibleToChangeLine:' first. (self.road is not TSLRoad)");
    TSLRoad *currentRoad = (TSLRoad *) self.road;
    NSUInteger desiredLine = self.roadLine;
    
    switch (lineChange) {
        case TSLCarLineChangeNO:
            break;
        case TSLCarLineChangeLEFT:
            NSAssert(desiredLine > 0, @"You should call 'isPossibleToChangeLine:' first. (desiredLine < 0)");
            desiredLine--;
            break;
        case TSLCarLineChangeRIGHT:
            NSAssert(desiredLine < [currentRoad lineCountInDirection:self.roadDirection], @"You should call 'isPossibleToChangeLine:' first. (desiredLine > lineCount)");
            desiredLine++;
            break;
    }
    
    TSLPath *desiredPath = [currentRoad pathForLine:desiredLine andDirection:self.roadDirection];
    
    NSUInteger desiredPathPosition = self.pathPosition + self.speed - kTSLRoadWidth;
    
    if ([desiredPath canPutCar:self onPathPosition:desiredPathPosition]) {
        
//        NSLog(@"Car %@ is changing line from %@ to %@ with desiredPP: %lu", self, self.path.name, desiredPath.name, desiredPathPosition);
        
        // Remove from current path
        [self.path removeCarLeftover:self];
        // Add to desired path
        [desiredPath putCar:self onPathPosition:desiredPathPosition];
    }
}

#pragma mark - Sensors

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) getDistanceToCarAfter
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self.sensorProvider getDistanceToCarAfter:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) getSpeedToCarAfter
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self.sensorProvider getSpeedToCarAfter:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (id) getClosestObjectAfter
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self.sensorProvider getClosestObjectAfterCar:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) getDistanceToCarBefore
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self.sensorProvider getDistanceToCarBefore:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) getSpeedToCarBefore
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self.sensorProvider getSpeedToCarBefore:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (id) getClosestObjectBefore
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self.sensorProvider getClosestObjectBeforeCar:self];
}

#pragma mark - TSLObject

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super updateWithTimeSinceLastUpdate:deltaTime];
//    [self.body resetChanges];
    
    // Call driver for update
    [self.driver updateWithTimeSinceLastUpdate:deltaTime];
    
    // Update car
    if (self.isActive == NO) return;
    
    [self.path updateCarPosition:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) removeFromUniverse
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super removeFromUniverse];
    
    if (self.path != nil) {
        [self.path removeCarLeftover:self];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didCreatedAtUniverse:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super didCreatedAtUniverse:universe];
    
    [TGLSceneManager registerLayerWithNode:[TGLShapeNode shapeNodeWithRectangleSize:self.body.size fillColor:self.color strokeColor:nil] andUpdate:^(CFTimeInterval deltaTime, SKNode *node, BOOL *isDead) {
        
        NSVector s = CGPointMake(self.body.size.height * 0.5f, self.body.size.width * 0.5f);
        
        node.position  = CGPointMake (
                                      self.body.position.x - NSVectorCross(self.direction, s),
                                      self.body.position.y - NSVectorDot(self.direction, s)
                                      );
        node.zRotation = self.body.zRotation;
        
        *isDead = self.isDead;
    }];
    
    [self.driver didCreatedAtUniverse:universe];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didDeleted
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super didDeleted];
    [self.driver didDeleted];
    [self.path removeCarLeftover:self];
}

@end
