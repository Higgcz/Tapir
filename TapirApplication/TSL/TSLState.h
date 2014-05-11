//
//  TSLState.h
//  TapirApplication
//
//  Created by Vojtech Micka on 11.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLObject.h"

typedef NS_ENUM(NSUInteger, eTSLState) {
    TSLStateRed       = 0,
    TSLStateRedOrange = 1,
    TSLStateGreen     = 2,
    TSLStateOrange    = 3
};

#define kTSLStateCount (4)
#define kTSLOrangeTime (3)

@interface TSLState : TSLObject

@property (nonatomic) eTSLState value;
@property (nonatomic, weak) NSColor *color;

@property (nonatomic) NSUInteger stateDelay;

@property (nonatomic) NSUInteger timeSinceLastChange;

- (void) change:(BOOL) value;
- (void) changeToRed;
- (void) changeToGreen;

// Creation
+ (instancetype) state;

@end
