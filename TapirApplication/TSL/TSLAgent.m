//
//  TSLAgent.m
//  TapirApplication
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLAgent.h"

@implementation TSLAgent

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithBodySize:(CGSize) size
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super initWithBodySize:(CGSize) size];
    if (self) {
        [self setup];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setup
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.body.delegate = self;
    self.active        = YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////
-(void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if ( self.isActive == NO ) return;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) colidesWith:(TSLBody *) otherBody
////////////////////////////////////////////////////////////////////////////////////////////////
{
    
}

@end