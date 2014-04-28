//
//  TSLCar.h
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLAgent.h"

#define kMAX_STEER      (M_PI / 12)
#define kMAX_TORQUE     (+50)
#define kMIN_TORQUE     (-50)
#define kMAX_VELOCITY   (50)
#define kGRAVITY        (9.8)

typedef void(^TSLAgentCompletitionBlock)(CGPoint *donePoint);

@interface TSLCarAgent : TSLAgent

// Dynamic properties
@property (nonatomic) CGFloat gas;   // from -1 to 1
@property (nonatomic) CGFloat desiredVelocity;
@property (nonatomic) CGFloat steer; // from -1 to 1

@property (nonatomic, readonly) CGFloat acceleration;
@property (nonatomic, readonly) CGFloat velocity;

// Constant properties
@property (nonatomic) CGFloat mass;
@property (nonatomic) CGFloat friction;

- (void) driveToPoint:(CGPoint) point onCompletition:(TSLAgentCompletitionBlock)completitionBlock;

// ...

@end
