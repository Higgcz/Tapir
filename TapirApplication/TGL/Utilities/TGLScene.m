//
//  TGLScene.m
//  TapirApplication
//
//  Created by Vojtech Micka on 28.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TGLScene.h"
#import "TGLLayer.h"

@interface TGLScene ()

@property (nonatomic) SKNode         *world;                    // Root node to which all game renderables are attached
@property (nonatomic) NSMutableArray *zIndexNodes;              // Different zIndex nodes within the world
@property (nonatomic) NSMutableArray *layers;                   // Layers to draw and notify during update
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;    // The previous update: loop time interval

@end

@implementation TGLScene

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithSize:(CGSize)size
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super initWithSize:size];
    if (self) {
        _world = [SKNode node];
        [_world setName:@"world"];
        
        _layers      = [NSMutableArray array];
        _zIndexNodes = [NSMutableArray arrayWithCapacity:kZIndexCount];
        
        for (int i = 0; i < kZIndexCount; i++) {
            SKNode *zIndex = [SKNode node];
            zIndex.zPosition = i - kZIndexCount;
            [_world addChild:zIndex];
            [(NSMutableArray *)_zIndexNodes addObject:zIndex];
        }
        
        [self addChild:_world];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addNode:(SKNode *) node atZIndex:(TGLZIndex) zIndex;
////////////////////////////////////////////////////////////////////////////////////////////////
{
    SKNode *layerNode = self.zIndexNodes[zIndex];
    [layerNode addChild:node];
}


////////////////////////////////////////////////////////////////////////////////////////////////
- (void) registerLayer:(TGLLayer *) layer atZIndex:(TGLZIndex) zIndex;
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.layers addObject:layer];
    [self addNode:layer.node atZIndex:(TGLZIndex) zIndex];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) update:(NSTimeInterval) currentTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval deltaTime = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (deltaTime > 1) { // More than a second since last update
        deltaTime = kMinTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    if (self.isPaused) return;
    
    // update universe
    [self.updateDelegate updateWithTimeSinceLastUpdate:deltaTime];
    
    [self.layers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        TGLLayer *layer = (TGLLayer *) obj;
        
        [layer updateWithTimeSinceLastUpdate:deltaTime];
        
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) keyDown:(NSEvent *) theEvent
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (theEvent.keyCode == 0x31) {
        self.paused = !self.isPaused;
    }
}

@end
