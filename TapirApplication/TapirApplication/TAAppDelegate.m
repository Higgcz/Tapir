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
#import "../TSL/TSLDriverAgent.h"
#import "../TSL/TSLCar.h"
#import "../TSL/TSLRoad.h"
#import "../TSL/TSLZone.h"
#import "../TSL/TSLIntersection.h"
#import "../TSL/TSLPlan.h"
#import "../TSL/TSLPath.h"

@interface TAAppDelegate ()

@property (nonatomic, strong) TSLUniverse *theUniverse;

@end

@implementation TAAppDelegate

@synthesize window = _window;

- (void) applicationDidFinishLaunching:(NSNotification *) aNotification
{
    // Create universe and scene
    TGLScene *scene = [[TGLSceneManager sharedInstance] createSceneWithSize:CGSizeMake(1024, 768)];
    
    self.theUniverse = [TSLUniverse universe];
    
    srand(time(NULL));
    
    /* Pick a size for the scene */
    //    SKScene *scene = [TAMyScene sceneWithSize:CGSizeMake(1024, 768)];
    scene.updateDelegate = self.theUniverse;
    
    NSInteger widthInt = scene.size.width;
    NSInteger heightInt = scene.size.height;
    
    NSPoint center = NSMakePoint((NSInteger) widthInt/2, (NSInteger) heightInt/2);
    
    TSLZone *zoneA = [TSLZone zoneAtPosition:NSMakePoint(center.x - 200, center.y)];
    TSLZone *zoneB = [TSLZone zoneAtPosition:NSMakePoint(center.x, center.y - 200)];
    TSLZone *zoneC = [TSLZone zoneAtPosition:NSMakePoint(center.x + 200, center.y)];
    TSLZone *zoneD = [TSLZone zoneAtPosition:NSMakePoint(center.x, center.y + 200)];
    
    TSLIntersection *intersection = [TSLIntersection intersectionAtPoint:center andRadius:20];
    
    TSLRoad *roadA = [TSLRoad roadBetweenRoadObjectA:zoneA andRoadObjectB:intersection];
    TSLRoad *roadB = [TSLRoad roadBetweenRoadObjectA:intersection andRoadObjectB:zoneB];
    TSLRoad *roadC = [TSLRoad roadBetweenRoadObjectA:intersection andRoadObjectB:zoneC];
    TSLRoad *roadD = [TSLRoad roadBetweenRoadObjectA:intersection andRoadObjectB:zoneD];
    
//    [intersection createPathFromRoad:roadA fromToLine:0 toRoad:roadB];
    [intersection createPathFromRoad:roadA fromToLine:0 toRoad:roadC];
    [intersection createPathFromRoad:roadD fromToLine:0 toRoad:roadB];
    
//    roadA.lineCountPositiveDir = 2;
//    roadA.lineCountNegativeDir = 2;
    
//    roadA.prev = zoneA;
//    roadA.next = zoneB;
    
    for (int i = 0; i < 20; i++) {
        TSLDriverAgent *driverAgent = [[TSLDriverAgent alloc] init];
        TSLCar *car = [TSLCar carWithType:[self getRandomCarType]];
        // Set driver's car
        driverAgent.car = car;
        
        if (rand()&1) {
            [driverAgent.plan addRoad:roadD];
            [driverAgent.plan addRoad:roadB];
            [zoneD.cars addObject:car];
        } else {
            [driverAgent.plan addRoad:roadA];
            [driverAgent.plan addRoad:roadC];
            [zoneA.cars addObject:car];
        }
    }
    
//    TSLCar *testCar = [TSLCar carWithType:TSLCarTypePassenger];
//    TSLPath *pathAC = [intersection pathFromRoad:roadA toRoad:roadC];
//    testCar.pathPositionMomentum = 10;
//    [pathAC putCar:testCar];
//    [self.theUniverse addObject:testCar];
    
    // Add object to the Universe
    [self.theUniverse addObject:zoneA];
    [self.theUniverse addObject:zoneB];
    [self.theUniverse addObject:zoneC];
    [self.theUniverse addObject:zoneD];
    [self.theUniverse addObject:intersection];
    [self.theUniverse addObject:roadA];
    [self.theUniverse addObject:roadB];
    [self.theUniverse addObject:roadC];
    [self.theUniverse addObject:roadD];
    
    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];

    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
    
}

- (eTSLCarType) getRandomCarType
{
    NSInteger n = rand() % 100;
    
    NSLog(@"Type: %ld", n);
    
    if (n < 70) {
        return TSLCarTypePassenger;
    } else if (n < 90) {
        return TSLCarTypeTruck;
    } else {
        return TSLCarTypeBus;
    }
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *) sender
{
    return YES;
}

@end
