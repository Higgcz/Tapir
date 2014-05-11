//
//  TSLSemaphore.h
//  TapirApplication
//
//  Created by Vojtech Micka on 10.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLObject.h"

#define kTSLSemaphorePeriodLength (20)
#define kTSLSemaphoreTickLength (5)

@class TSLState, TSLPath;

@interface TSLSemaphore : TSLObject

// Objects properties
@property (nonatomic) NSUInteger pathPosition;
@property (nonatomic, weak) TSLPath *path;

// Semaphore properties
// Current state
@property (nonatomic, strong) TSLState *state;

// Cycle array containing the state for time unit
@property (nonatomic) NSUInteger currentTime;
@property (nonatomic) NSUInteger currentTick;

// Setting the cycle
- (void) setCycleFromString:(NSString *) string;
- (void) setCycleFromString:(NSString *) string startedAtIndex:(NSUInteger) startIndex;
- (void) setCycleOnValue:(BOOL) value inRange:(NSRange) range;

+ (instancetype) semaphore;
+ (instancetype) semaphoreAtPathPosition:(NSUInteger) pathPosition;

@end
