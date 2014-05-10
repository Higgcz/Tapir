//
//  TSLZone.h
//  TapirApplication
//
//  Created by Vojtech Micka on 08.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLRoadObject.h"

@class TSLRoad, TSLCar, TSLPath;

@interface TSLZone : TSLRoadObject

+ (instancetype) zoneAtPosition:(NSPoint) position;

@property (nonatomic, strong) NSMutableArray *cars;

@property (nonatomic, weak) TSLRoad *road;

- (TSLPath *) getFreePathForCar:(TSLCar *) car;

@end
