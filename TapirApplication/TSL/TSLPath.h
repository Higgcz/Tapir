//
//  TSLPath.h
//  TapirApplication
//
//  Created by Vojtech Micka on 09.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLObject.h"
#import "VectorType.h"
#import "TSLSencorsProtocol.h"
#import "TSLRoad.h"

typedef NS_ENUM(NSUInteger, eTSLPathDirection) {
    TSLPathDirectionAfter  = 1,
    TSLpathDirectionBefore = 0
};

#define kTSLPathResursionLimit (3)

@class TSLCar, TSLRoadObject, TSLSemaphore;

@interface TSLPath : TSLObject <TSLSencorsProtocol>

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) NSMutableArray *cars;

@property (nonatomic, readonly) NSPoint pointA;
@property (nonatomic, readonly) NSPoint pointB;

@property (nonatomic, readonly) NSVector direction;
@property (nonatomic, readonly) NSUInteger length;
@property (nonatomic, readonly) NSUInteger carCount;

// TSLRoad
- (void) setRoadObject:(TSLRoadObject *) roadObject roadLine:(NSUInteger) roadLine andRoadDirection:(eTSLRoadDirection) roadDirection;
@property (nonatomic, weak, readonly) TSLRoadObject *road;
@property (nonatomic, readonly) NSUInteger roadLine;
@property (nonatomic, readonly) eTSLRoadDirection roadDirection; // eTSLRoadDirection

// TSLIntersection
@property (nonatomic) NSUInteger indexFrom;
@property (nonatomic) NSUInteger indexTo;

// TSLSemaphore
@property (nonatomic, strong) TSLSemaphore *semaphore;

+ (instancetype) pathFromPoint:(NSPoint) pointA toPoint:(NSPoint) pointB;

- (BOOL) canPutCar:(TSLCar *) car onPathPosition:(NSUInteger) pathPostion;
- (BOOL) canPutCar:(TSLCar *) car;
- (void) putCar:(TSLCar *) car;
- (void) putCar:(TSLCar *) car onPathPosition:(NSUInteger) pathPosition;

// @return YES if the car was able to exit
- (BOOL) shouldExitCar:(TSLCar *) car;
- (void) didExitCar:(TSLCar *) car;

- (id) objectAtPathPosition:(NSUInteger) pathPosition;

- (void) removeCarLeftover:(TSLCar *) car;

- (void) moveCar:(TSLCar *) car;

- (NSPoint) getPositionForPathPosition:(NSUInteger) pathPosition;

- (void) updateCarPosition:(TSLCar *) car;

- (NSUInteger) indexForConnectedPath:(TSLPath *) path;

- (NSValue *) value;

- (BOOL) isPathCrossConnected:(TSLPath *) path;

- (void) addCrossConnectedPath:(NSSet *) set;
- (void) addLinarConnectedPath:(NSSet *) set;

- (id) getClosestObjectInDirection:(eTSLPathDirection) dir toCar:(TSLCar *) car objectIndex:(NSUInteger *) objectIndex;
- (id) getClosestObjectInDirection:(eTSLPathDirection) dir forPath:(TSLPath *) path withLimit:(NSInteger) limit objectIndex:(NSUInteger *) objectIndex withRecursionLimit:(NSInteger) recursionLimit;
- (id) getClosestObjectInDirection:(eTSLPathDirection) dir forIndex:(NSUInteger) index withLimit:(NSInteger) limit objectIndex:(NSUInteger *) objectIndex withRecursionLimit:(NSInteger) recursionLimit;

@end
