//
//  TSLCar.h
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLEntity.h"
#import "TSLColisionDelegate.h"
#import "VectorType.h"

#define kMAX_VELOCITY       (5.0)
#define kWAYPOINT_ACCURANCY (3.0)
#define kACCURANCY          (0.001)

typedef void(^TSLAgentCompletitionBlock)(CGPoint *donePoint);

@class TSLRoad, TSLCar, TSLRoadObject, TSLPlan, TSLPath;

@interface TSLDriverAgent : TSLEntity <TSLColisionDelegate>

@property (nonatomic) CGFloat preferedDistance;
@property (nonatomic) CGFloat preferedDistanceMin; // default: 1
@property (nonatomic) CGFloat preferedDistanceMax; // default: 10

@property (nonatomic, strong) TSLPlan *plan;
@property (nonatomic, weak) TSLCar *car;

// @return YES if the car was able to exit
- (BOOL) shouldExitCar:(TSLCar *) car;
- (void) didExitCar:(TSLCar *) car;
- (void) didStartCar:(TSLCar *) car;
- (TSLPath *) pathForCar:(TSLCar *) car andRoadObject:(TSLRoadObject *) roadObject;
- (void) arriveToNewRoadObject:(TSLRoadObject *) roadObject;

@end
