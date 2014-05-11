//
//  TSLIntersection.h
//  TapirApplication
//
//  Created by Vojtech Micka on 08.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLRoadObject.h"

#define kMAX_ROADS (4)

@class TSLWaypoint, TSLRoad, TSLPath;

@interface TSLIntersection : TSLRoadObject

+ (instancetype) intersectionAtPoint:(NSPoint) position andRadius:(CGFloat) radius;

@property (nonatomic) CGFloat radius;

@property (nonatomic, strong) NSMutableArray *roads;
@property (nonatomic, readonly) NSUInteger count;

- (void) addRoad:(TSLRoad *) road;

- (NSInteger) getLineNumberPathFromRoad:(TSLRoad *) roadA toRoad:(TSLRoad *) roadB;

- (TSLPath *) pathFromRoad:(TSLRoad *) roadFrom toRoad:(TSLRoad *) roadTo;
- (TSLPath *) pathFromRoadIdx:(NSUInteger) roadIdxFrom toRoadIdx:(NSUInteger) roadIdxTo;

// ----------------
// Path creation
// ----------------
// From TSLRoad

- (void) createPathFromRoad:(TSLRoad *) roadA fromToLine:(NSUInteger) line toRoad:(TSLRoad *) roadB;
- (void) createPathFromRoad:(TSLRoad *) roadA fromLine:(NSUInteger) lineA toRoad:(TSLRoad *) roadB toLine:(NSUInteger) lineB;

// Generic
- (void) createPath:(TSLPath *) path fromRoadObject:(TSLRoadObject *) roadObjectA toRoadObject:(TSLRoadObject *) roadObjectB;


@end
