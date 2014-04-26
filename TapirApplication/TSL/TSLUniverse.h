//
//  TSLWorld.h
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TSLUniverseDelegate.h"

@class TSLConfiguration, TSLEnvironment;

@interface TSLUniverse : NSObject <TSLUniverseDelegate>

// Main properties
@property (nonatomic, strong) TSLEnvironment   *enviroment;
@property (nonatomic, strong) TSLConfiguration *configuration;

// Initialization & creation of universe
- (instancetype) initWithConfiguration:(TSLConfiguration*)configuration;
- (instancetype) initWithConfigurationDict:(NSDictionary*)configuration;

+ (TSLUniverse*) createWithConfiguration:(TSLConfiguration*)configuration;
+ (TSLUniverse*) createWithConfigurationDict:(NSDictionary*)configuration;

// Universe running properties
@property (nonatomic, getter = isPaused) BOOL paused;

// Start of universe
- (void) start;
- (void) bang;

// Control the universe
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) interval;

@property (nonatomic, strong) id<TSLUniverseDelegate> delegate;

@end
