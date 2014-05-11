//
//  TSLCar.m
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLDriverAgent.h"
#import "TSLCar.h"
#import "TSLBody.h"
#import "TSLPlan.h"
#import "TSLPath.h"
#import "TSLIntersection.h"
#import "TSLSemaphore.h"
#import "TSLState.h"
#import "TSLUniverse.h"
#import "TSLConfiguration.h"

#import "Vectors.h"

#import "../TGL/TGL.h"

@interface TSLDriverAgent ()

- (eTSLCarLineChange) shouldChangeLine;
- (BOOL) shouldSpeedUp;
- (BOOL) shouldStayOnSemaphoreState:(TSLState *) state;

@end

@implementation TSLDriverAgent {
    BOOL _go;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setup
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.plan = [TSLPlan plan];
    
    // Prefered distance
    self.preferedDistance    = 5.0f;
    self.preferedDistanceMin = 1.0f;
    self.preferedDistanceMax = 10.0f;
}

#pragma mark - Car controling on Path

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLPath *) pathForCar:(TSLCar *) car andRoadObject:(TSLRoadObject *) roadObject;
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLPath *newPath;
    
    if ([roadObject isKindOfClass:[TSLIntersection class]]) {
        TSLIntersection *inters = (TSLIntersection *) roadObject;
        newPath = [inters pathFromRoad:self.plan.current toRoad:self.plan.nextRoad];
    } else {
        if ([roadObject isKindOfClass:[TSLRoad class]]) {
            TSLRoad *road = (TSLRoad *) roadObject;
            newPath = [road pathForLine:car.roadLine andDirection:car.roadDirection];
        }
    }
    
    return newPath;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) arriveToNewRoadObject:(TSLRoadObject *) roadObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if ([roadObject isKindOfClass:[TSLIntersection class]] == NO) {
        [self.plan moveNext];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didStartCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.active = YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) shouldExitCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (self.isActive == NO) {
        return NO;
    }
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didExitCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super updateWithTimeSinceLastUpdate:deltaTime];
    
    if ( self.isActive == NO ) return;

    CGFloat desiredSpeed = CGFLOAT_MAX;
    
    eTSLCarLineChange lineChange = [self shouldChangeLine];
    
    if (lineChange != TSLCarLineChangeNO && [self.car isPossibleToChangeLine:lineChange]) {
        [self.car changeLine:lineChange];
    } else {
        if (self.car.speed - kTSLRoadWidth/2 < 0) {
            desiredSpeed = kTSLRoadWidth/2 - self.car.speed;
        }
    }
    
    CGFloat distance            = [self.car getDistanceToCarAfter];
    CGFloat distanceToSemaphore = [self.car getDistanceToSemaphore];
    
    if (distance < self.preferedDistance) {
        desiredSpeed = 0;
    } else if (desiredSpeed == CGFLOAT_MAX) {
        desiredSpeed = distance - self.preferedDistance;
    }
    
    if (distanceToSemaphore < distance) {
        TSLSemaphore *semaphore = [self.car getClosestSemaphore];
        
        if ([self shouldStayOnSemaphoreState:semaphore.state]) {
            desiredSpeed = MAX(distanceToSemaphore - self.preferedDistance, 0);
        }
    }
    
    if (desiredSpeed > self.car.maxSpeed) {
        if ([self shouldSpeedUp]) {
            [self.car speedUp];
        } else {
            [self.car slowDown];
        }
    } else {
        self.car.speed = desiredSpeed;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (eTSLCarLineChange) shouldChangeLine
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger desiredLine = [self.car getLineForDesiredRoad:self.plan.nextRoad];
    if (desiredLine == NSNotFound) {
        return TSLCarLineChangeNO;
    }
    
    if (self.car.roadLine < desiredLine) {
        return TSLCarLineChangeRIGHT;
    } else if (self.car.roadLine > desiredLine) {
        return TSLCarLineChangeLEFT;
    } else {
        return TSLCarLineChangeNO;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) shouldStayOnSemaphoreState:(TSLState *) state
////////////////////////////////////////////////////////////////////////////////////////////////
{
    switch (state.value) {
        case TSLStateRed:    return YES;
        case TSLStateOrange: return YES;
        default:
            return NO;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) shouldSpeedUp
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return (rand() % 100) < self.universe.configuration.probDriverSpeedUp;
}


#pragma mark - Setters

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setActive:(BOOL) active
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super setActive:active];
    self.car.active = active;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setCar:(TSLCar *) car
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _car = car;
    if (_car.driver != self) {
        _car.driver = self;
    }
}

#pragma mark - TSLColisionDelegate

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) colidesWith:(TSLBody *) otherBody
////////////////////////////////////////////////////////////////////////////////////////////////
{
    
}

#pragma mark - TSLObject

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

@end
