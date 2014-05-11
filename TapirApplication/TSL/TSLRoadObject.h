//
//  TSLRoadObject.h
//  TapirApplication
//
//  Created by Vojtech Micka on 08.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLObject.h"
#import "TSLSencorsProtocol.h"

@class TSLCar, TSLPath;

@interface TSLRoadObject : TSLObject

@property (nonatomic) NSPoint position;

- (instancetype) initWithPosition:(NSPoint) position;

- (void) takeCar:(TSLCar *) car fromRoadObject:(TSLRoadObject *) roadObject;

// @return YES if the car was able to exit
- (BOOL) shouldExitCar:(TSLCar *) car;
- (void) didExitCar:(TSLCar *) car;
- (TSLPath *) pathForExitingCar:(TSLCar *) car;

- (NSSet *) pathsNextForPath:(TSLPath *) path;
- (NSSet *) pathsForPath:(TSLPath *) path fromRoadObject:(TSLRoadObject *) roadObject;

@end
