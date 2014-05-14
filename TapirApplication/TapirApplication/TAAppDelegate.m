//
//  TAAppDelegate.m
//  TapirApplication
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TAAppDelegate.h"

#import <TGL/TGL.h>
#import "TSimulation.h"
#import "../TSL/TSL.h"

#import "TIndividual.h"
#import "TGeneticAlgorithm.h"

#define SIMULATIONS_COUNT (8)

@interface TAAppDelegate()

@property (nonatomic, strong) NSArray *simulations;
@property (nonatomic, strong) TGLScene *scene;
@property (nonatomic, strong) TGeneticAlgorithm *algorithm;

- (void) prepareSimulations;
- (void) runEvolutionAlgorithm;
- (void) createAndDisplaySimulation:(TSimulation *) simulation;

@end

@implementation TAAppDelegate

@synthesize window = _window;

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) applicationDidFinishLaunching:(NSNotification *) aNotification
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self prepareSimulations];
    
    TSimulation *simulation = self.simulations[0];
    
    BOOL shouldUseEvolution = simulation.universe.configuration.shouldUseEvolution;
    
    if (shouldUseEvolution) {
        [self runEvolutionAlgorithm];
    }
    
    [TGLSceneManager flush];
    
    NSLog(@"Done - showing the best.");
    
    [self createAndDisplaySimulation:simulation];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) prepareSimulations
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSMutableArray *simulations = [NSMutableArray arrayWithCapacity:SIMULATIONS_COUNT];
    
    for (int i = 0; i < SIMULATIONS_COUNT; i++) {
        TSimulation *sim = [TSimulation simulation];
        [sim buildSimulationWithDefaultConfigFile];
        [sim prepareCars];
        [simulations addObject:sim];
    }
    
    self.simulations = simulations;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) runEvolutionAlgorithm
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.algorithm = [TGeneticAlgorithm algorithmWithSimulations:self.simulations];
    [self.algorithm execute];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) createAndDisplaySimulation:(TSimulation *) simulation
////////////////////////////////////////////////////////////////////////////////////////////////
{
    BOOL shouldUseEvolution = simulation.universe.configuration.shouldUseEvolution;
    
    if (shouldUseEvolution) {
        [self.algorithm writeToFile];
        [simulation calculateCarsFitness];
        [simulation configurateSemaphoresWithArray:self.algorithm.bestIndividual.cycles];
    } else {
        [simulation configurateSemaphoresFromConfiguration];
    }
    
    // Create universe and scene
    self.scene = [[TGLSceneManager sharedInstance] createSceneWithSize:simulation.universe.configuration.worldSize];
    
    // Reset simulation
    [simulation resetSimulation];
    
    // Run simulation in scene
    [simulation runSimulationInScene:self.scene];
    
    /* Set the scale mode to scale to fit the window */
    self.scene.scaleMode = SKSceneScaleModeAspectFit;
    
    [self.skView presentScene:self.scene];
    
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *) sender
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return YES;
}

@end
