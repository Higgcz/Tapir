//
//  TSLRoad.h
//  TapirApplication
//
//  Created by Vojtech Micka on 07.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLRoadObject.h"
#import "VectorType.h"

#define kTSLRoadWidth (10.0)
#define kMAX_LINECOUNT (3)

typedef NS_ENUM(NSUInteger, eTSLRoadDirection) {
    TSLRoadDirectionPositive = 1, // start to end
    TSLRoadDirectionNegative = 0, // end to start
    TSLRoadDirectionNone     = -1 // None
};

@class TSLWaypoint, TSLCar, TSLPath, TSLSemaphore;

@interface TSLRoad : TSLRoadObject

@property (nonatomic, strong, readonly) NSMutableArray *pathsPositive;
@property (nonatomic, strong, readonly) NSMutableArray *pathsNegative;

@property (nonatomic) NSPoint startPoint;
@property (nonatomic) NSPoint endPoint;

@property (nonatomic, readonly) CGFloat length;
@property (nonatomic, readonly) NSVector direction;

@property (nonatomic) NSUInteger lineCountPositiveDir; // right side
@property (nonatomic) NSUInteger lineCountNegativeDir; // left side

// Linked roads
@property (nonatomic, weak) TSLRoadObject *prev;
@property (nonatomic, weak) TSLRoadObject *next;

// Direction dependent
- (NSMutableArray *) pathsInDirection:(eTSLRoadDirection) dir;
- (NSUInteger) lineCountInDirection:(eTSLRoadDirection) dir;
- (TSLRoadObject *) prevInDirection:(eTSLRoadDirection) dir;
- (TSLRoadObject *) nextInDirection:(eTSLRoadDirection) dir;
- (NSVector) directionInDirection:(eTSLRoadDirection) dir;

// Creating
- (instancetype) initWithStart:(NSPoint) startPoint andEnd:(NSPoint) endPoint;

+ (instancetype) road;
+ (instancetype) roadWithStart:(NSPoint) startPoint andEnd:(NSPoint) endPoint;
+ (instancetype) roadWithStartPoint:(NSPoint) startPoint andConnectToRoadObject:(TSLRoadObject *) next;
+ (instancetype) roadConnectToRoadObject:(TSLRoadObject *) prev andEndPoint:(NSPoint) endPoint;
+ (instancetype) roadBetweenRoadObjectA:(TSLRoadObject *) roadA andRoadObjectB:(TSLRoadObject *) roadB;

- (BOOL) isFreeLine:(NSUInteger)line inDir:(eTSLRoadDirection) dir forCar:(TSLCar *) car;
- (NSInteger) getFreeLineInDirection:(eTSLRoadDirection) dir forCar:(TSLCar *) car;
- (TSLPath *) getFreePathInDirection:(eTSLRoadDirection) dir forCar:(TSLCar *) car;

- (eTSLRoadDirection) getDirectionFromRoadObject:(TSLRoadObject *) roadObject;
- (eTSLRoadDirection) getDirectionToRoadObject:(TSLRoadObject *) roadObject;

- (TSLPath *) pathForLine:(NSUInteger) lineNumber andDirection:(eTSLRoadDirection) dir;

// ----------------
// Semaphore
// ----------------
- (TSLSemaphore *) createSemaphoreAtLine:(NSUInteger) lineNumber inDirection:(eTSLRoadDirection) dir;

@end
