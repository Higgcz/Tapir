//
//  TSLEnvironment.h
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLUniverse;

@interface TSLEnvironment : NSObject

// Main properties
@property (nonatomic, weak) TSLUniverse *universe;

// Initialization & creation of Environment
- (instancetype) initInUniverse:(TSLUniverse *) universe;

+ (TSLEnvironment *) createInUniverse:(TSLUniverse *) universe;

// Storages
@property (nonatomic, strong, readonly) NSMutableArray *dynamicObjectStorage;
@property (nonatomic, strong, readonly) NSMutableArray *staticObjectStorage;
@property (nonatomic, strong, readonly) NSMutableArray *abstractObjectStorage;

// Updating the Environment
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) interval;

@end
