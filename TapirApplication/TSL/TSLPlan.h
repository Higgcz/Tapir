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

- (TSLRoad *) moveNext;
- (void) addRoad:(TSLRoad *) road;
- (void) searchPathFromRoadObject:(TSLZone *) start toRoadObject:(TSLZone *) target;

+ (instancetype) plan;
+ (instancetype) planFromRoadObject:(TSLZone *) start toRoadObject:(TSLZone *) target;

@end
