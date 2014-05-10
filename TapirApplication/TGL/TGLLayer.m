//
//  TGLLayer.m
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TGLLayer.h"
#import "Utilities/TGLShapeNode.h"

@implementation TGLLayer

#pragma mark - Updating

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (self.updateBlock != nil) {
        BOOL isDead = NO;
        self.updateBlock ( deltaTime, self.node, &isDead );
        if (isDead) {
            self.dead = YES;
        }
    }
}

#pragma mark - Private Setters

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setNode:(SKNode *) node
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _node = node;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setUpdateBlock:(TGLLayerUpdateBlock) updateBlock
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _updateBlock = updateBlock;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setDead:(BOOL) dead
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _dead = dead;
    if (dead) {
        [_node removeAllActions];
        [_node removeFromParent];
    }
}

#pragma mark - Initialization & Creation

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        self.dead = NO;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layer
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TGLLayer alloc] init];
}

#pragma mark Node

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithNode:(SKNode *) node
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [TGLLayer layerWithNode:node andUpdate:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithNode:(SKNode *) node andUpdate:(TGLLayerUpdateBlock) updateBlock
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TGLLayer *layer   = [TGLLayer layer];
    layer.node        = node;
    layer.updateBlock = updateBlock;
    return layer;
}

#pragma mark Grid

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithGridInRectSize:(CGSize) rectSize gridSize:(CGSize) gridSize andStrokeColor:(SKColor *) strokeColor
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TGLLayer *layer = [TGLLayer layer];
    
    SKNode *baseShape = [SKNode node];
    
    SKSpriteNode *lineShape;
    
    CGSize cellSize = CGSizeMake(rectSize.width / gridSize.width, rectSize.height / gridSize.height);
    
    // Add ver lines
    for (int c = 1; c < gridSize.width; c++) {
        lineShape             = [SKSpriteNode spriteNodeWithColor:strokeColor size:CGSizeMake(2.0f, rectSize.height)];
        lineShape.position    = CGPointMake(cellSize.width * c, rectSize.height / 2.0f);
        [baseShape addChild:lineShape];
    }
    
    // Add hor lines
    for (int r = 1; r < gridSize.height; r++) {
        lineShape             = [SKSpriteNode spriteNodeWithColor:strokeColor size:CGSizeMake(rectSize.width, 2.0f)];
        lineShape.position    = CGPointMake(rectSize.width / 2.0f, cellSize.height * r);
        [baseShape addChild:lineShape];
    }
    
    layer.node        = baseShape;
    layer.updateBlock = nil;
    
    return layer;
}

#pragma mark Line

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithLineFromA:(NSPoint) pointA toB:(NSPoint) pointB strokColor:(SKColor *) strokeColor
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TGLLayer *layer = [TGLLayer layer];
    
//    TGLShapeNode *shapeNode = [TGLShapeNode shapeNodeWithLineFromA:pointA toB:pointB strokeColor:strokeColor lineWidth:1.0];
    SKShapeNode *shapeNode = [SKShapeNode node];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, (int)pointA.x, (int)pointA.y);
    CGPathAddLineToPoint(path, NULL, (int)pointB.x, (int)pointB.y);
    
    shapeNode.strokeColor = strokeColor;
    shapeNode.lineWidth = 1.0f;
    shapeNode.path = path;
    
    CGPathRelease(path);
    
    layer.node        = shapeNode;
    layer.updateBlock = nil;
    
    return layer;
}

#pragma mark Rectangle

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithRectangleSize:(CGSize) rectSize fillColor:(SKColor *) fillColor
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [TGLLayer layerWithRectangleSize:rectSize fillColor:fillColor strokeColor:nil andUpdate:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithRectangleSize:(CGSize) rectSize fillColor:(SKColor *) fillColor andUpdate:(TGLLayerUpdateBlock) updateBlock
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [TGLLayer layerWithRectangleSize:rectSize fillColor:fillColor strokeColor:nil andUpdate:updateBlock];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithRectangleSize:(CGSize) rectSize fillColor:(SKColor *) fillColor strokeColor:(SKColor *) strokeColor andUpdate:(TGLLayerUpdateBlock) updateBlock
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TGLLayer *layer   = [TGLLayer layer];
    layer.node        = [TGLShapeNode shapeNodeWithRectangleSize:rectSize fillColor:fillColor strokeColor:strokeColor];
    layer.updateBlock = updateBlock;
    return layer;
}

#pragma mark Circle

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithCircleRadius:(CGFloat) r atPoint:(NSPoint) point fillColor:(SKColor *) fillColor
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [TGLLayer layerWithCircleRadius:r atPoint:point fillColor:fillColor strokeColor:nil andUpdate:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithCircleRadius:(CGFloat) r atPoint:(NSPoint) point fillColor:(SKColor *) fillColor andUpdate:(TGLLayerUpdateBlock) updateBlock
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [TGLLayer layerWithCircleRadius:r atPoint:point fillColor:fillColor strokeColor:nil andUpdate:updateBlock];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithCircleRadius:(CGFloat) r atPoint:(NSPoint) point fillColor:(SKColor *) fillColor strokeColor:(SKColor *) strokeColor andUpdate:(TGLLayerUpdateBlock) updateBlock
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TGLLayer *layer   = [TGLLayer layer];
    layer.node        = [TGLShapeNode shapeNodeWithCircleOfRadius:r fillColor:fillColor strokeColor:strokeColor];
    point.x -= r;
    point.y -= r;
    layer.node.position = point;
    layer.updateBlock = updateBlock;
    return layer;
}

#pragma mark General Bezier Path

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithBezierPath:(NSBezierPath *) bezierPath fillColor:(SKColor *) fillColor
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [TGLLayer layerWithBezierPath:bezierPath fillColor:fillColor strokeColor:nil andUpdate:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithBezierPath:(NSBezierPath *) bezierPath fillColor:(SKColor *) fillColor andUpdate:(TGLLayerUpdateBlock) updateBlock
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [TGLLayer layerWithBezierPath:bezierPath fillColor:fillColor strokeColor:nil andUpdate:updateBlock];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLLayer *) layerWithBezierPath:(NSBezierPath *) bezierPath fillColor:(SKColor *) fillColor strokeColor:(SKColor *) strokeColor andUpdate:(TGLLayerUpdateBlock) updateBlock
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TGLLayer *layer   = [TGLLayer layer];
    layer.node        = [TGLShapeNode shapeNodeWithBezierPath:bezierPath fillColor:fillColor strokeColor:strokeColor];
    layer.updateBlock = updateBlock;
    return layer;
}

@end
