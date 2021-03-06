//
//  TSLObject.m
//  TapirApplication
//
//  Created by Vojtech Micka on 07.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLObject.h"
#import "TSLUniverse.h"

@implementation TSLObject

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        self.active   = NO;
        self.universe = nil;
        self.ready    = NO;
        [self reset];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setUniverse:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _universe = universe;
}

#pragma mark - Updating

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) reset
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.dead     = NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (self.isActive == NO) return;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) removeFromUniverse
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.universe removeObject:self];
}

#pragma mark - Callbacks

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didCreatedAtUniverse:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.universe = universe;
    self.active   = YES;
    self.ready    = YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didDeleted
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.dead = YES;
    self.universe = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) visualize
////////////////////////////////////////////////////////////////////////////////////////////////
{

}

@end
