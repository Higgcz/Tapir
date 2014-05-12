//
//  TGLSceneUpdateDelegate.h
//  TapirApplication
//
//  Created by Vojtech Micka on 28.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLConfiguration;

@protocol TGLSceneUpdateDelegate <NSObject>

- (void) resetScene;
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime;

@end
