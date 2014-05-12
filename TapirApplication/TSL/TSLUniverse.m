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
#import "TSLCar.h"

#import <TGL/TGL.h>

@interface TSLUniverse ()

- (void) setup;
- (BOOL) shouldDie;

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;    // The previous update: loop time interval

@end

@implementation TSLUniverse {
    BOOL _start;
}

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
    self.living = YES;
    _start = NO;
    
    // Setting self as delegate
    self.delegate = self;
    
    self.numberOfCars  = 0;
    self.numberOfSteps = 0;
    
    // Set configuration
    self.storage = [NSMutableArray array];
    
    SKLabelNode *node = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Neue"];
    node.text = [NSString stringWithFormat:@"Num of steps: %lu, Num of cars: %lu", self.numberOfSteps, self.numberOfCars];
    node.fontSize = 16.0f;
    node.position = CGPointMake(5 + node.frame.size.width / 2.0f, 5);
    
    [TGLSceneManager registerLayerWithNode:node andUpdate:^(CFTimeInterval deltaTime, SKNode *node, BOOL *isDead) {
        SKLabelNode *labelNode = (SKLabelNode *) node;
        labelNode.text = [NSString stringWithFormat:@"Num of steps: %lu, Num of cars: %lu", self.numberOfSteps, self.numberOfCars];
        node.position = CGPointMake(5 + node.frame.size.width / 2.0f, 5);
    }];
    
    // Set the Physics core
//    self.physicsCore = [[TSLPhysicsCore alloc] initWithGridSize:self.configuration.worldSize andCount:3];
}

#pragma mark - Objects handling

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addObject:(TSLObject *) anObject
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.storage addObject:anObject];
    
    if ([anObject isKindOfClass:[TSLCar class]]) {
        self.numberOfCars++;
    }
    
    [anObject didCreatedAtUniverse:self];
//    [anObject performSelector:@selector(didCreatedAtUniverse:) withObject:self afterDelay:0.0f];
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
    
    if ([anObject isKindOfClass:[TSLCar class]]) {
        self.numberOfCars--;
    }
    
    [anObject didDeleted];
//    [anObject performSelector:@selector(didDeleted) withObject:nil afterDelay:0.0f];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) removeAllObjects
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.storage enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[TSLObject class]]) {
//            NSLog(@"WARNING: There is wrong type of object in storage!");
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
    while (self.isLiving) {
        @autoreleasepool {
            [self update:[NSDate timeIntervalSinceReferenceDate]];
        }
    }
//    [self performSelector:@selector(start) withObject:nil afterDelay:0.0f];
//    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
//        [self start];
//    }];
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

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) resetUniverse
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self.delegate willUniverseReset:self];
    
    NSArray *tmp = [NSArray arrayWithArray:self.storage];
    for (TSLObject *obj in tmp) {
        [obj reset];
    }
    
    self.living        = YES;
    self.numberOfSteps = 0;
    self.numberOfCars  = 0;
}

#pragma mark - TGLSceneUpdateDelegate - delegation method

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) resetScene
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self resetUniverse];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if ([self isLiving] == NO) return;
    
    NSArray *tmp = [NSArray arrayWithArray:self.storage];
    
    NSAssert(tmp != nil, @"Universe storage NIL!!?");
    
    for (TSLObject *obj in tmp) {
        if (!obj.isReady) continue;
        [obj updateWithTimeSinceLastUpdate:deltaTime];
    }
    
    if (self.numberOfSteps >= self.configuration.totalNumberOfSteps || [self.delegate shouldDie:self] || [self shouldDie]) {
        self.living = NO;
        [self.delegate didUniverseDie:self];
    }
    
    self.numberOfSteps++;
    [self.delegate didEvaluateUpdate:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) shouldDie
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (self.numberOfCars != 0 && _start) return NO;
    
    if (_start == NO && self.numberOfCars != 0) {
        _start = YES;
    } else if (_start && self.numberOfCars == 0) {
        return YES;
    }
    
    return NO;
}

#pragma mark - TSLUniverseDelegate - delegation methods

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) willUniverseReset:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) shouldDie:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didUniverseDie:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didEvaluateUpdate:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didSimulatePhysics:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{}

@end