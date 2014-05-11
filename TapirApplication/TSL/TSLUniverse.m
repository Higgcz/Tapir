//
//  TSLWorld.m
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLUniverse.h"

#import "TSLPhysicsCore.h"
#import "TSLConfiguration.h"
#import "TSLEntity.h"

@interface TSLUniverse ()

- (void) setup;

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;    // The previous update: loop time interval

@end

@implementation TSLUniverse

#pragma mark - Initialization & Creation

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithConfiguration:(TSLConfiguration *) configuration
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        self.configuration = configuration;
        [self setup];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithConfigurationDict:(NSDictionary *) configuration
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        self.configuration = [TSLConfiguration configurationWithConfigurationDict:configuration];
        [self setup];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TSLUniverse *) universe////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLUniverse alloc] initWithConfiguration:[TSLConfiguration configuration]];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TSLUniverse *) universeWithConfiguration:(TSLConfiguration *) configuration
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLUniverse alloc] initWithConfiguration:configuration];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TSLUniverse *) universeWithConfigurationDict:(NSDictionary *) configuration
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLUniverse alloc] initWithConfigurationDict:configuration];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setup
//////////////////////////////////////////////////////////////////////////////////////////////////
{
    // Setting self as delegate
    self.delegate = self;
    
    // Set configuration
    self.storage = [NSMutableArray array];
    
    // Set the Physics core
    self.physicsCore = [[TSLPhysicsCore alloc] initWithGridSize:self.configuration.worldSize andCount:3];
}

#pragma mark - Objects handling

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addObject:(TSLObject *) anObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.storage addObject:anObject];
    
//    [anObject didCreatedAtUniverse:self];
    [anObject performSelector:@selector(didCreatedAtUniverse:) withObject:self afterDelay:0.0f];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addObjects:(NSArray *) objectsArray
////////////////////////////////////////////////////////////////////////////////////////////////
{
    for (TSLObject *obj in objectsArray) {
        [self addObject:obj];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) removeObject:(TSLObject *) anObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.storage removeObject:anObject];
    
    [anObject performSelector:@selector(didDeleted) withObject:nil afterDelay:0.0f];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) removeAllObjects
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.storage enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[TSLObject class]]) {
            NSLog(@"WARNING: There is wrong type of object in storage!");
            return;
        }
        
        TSLObject *object = (TSLObject *) obj;
        
        [object didDeleted];
    }];
    
    [self.storage removeAllObjects];
}

#pragma mark - Updating

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) start
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (!self.isLiving) return;
    
    [self update:[NSDate timeIntervalSinceReferenceDate]];
    
    [self performSelector:@selector(start) withObject:nil afterDelay:0.0f];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) bang
////////////////////////////////////////////////////////////////////////////////////////////////
{
    // Just an ester-egg
    [self start];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) update:(NSTimeInterval) currentTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    CFTimeInterval deltaTime = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (deltaTime > 1) { // More than a second since last update
        deltaTime = kMinTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
    }
    [self updateWithTimeSinceLastUpdate:deltaTime];
}

#pragma mark - TGLSceneUpdateDelegate - delegation method

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSArray *tmp = [NSArray arrayWithArray:self.storage];
    
    NSAssert(tmp != nil, @"Universe storage NIL!!?");
    
    for (TSLObject *obj in tmp) {
        if (!obj.isReady) continue;
        [obj updateWithTimeSinceLastUpdate:deltaTime];
    }
    
    [self.delegate didEvaluateUpdate];
}

#pragma mark - TSLUniverseDelegate - delegation methods

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didEvaluateUpdate
////////////////////////////////////////////////////////////////////////////////////////////////
{}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didSimulatePhysics
////////////////////////////////////////////////////////////////////////////////////////////////
{}

@end