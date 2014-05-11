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

- (void) prepareCars;
- (void) createCars;
- (void) removeAllCars;

- (void) runSimulationWithCompletion:(void(^)(NSUInteger simulationSteps)) completion;
- (void) runSimulationInScene:(TGLScene *) scene;

@end