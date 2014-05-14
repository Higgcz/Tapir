//
//  TSimulation.h
//  TapirApplication
//
//  Created by Vojtech Micka on 11.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSL.h"

@class TGLScene;

@interface TSimulation : NSObject <TSLUniverseDelegate>

@property (nonatomic, strong) TSLUniverse *universe;
@property (nonatomic, strong) NSArray *semaphores;
@property (nonatomic, strong) NSArray *zones;
@property (nonatomic, strong) NSArray *cars;

@property (nonatomic, readonly, getter = isReady) BOOL ready;

@property (nonatomic, strong) NSOperationQueue *simulationQueue;

+ (instancetype) simulation;

- (void) buildSimulationWithConfigFile:(NSString *) fileName;
- (void) buildSimulationWithDefaultConfigFile;

- (void) configurateSemaphoresWithArray:(NSArray *) semaphoreConfig;
- (void) configurateSemaphoresFromConfiguration;

- (void) prepareCars;
- (void) createCars;
- (void) removeAllCars;

- (void) resetSimulation;

- (CGFloat) calculateCarsFitness;

- (void) runSimulationWithCompletion:(void (^)(NSUInteger simulationSteps, NSUInteger stayingCars)) completion;
- (void) runSimulationInScene:(TGLScene *) scene;

@end
