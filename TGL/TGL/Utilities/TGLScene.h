//
//  TGLScene.h
//  TapirApplication
//
//  Created by Vojtech Micka on 28.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TGLSceneUpdateDelegate.h"

#define kMinTimeInterval (1.0f / 60.0f)

typedef NS_ENUM (uint8_t, TGLZIndex) {
	TGLZIndexGround = 0,
	TGLZIndexBelowCharacter,
	TGLZIndexCharacter,
	TGLZIndexAboveCharacter,
	TGLZIndexTop,
	kZIndexCount
};

@class TGLLayer;

@interface TGLScene : SKScene

@property (nonatomic, weak) id<TGLSceneUpdateDelegate> updateDelegate;

- (void) addNode:(SKNode *) node atZIndex:(TGLZIndex) zIndex;
- (void) registerLayer:(TGLLayer *) layer atZIndex:(TGLZIndex) zIndex;

@end
