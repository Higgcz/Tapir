//
//  TSLCar.h
//  TapirApplication
//
//  Created by Vojtech Micka on 08.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLObject.h"
#import "VectorType.h"
#import "TSLSencorsProtocol.h"
#import "TSLRoad.h"

#define kTSLCarMinLength (8)
#define kTSLCarMaxLength (22)

typedef NS_ENUM(NSUInteger, eTSLCarType) {
    TSLCarTypePassenger,    // Length: MIN, MaxSpeed: 36, Acc: 1.5
    TSLCarTypeTruck,        // Length:  12, MaxSpeed: 27, Acc: 1.0
    TSLCarTypeBus           // Length: MAX, MaxSpeed: 22, Acc: 0.5
};

typedef NS_ENUM(NSUInteger, eTSLCarLineChange) {
    TSLCarLineChangeNO = 0,
    TSLCarLineChangeLEFT,
    TSLCarLineChangeRIGHT
};

@class TSLBody, TSLRoad, TSLDriverAgent, TSLWaypoint, TSLPath, TSLRoadObject, TSLSemaphore, TSLZone;

@interface TSLCar : TSLObject

// Initialization
- (instancetype) initWithType:(eTSLCarType) carType;

+ (instancetype) car;
+ (instancetype) carWithType:(eTSLCarType) carType;

// Statistics
@property (nonatomic) CGFloat finishTime;
@property (nonatomic) CGFloat finishDistance;

// Parameters of car
@property (nonatomic) CGFloat maxSpeed;
@property (nonatomic) NSInteger maxRange;

// Dynamic properties
@property (nonatomic) NSVector direction;
@property (nonatomic) CGFloat acceleration;
@property (nonatomic) CGFloat speed;

// Path
@property (nonatomic, weak) TSLPath *path;
@property (nonatomic) NSUInteger pathPosition;
@property (nonatomic) NSUInteger pathPositionMomentum;

// Roads
@property (nonatomic, weak, readonly) TSLRoadObject *road;
@property (nonatomic, readonly) NSUInteger roadLine;
@property (nonatomic, readonly) eTSLRoadDirection roadDirection; // eTSLRoadDirection

// Sensors
@property (nonatomic, weak) id<TSLSencorsProtocol> sensorProvider;

- (void) speedUp;
- (void) slowDown;

// Static properties
@property (nonatomic) eTSLCarType carType;
@property (nonatomic, strong) TSLBody *body;
@property (nonatomic, strong) TSLDriverAgent *driver;

@property (nonatomic, weak, readonly) NSColor *color;

@property (nonatomic, readonly, weak) TSLZone *startedZone;
- (void) addToZone:(TSLZone *) zone;

- (void) moveToPosition:(NSPoint) position;

- (CGFloat) getDistanceToCar:(TSLCar *) otherCar;
- (CGFloat) getDistanceToSemaphore;
- (TSLSemaphore *) getClosestSemaphore;

// @return YES if the car was able to exit
- (BOOL) shouldExit;
- (void) didExit;
- (void) didStart;
- (TSLPath *) pathForRoadObject:(TSLRoadObject *) roadObject;
- (void) arriveToNewRoadObject:(TSLRoadObject *) roadObject;

- (NSUInteger) getLineForDesiredRoad:(TSLRoad *) desiredRoad;
- (BOOL) isPossibleToChangeLine:(eTSLCarLineChange) lineChange;
- (void) changeLine:(eTSLCarLineChange) lineChange;

// Sensors
- (CGFloat) getDistanceToCarAfter;
- (CGFloat) getSpeedToCarAfter;
- (id) getClosestObjectAfter;

- (CGFloat) getDistanceToCarBefore;
- (CGFloat) getSpeedToCarBefore;
- (id) getClosestObjectBefore;

//- (BOOL) isArrivedToWaypoint:(TSLWaypoint *) waypoint withAccurancy:(CGFloat) accurancy;

@end
