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

@interface TAAppDelegate()

@property (nonatomic, strong) NSArray *simulations;
@property (nonatomic, strong) TSimulation *simulation;

@end

@implementation TAAppDelegate

@synthesize window = _window;

- (void) applicationDidFinishLaunching:(NSNotification *) aNotification
{
//    TGeneticAlgorithm *algorithm = [TGeneticAlgorithm new];
//    
//    [algorithm execute];
//    
//    [TGLSceneManager flush];
//    NSLog(@"Done");
    
    self.simulation = [TSimulation simulation];
    [self.simulation buildSimulationWithDefaultConfigFile];
//    [self.simulation configurateSemaphoresWithArray:algorithm.bestIndividual.cycles];
    [self.simulation prepareCars];

    // Create universe and scene
    TGLScene *scene = [[TGLSceneManager sharedInstance] createSceneWithSize:self.simulation.universe.configuration.worldSize];
    
    [self.simulation runSimulationInScene:scene];
    
    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *) sender
{
    return YES;
}

@end
