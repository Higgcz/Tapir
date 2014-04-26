//
//  TSLCar.h
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSLCar : NSObject

@property (nonatomic) CGRect frame;
@property (nonatomic, strong) NSBezierPath *shape;

// ...

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) interval;

@end
