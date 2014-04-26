//
//  TSLUniverseDelegate.h
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSLUniverseDelegate <NSObject>

- (void) didEvaluateUpdate;
- (void) didSimulatePhysics;

@end
