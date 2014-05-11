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

@interface TAAppDelegate()

@property (nonatomic, strong) NSArray *simulations;

@end

@implementation TAAppDelegate

@synthesize window = _window;

- (void) applicationDidFinishLaunching:(NSNotification *) aNotification
{
    NSMutableArray *simulations = [NSMutableArray new];
    
    
    
    for (int i = 0; i < 7; i++) {
        TSimulation *simulation = [TSimulation simulation];
        [simulation buildSimulationWithDefaultConfigFile];
        [simulations addObject:simulation];
    }

    [simulations enumerateObjectsUsingBlock:^(TSimulation *sim, NSUInteger idx, BOOL *stop) {
        [sim prepareCars];
        [sim runSimulationWithCompletion:^(NSUInteger simulationSteps) {
            NSLog(@"Simulation: %lu, Total steps %lu", idx, simulationSteps);
        }];
    }];
    
//    for (TSimulation *sim in simulations) {
//        
//        
//        [sim runSimulationWithCompletion:^(NSUInteger simulationSteps) {
//            NSLog(@"Simulation: %d, Total steps %lu", i, simulationSteps);
//        }];
//    }
    
    // Create universe and scene
//    TGLScene *scene = [[TGLSceneManager sharedInstance] createSceneWithSize:self.simulation.universe.configuration.worldSize];
//    
//    [self.simulation runSimulationInScene:scene];
    
    /* Set the scale mode to scale to fit the window */
//    scene.scaleMode = SKSceneScaleModeAspectFit;
//
//    [self.skView presentScene:scene];
//
//    self.skView.showsFPS = YES;
//    self.skView.showsNodeCount = YES;
    
}



- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *) sender
{
    return YES;
}

@end
