//
//  TAAppDelegate.m
//  TapirApplication
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TAAppDelegate.h"
#import "TAMyScene.h"

@implementation TAAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /* Pick a size for the scene */
    SKScene *scene = [TAMyScene sceneWithSize:CGSizeMake(1024, 768)];

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
