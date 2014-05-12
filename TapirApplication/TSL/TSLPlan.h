//
//  TSLPlan.h
//  TapirApplication
//
//  Created by Vojtech Micka on 10.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLRoad, TSLZone;

@interface TSLPlan : NSObject

@property (nonatomic, weak) TSLRoad *current;
@property (nonatomic, weak) TSLRoad *nextRoad;

- (void) resetToBeginning;

- (TSLRoad *) moveNext;
- (void) addRoad:(TSLRoad *) road;
- (void) searchPathFromZone:(TSLZone *) start toZone:(TSLZone *) target;

+ (instancetype) plan;
+ (instancetype) planFromZone:(TSLZone *) start toZone:(TSLZone *) target;

@end
