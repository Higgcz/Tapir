//
//  TGLScene.m
//  TapirApplication
//
//  Created by Vojtech Micka on 28.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TGLScene.h"
#import "TGLLayer.h"
#import "Vectors.h"

@interface TGLScene ()

@property (nonatomic) SKNode         *world;                    // Root node to which all game renderables are attached
@property (nonatomic) NSMutableArray *zIndexNodes;              // Different zIndex nodes within the world
@property (nonatomic) NSMutableArray *layers;                   // Layers to draw and notify during update
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;    // The previous update: loop time interval
@property (nonatomic) CGFloat        scale;
@property (nonatomic) NSUInteger     delay;
@property (nonatomic) NSUInteger     updateCounter;

@property (nonatomic) SKLabelNode    *topLeftLabel;

- (void) handleKeyEvent:(NSEvent *) theEvent keyDown:(BOOL) downOrUp;

@end

@implementation SKView(ScrollTouchForwarding)

- (void) scrollWheel:(NSEvent *) event
{
    [self.scene scrollWheel:event];
}

- (void) magnifyWithEvent:(NSEvent *) event
{
    [self.scene magnifyWithEvent:event];
}

- (void) rotateWithEvent:(NSEvent *) event
{
    [self.scene rotateWithEvent:event];
}

- (void) swipeWithEvent:(NSEvent *) event
{
    [self.scene swipeWithEvent:event];
}

@end

@implementation TGLScene

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithSize:(CGSize) size
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super initWithSize:size];
    if (self) {
        _world = [SKNode node];
        [_world setName:@"world"];
        
        _scale = 1.0f;
        _delay = 1;
        _updateCounter = 0;
        
        _layers      = [NSMutableArray array];
        _zIndexNodes = [NSMutableArray arrayWithCapacity:kZIndexCount];
        
        for (int i = 0; i < kZIndexCount; i++) {
            SKNode *zIndex = [SKNode node];
            zIndex.zPosition = i - kZIndexCount;
            [_world addChild:zIndex];
            [(NSMutableArray *)_zIndexNodes addObject:zIndex];
        }
        
        [self addChild:_world];
        
        _topLeftLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
        [self addNode:_topLeftLabel atZIndex:TGLZIndexTop];
        
        _topLeftLabel.fontSize = 16.0f;
        _topLeftLabel.text = [NSString stringWithFormat:@"Delay: %lu", self.delay];
        _topLeftLabel.position = CGPointMake(_topLeftLabel.frame.size.width / 2.0f + 5, self.size.height - _topLeftLabel.frame.size.height - 5);
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
    self.updateCounter++;
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval deltaTime = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (deltaTime > 1) { // More than a second since last update
        deltaTime = kMinTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    _topLeftLabel.text = [NSString stringWithFormat:@"Delay: %lu", self.delay];
    
    if (self.isPaused || (self.updateCounter % self.delay) != 0) {
        return;
    }
    
    // update universe
    [self.updateDelegate updateWithTimeSinceLastUpdate:deltaTime];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [self.layers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        TGLLayer *layer = (TGLLayer *) obj;
        
        [layer updateWithTimeSinceLastUpdate:deltaTime];
        
        if (layer.isDead) {
            [indexSet addIndex:idx];
        }
    }];
    
    [self.layers removeObjectsAtIndexes:indexSet];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) scrollWheel:(NSEvent *) theEvent
////////////////////////////////////////////////////////////////////////////////////////////////
{
//    self.scale += theEvent.deltaY / 10.0f;
//    
//    CGSize size = self.view.frame.size;
//    
//    NSPoint mousePoint = [NSEvent mouseLocation];
////    NSPoint mousePoint = NSMakePoint(size.width/2, size.height/2);
//    NSPoint origin = self.world.position;
//    
//    NSVector vec = NSVectorResize(NSVectorMake(mousePoint, origin), self.scale);
//    
//    self.world.position = NSVectorAdd(vec, mousePoint);
//    
//    NSLog(@"Scrolling ... scale: %f point: %@", self.scale, NSStringFromPoint(self.world.position));
//    
//    self.world.xScale = self.scale;
//    self.world.yScale = self.scale;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) keyUp:(NSEvent *) theEvent
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self handleKeyEvent:theEvent keyDown:NO];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) keyDown:(NSEvent *) theEvent
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self handleKeyEvent:theEvent keyDown:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) handleKeyEvent:(NSEvent *) theEvent keyDown:(BOOL) downOrUp
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (downOrUp == NO) return;
    
    if ([theEvent modifierFlags] & NSNumericPadKeyMask) { // arrow keys have this mask
        NSString *theArrow = [theEvent charactersIgnoringModifiers];
        unichar keyChar = 0;
        if ([theArrow length] == 1) {
            keyChar = [theArrow characterAtIndex:0];
            switch (keyChar) {
                case NSUpArrowFunctionKey:
                    self.delay++;
                    break;
                case NSDownArrowFunctionKey:
                    self.delay = MAX(self.delay - 1, 1);
                    break;
            }
        }
    }
    
    // Now check the rest of the keyboard
    NSString *characters = [theEvent characters];
    for (int s = 0; s < [characters length]; s++) {
        unichar character = [characters characterAtIndex:s];
        switch (character) {
            case ' ':
                self.paused = !self.isPaused;
                break;
        }
    }
}

- (BOOL) acceptsFirstResponder
{
    return YES;
}

@end
