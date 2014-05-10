//
//  TSLObject.h
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLBodyConstants.h"
#import "TSLColisionDelegate.h"

typedef NS_ENUM(NSUInteger, TSLBodyShape) {
    TSLBodyShapeRectangle = 0,
    TSLBodyShapeElipse
};

@class TSLCar;

@interface TSLBody : NSObject

// Reference to entity
@property (nonatomic, weak) TSLCar *car;

// Dynamic properties
@property (nonatomic) NSPoint position;
@property (nonatomic) CGFloat zRotation;

@property (nonatomic) NSPoint oldPosition;

@property (nonatomic) BOOL positionChanged;

- (void) resetChanges;

// Static properties
@property (nonatomic, strong  ) NSString *name;
@property (nonatomic, readonly) CGSize   size;

// Initialization
- (instancetype) initWithSize:(CGSize) size;
+ (TSLBody *) bodyWithSize:(CGSize) size;

// --------------------
// -- PHYSICS BODY ----
// --------------------

@property (nonatomic, weak) id<TSLColisionDelegate> delegate;

// Collision properties
@property (nonatomic) TSLBodyShape shapeDef;
@property (nonatomic, getter = isDynamic) BOOL dynamic;

- (NSBezierPath *) getShape;

// Bit masks properties
@property (nonatomic) TBitMask categoryBitMask;
@property (nonatomic) TBitMask collisionBitMask;
@property (nonatomic) TBitMask contactTestBitMask;

- (void) colidesWith:(TSLBody *) otherBody;

@end
