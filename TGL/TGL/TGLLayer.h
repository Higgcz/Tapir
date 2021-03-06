//
//  TGLLayer.h
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

typedef void (^TGLLayerUpdateBlock)(CFTimeInterval deltaTime, SKNode *node, BOOL *isDead);

@interface TGLLayer : NSObject

@property (nonatomic,         readonly) TGLLayerUpdateBlock updateBlock;
@property (nonatomic, strong, readonly) SKNode              *node;

@property (nonatomic, getter = isDead) BOOL dead;

// Updating
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime;

// Creation
+ (TGLLayer *) layer;

// Node
+ (TGLLayer *) layerWithNode:(SKNode *) node;
+ (TGLLayer *) layerWithNode:(SKNode *) node andUpdate:(TGLLayerUpdateBlock) updateBlock;

// Grid
+ (TGLLayer *) layerWithGridInRectSize:(CGSize) rectSize gridSize:(CGSize) gridSize andStrokeColor:(SKColor *) strokeColor;

// Line
+ (TGLLayer *) layerWithLineFromA:(NSPoint) pointA toB:(NSPoint) pointB strokColor:(SKColor *) strokeColor;

// Rectangle
+ (TGLLayer *) layerWithRectangleSize:(CGSize) rectSize fillColor:(SKColor *) fillColor;
+ (TGLLayer *) layerWithRectangleSize:(CGSize) rectSize fillColor:(SKColor *) fillColor andUpdate:(TGLLayerUpdateBlock) updateBlock;
+ (TGLLayer *) layerWithRectangleSize:(CGSize) rectSize fillColor:(SKColor *) fillColor strokeColor:(SKColor *) strokeColor andUpdate:(TGLLayerUpdateBlock) updateBlock;

// Circle
+ (TGLLayer *) layerWithCircleRadius:(CGFloat) r atPoint:(NSPoint) point fillColor:(SKColor *) fillColor;
+ (TGLLayer *) layerWithCircleRadius:(CGFloat) r atPoint:(NSPoint) point fillColor:(SKColor *) fillColor andUpdate:(TGLLayerUpdateBlock) updateBlock;
+ (TGLLayer *) layerWithCircleRadius:(CGFloat) r atPoint:(NSPoint) point fillColor:(SKColor *) fillColor strokeColor:(SKColor *) strokeColor andUpdate:(TGLLayerUpdateBlock) updateBlock;

// General bezier path
+ (TGLLayer *) layerWithBezierPath:(NSBezierPath *) bezierPath fillColor:(SKColor *) fillColor;
+ (TGLLayer *) layerWithBezierPath:(NSBezierPath *) bezierPath fillColor:(SKColor *) fillColor andUpdate:(TGLLayerUpdateBlock) updateBlock;
+ (TGLLayer *) layerWithBezierPath:(NSBezierPath *) bezierPath fillColor:(SKColor *) fillColor strokeColor:(SKColor *) strokeColor andUpdate:(TGLLayerUpdateBlock) updateBlock;

@end
