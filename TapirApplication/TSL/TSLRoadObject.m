//
//  TSLRoadObject.m
//  TapirApplication
//
//  Created by Vojtech Micka on 08.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLRoadObject.h"

#define D12_ABSTRACT_METHOD {\
[self doesNotRecognizeSelector:_cmd]; \
__builtin_unreachable(); \
}

@implementation TSLRoadObject

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithPosition:(NSPoint) position
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        self.position = position;
    }
    return self;
}

#pragma mark - Abstract methods

- (instancetype) init D12_ABSTRACT_METHOD
- (void) takeCar:(TSLCar *) car fromRoadObject:(TSLRoadObject *) roadObject D12_ABSTRACT_METHOD
- (BOOL) shouldExitCar:(TSLCar *) car D12_ABSTRACT_METHOD
- (void) didExitCar:(TSLCar *) car D12_ABSTRACT_METHOD
- (TSLPath *) pathForExitingCar:(TSLCar *) car D12_ABSTRACT_METHOD
- (TSLPath *) pathNextForPath:(TSLPath *) path D12_ABSTRACT_METHOD
- (TSLPath *) pathForPath:(TSLPath *) path fromRoadObject:(TSLRoadObject *) roadObject D12_ABSTRACT_METHOD


@end
