//
//  TSLSencors.h
//  TapirApplication
//
//  Created by Vojtech Micka on 09.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLCar;

@protocol TSLSencorsProtocol <NSObject>

- (CGFloat) getDistanceToCarAfter:(TSLCar *) car;
- (CGFloat) getSpeedToCarAfter:(TSLCar *) car;
- (id) getClosestObjectAfterCar:(TSLCar *) car;

- (CGFloat) getDistanceToCarBefore:(TSLCar *) car;
- (CGFloat) getSpeedToCarBefore:(TSLCar *) car;
- (id) getClosestObjectBeforeCar:(TSLCar *) car;

@end
