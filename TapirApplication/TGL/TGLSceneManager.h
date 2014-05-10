//
//  TGLSceneManager.h
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGLLayer.h"
#import "Utilities/TGLScene.h"

@class SKNode;

@interface TGLSceneManager : NSObject

@property (nonatomic, weak, readonly) TGLScene *scene;

- (TGLScene *) createSceneWithScene:(TGLScene *) scene;
- (TGLScene *) createSceneWithSize:(CGSize) sceneSize;

- (void) registerLayer:(TGLLayer *) layer atZIndex:(TGLZIndex) zIndex;

// Class method - singleton & faster layer registration

+ (TGLSceneManager *) sharedInstance;

+ (void) registerLayer:(TGLLayer *) layer;
+ (void) registerLayer:(TGLLayer *) layer atZIndex:(TGLZIndex) zIndex;
+ (void) registerLayerWithNode:(SKNode *) node;
+ (void) registerLayerWithNode:(SKNode *) node atZIndex:(TGLZIndex) zIndex;
+ (void) registerLayerWithNode:(SKNode *) node andUpdate:(TGLLayerUpdateBlock) updateBlock;
+ (void) registerLayerWithNode:(SKNode *) node andUpdate:(TGLLayerUpdateBlock) updateBlock atZIndex:(TGLZIndex) zIndex;

@end
