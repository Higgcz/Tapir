//
//  TSLUniverseDelegate.h
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLUniverse;

@protocol TSLUniverseDelegate <NSObject>


- (BOOL) shouldDie:(TSLUniverse *) universe;
- (void) willUniverseReset:(TSLUniverse *) universe;
- (void) didUniverseDie:(TSLUniverse *) universe;
- (void) didEvaluateUpdate:(TSLUniverse *) universe;
- (void) didSimulatePhysics:(TSLUniverse *) universe;

@end
