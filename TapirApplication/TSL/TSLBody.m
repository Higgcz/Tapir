//
//  TSLObject.m
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLBody.h"
#import "TSLUniverse.h"

@interface TSLBody ()

@property (nonatomic, strong) NSBezierPath *shape;

- (void) setupSize:(CGSize) size position:(CGPoint) position andZRotation:(CGFloat) zRotation;

@end

static const CGSize  DEFAULTS_SIZE      = {1.0f, 1.0f};
static const CGPoint DEFAULTS_POSITION  = {0.0f, 0.0f};
static const CGFloat DEFAULTS_ZROTATION = 0.0f;

@implementation TSLBody

#pragma mark - Setters & Getters

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setSize:(CGSize) size
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _size = size;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setPosition:(CGPoint) position
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.positionChanged = !CGPointEqualToPoint(_position, position);
    if (self.positionChanged) {
        self.oldPosition = self.position;
    }
    _position = position;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) resetChanges
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.positionChanged  = NO;
}

#pragma mark - Initialization & Creation

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        [self setupSize:DEFAULTS_SIZE position:DEFAULTS_POSITION andZRotation:DEFAULTS_ZROTATION];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithSize:(CGSize) size
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        [self setupSize:size position:DEFAULTS_POSITION andZRotation:DEFAULTS_ZROTATION];
        self.size = size;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TSLBody *) bodyWithSize:(CGSize) size
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLBody alloc] initWithSize:size];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setupSize:(CGSize) size position:(CGPoint) position andZRotation:(CGFloat) zRotation;
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.position  = position;
    self.zRotation = zRotation;
    self.size      = size;
    
    [self resetChanges];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSBezierPath *) getShape
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (self.shape == NULL) {
        switch (self.shapeDef) {
            case TSLBodyShapeRectangle:
                self.shape = [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, self.size.width, self.size.height)];
                break;
            case TSLBodyShapeElipse:
                self.shape = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, self.size.width, self.size.height)];
                break;
            default:
                ERROR(@"No such shape exist!");
                break;
        }
    }
    
    NSRect bounds = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSPoint center = NSMakePoint(NSMidX(bounds), NSMidY(bounds));
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:center.x yBy:center.y];
    [transform rotateByRadians:self.zRotation];
    [transform translateXBy:self.position.x yBy:self.position.y];
    [transform translateXBy:-center.x yBy:-center.y];
    
    return [transform transformBezierPath:self.shape];
}

#pragma mark - TSLCollisionDelegate

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) colidesWith:(TSLBody *) otherBody
////////////////////////////////////////////////////////////////////////////////////////////////
{
    // Forward to delegate
    if (self.delegate != nil) {
        [self.delegate colidesWith:otherBody];
    }

    NSLog(@"Body %@ colides with body %@.", self, otherBody);
}

#pragma mark - NSObject - Description

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *) debugDescription
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSString *desc = [NSString stringWithFormat:@"Name: %@", self.name];
    
    return desc;
}

@end
