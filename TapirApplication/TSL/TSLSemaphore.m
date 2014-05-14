//
//  TSLSemaphore.m
//  TapirApplication
//
//  Created by Vojtech Micka on 10.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLSemaphore.h"
#import "TSLState.h"
#import "TSLPath.h"
#import "NSString+CharacterEnumeration.h"
#import "TSLUniverse.h"
#import "TSLConfiguration.h"

#import <TGL/TGL.h>

@implementation TSLSemaphore {
    BOOL _cycle[kTSLSemaphorePeriodLength];
    BOOL _current;
}

#pragma mark - Initialization

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        self.state        = [TSLState state];
        self.currentTime  = 0;
        self.pathPosition = 0;
        self.tickLength   = kTSLSemaphoreTickLength;
        
        memset(_cycle, 0, kTSLSemaphorePeriodLength * sizeof(BOOL));
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) semaphore
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLSemaphore alloc] init];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) semaphoreAtPathPosition:(NSUInteger) pathPosition
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLSemaphore *sem = [TSLSemaphore semaphore];
    sem.pathPosition  = pathPosition;
    return sem;
}

#pragma mark - Cycle setting

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setCycleFromArray:(NSArray *) array
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(array.count == kTSLSemaphorePeriodLength, @"Length of given configuration array has to be period length.");
    NSUInteger counter = 0;
    for (NSNumber *state in array) {
        _cycle [counter++] = state.boolValue;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setCycleFromString:(NSString *) string
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self setCycleFromString:string startedAtIndex:0];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setCycleFromString:(NSString *) string startedAtIndex:(NSUInteger) startIndex
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [string enumerateCharacters:^(unichar chars, NSUInteger idx, BOOL *stop) {
        switch (chars) {
            case '0':
                _cycle[startIndex + idx] = NO;
                break;
            case '1':
                _cycle[startIndex + idx] = YES;
                break;
            default:
                ERROR(@"Wrong character!");
                break;
        }
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setCycleOnValue:(BOOL) value inRange:(NSRange) range
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(range.location + range.length < kTSLSemaphorePeriodLength, @"Range goes out of bounds.");
    for (NSUInteger i = 0; i < range.length; i++) {
        _cycle[range.location + i] = value;
    }
}

#pragma mark - TSLObject

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super updateWithTimeSinceLastUpdate:deltaTime];
    
    if (self.isActive == NO) return;
    
    if (self.currentTick % self.tickLength == 0) {
        
        [self.state updateWithTimeSinceLastUpdate:deltaTime];
        
        BOOL last = _current;
        _current = _cycle [self.currentTime];
        
        if (last != _current) {
            [self.state change:_current];
        }

        self.currentTime++;
        self.currentTime %= kTSLSemaphorePeriodLength;
    }
    
    self.currentTick++;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didCreatedAtUniverse:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super didCreatedAtUniverse:universe];
    [self.state didCreatedAtUniverse:universe];
    
    self.tickLength = universe.configuration.semaphoreTickLength;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didDeleted
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [super didDeleted];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) visualize
////////////////////////////////////////////////////////////////////////////////////////////////
{
    SKSpriteNode *spriteNode = [SKSpriteNode spriteNodeWithColor:self.state.color size:CGSizeMake(5, 5)];
    spriteNode.position = [self.path getPositionForPathPosition:self.pathPosition];
    
    [TGLSceneManager registerLayerWithNode:spriteNode andUpdate:^(CFTimeInterval deltaTime, SKNode *node, BOOL *isDead) {
        
        SKSpriteNode *sn = (SKSpriteNode *) node;
        sn.color = self.state.color;
        
    }];
}

@end
