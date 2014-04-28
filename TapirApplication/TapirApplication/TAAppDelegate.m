//
//  TAAppDelegate.m
//  TapirApplication
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TAAppDelegate.h"
#import "TAMyScene.h"

#import "TGL.h"

#import "TSLUniverse.h"
#import "../TSL/TSLCarAgent.h"

@interface TAAppDelegate ()

@property (nonatomic, strong) TSLUniverse *theUniverse;

@end

@implementation TAAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Create universe and scene
    self.theUniverse = [TSLUniverse universe];
    /* Pick a size for the scene */
    //    SKScene *scene = [TAMyScene sceneWithSize:CGSizeMake(1024, 768)];
    TGLScene *scene = [[TGLSceneManager sharedInstance] createSceneWithSize:CGSizeMake(1024, 768)];
    scene.updateDelegate = self.theUniverse;
    
    TSLCarAgent *carAgent = [[TSLCarAgent alloc] initWithBodySize:CGSizeMake(40, 20)];
    
    carAgent.body.position = CGPointMake (200, 200);
    carAgent.body.zRotation = M_PI / 2;
    [carAgent setup];
    
//    carAgent.gas = 0.1;
    carAgent.desiredVelocity = 50;
    
    srand((unsigned int) time(NULL));
    [carAgent driveToPoint:CGPointMake(400, 400) onCompletition:^(CGPoint *point) {
        *point = CGPointMake(750 + rand() % 400 - 200, 380 + rand() % 400 - 200);
    }];
    
    // Add object to the Universe
    [self.theUniverse addObject:carAgent];
    
    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
