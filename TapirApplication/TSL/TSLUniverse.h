//
//  TSLWorld.h
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <TGL/TGLSceneUpdateDelegate.h>
#import "TSLUniverseDelegate.h"

#define kMinTimeInterval (1.0f / 60.0f)

@class TSLConfiguration, TSLEntity, TSLObject, TSLPhysicsCore;

@interface TSLUniverse : NSObject <TSLUniverseDelegate, TGLSceneUpdateDelegate>

// Main properties
@property (atomic, strong) NSMutableArray   *storage;
@property (nonatomic, strong) TSLConfiguration *configuration;
@property (nonatomic, strong) TSLPhysicsCore   *physicsCore;

// Initialization & creation of universe
- (instancetype) initWithConfiguration:(TSLConfiguration *) configuration;
- (instancetype) initWithConfigurationDict:(NSDictionary *) configuration;

+ (TSLUniverse *) universe;
+ (TSLUniverse *) universeWithConfiguration:(TSLConfiguration *) configuration;
+ (TSLUniverse *) universeWithConfigurationDict:(NSDictionary *) configuration;

@property (nonatomic) NSUInteger numberOfCars;
@property (nonatomic) NSUInteger numberOfSteps;

// Universe running properties
@property (nonatomic, getter = isLiving) BOOL living;

// Start of universe
- (void) start; // how to start with graphical output ?
- (void) bang;

// Objects handling
- (void) addObject:(TSLObject *) anObject;
- (void) addObjects:(NSArray *) objectsArray;
- (void) removeObject:(TSLObject *) anObject;
- (void) removeAllObjects;

// Control the universe
- (void) update:(NSTimeInterval) currentTime;

@property (nonatomic, weak) id<TSLUniverseDelegate> delegate;

@end
