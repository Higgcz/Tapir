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

@class TSLEntity;

@interface TSLBody : NSObject

// Reference to entity
@property (nonatomic, weak) TSLEntity *entity;

// Dynamic properties
@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat zRotation;

@property (nonatomic) BOOL positionChanged;
@property (nonatomic) BOOL zRotationChanged;

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
@property (nonatomic, strong) NSBezierPath *shape;
@property (nonatomic, getter = isDynamic) BOOL dynamic;

// Bit masks properties
@property (nonatomic) TBitMask categoryBitMask;
@property (nonatomic) TBitMask collisionBitMask;
@property (nonatomic) TBitMask contactTestBitMask;

- (void) colidesWith:(TSLBody *) otherBody;

@end
