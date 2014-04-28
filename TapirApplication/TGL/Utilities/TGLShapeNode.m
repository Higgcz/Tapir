//
//  TSLShapeNode.m
//  TapirApplication
//
//  Created by Michael Redig on 4/7/14.
//  URL: https://github.com/mredig/SKUtilities/blob/Shapes/time_conv/Utilities/SKUShapeNode.m
//  Copyright (c) 2014 Michael Redig. All rights reserved.
//
//  Edited by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TGLShapeNode.h"
#import "NSBezierPath+BezierPathQuartzUtilities.h"

@interface TGLShapeNode() {
	CAShapeLayer* shapeLayer;
}

@end


@implementation TGLShapeNode

////////////////////////////////////////////////////////////////////////////////////////////////
- (id) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    
	if (self = [super init]) {
		_boundingSize = CGSizeMake(500, 500);
		_strokeColor = [SKColor whiteColor];
		_fillColor = [SKColor clearColor];
		_lineWidth = 1.0;
		_fillRule = kCAFillRuleNonZero;
		_lineCap = kCALineCapButt;
		_lineDashPattern = nil;
		_lineDashPhase = 0;
		_lineJoin = kCALineJoinMiter;
		_miterLimit = 10.0;
		_strokeEnd = 1.0;
		_strokeStart = 0.0;
        
		self.anchorPoint = CGPointZero;
	}
    
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLShapeNode *) shapeNodeWithCircleOfRadius:(CGFloat) r fillColor:(SKColor *) fillColor strokeColor:(SKColor *) strokeColor
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TGLShapeNode *shapeNode = [TGLShapeNode node];
    shapeNode.fillColor   = fillColor;
    shapeNode.strokeColor = strokeColor;
    
    CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, 2 * r, 2 * r), NULL);
    shapeNode.path = path;
    CGPathRelease(path);
    return shapeNode;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLShapeNode *) shapeNodeWithRectangleSize:(CGSize) rectSize fillColor:(SKColor *) fillColor strokeColor:(SKColor *) strokeColor
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TGLShapeNode *shapeNode = [TGLShapeNode node];
    shapeNode.fillColor   = fillColor;
    shapeNode.strokeColor = strokeColor;
    
    CGPathRef path = CGPathCreateWithRect((CGRect) {{0, 0}, rectSize}, NULL);
    shapeNode.path = path;
    CGPathRelease(path);
    return shapeNode;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TGLShapeNode *) shapeNodeWithBezierPath:(NSBezierPath *) bezierPath fillColor:(SKColor *) fillColor strokeColor:(SKColor *) strokeColor
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TGLShapeNode *shapeNode = [TGLShapeNode node];
    shapeNode.fillColor   = fillColor;
    shapeNode.strokeColor = strokeColor;
    
    shapeNode.path = bezierPath.quartzPath;
    return shapeNode;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) redrawTexture
////////////////////////////////////////////////////////////////////////////////////////////////
{
    
	if (!_path) {
		return;
	}
    
	if (!shapeLayer) {
		shapeLayer = [CAShapeLayer layer];
	}
    
	shapeLayer.strokeColor = [_strokeColor CGColor];
	shapeLayer.fillColor = [_fillColor CGColor];
	shapeLayer.lineWidth = _lineWidth;
	shapeLayer.fillRule = _fillRule;
	shapeLayer.lineCap = _lineCap;
	shapeLayer.lineDashPattern = _lineDashPattern;
	shapeLayer.lineDashPhase = _lineDashPhase;
	shapeLayer.lineJoin = _lineJoin;
	shapeLayer.miterLimit = _miterLimit;
	shapeLayer.strokeEnd = _strokeEnd;
	shapeLayer.strokeStart = _strokeStart;
    
    
    //	CGAffineTransform transform = CGAffineTransformMake(1, 1, 0, 0, _boundingSize.width*0.75, _boundingSize.height*0.75);
    //	CGPathRef newPath = CGPathCreateCopyByTransformingPath(_path, &transform);
    
	shapeLayer.path = _path;
    
    //	CGRect enclosure = CGPathGetPathBoundingBox(_path);
    //	NSLog(@"bounding: %f %f %f %f", enclosure.origin.x, enclosure.origin.y, enclosure.size.width, enclosure.size.height);
    
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
	CGContextRef context = CGBitmapContextCreate(NULL, _boundingSize.width, _boundingSize.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    //	CGContextTranslateCTM(context, _boundingSize.width*0.75, _boundingSize.height*0.75);
    
	[shapeLayer renderInContext:context];
    
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
    
    
	SKTexture* tex = [SKTexture textureWithCGImage:imageRef];
    
	CGImageRelease(imageRef);
    
    
	self.texture = tex;
	self.size = _boundingSize;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPath:(CGPathRef) path
////////////////////////////////////////////////////////////////////////////////////////////////
{
	_path = path;
	[self redrawTexture];
}



@end