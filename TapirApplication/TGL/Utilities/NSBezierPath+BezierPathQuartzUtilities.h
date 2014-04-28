//
//  NSBezierPath+BezierPathQuartzUtilities.h
//  TapirApplication
//
//  Created by Apple Inc.
//  UTL: https://developer.apple.com/library/mac/documentation/cocoa/Conceptual/CocoaDrawingGuide/Paths/Paths.html#//apple_ref/doc/uid/TP40003290-CH206-SW2
//  Copyright (c) 2005, 2012 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (BezierPathQuartzUtilities)

- (CGPathRef) quartzPath;

@end
