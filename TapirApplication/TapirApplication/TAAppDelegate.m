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
#import "../TSL/TSLSemaphore.h"
#import "../TSL/TSLConfiguration.h"

#import "../TSL/Vectors.h"

static NSString *kConfigurationFileName = @"Configuration";

@interface TAAppDelegate ()

@property (nonatomic, strong) TSLUniverse *theUniverse;


@end

@implementation TAAppDelegate

@synthesize window = _window;

- (void) applicationDidFinishLaunching:(NSNotification *) aNotification
{
    // Create configureation
    TSLConfiguration *conf = [TSLConfiguration configurationFromFileNamed:kConfigurationFileName];
    
    // Create universe and scene
    TGLScene *scene = [[TGLSceneManager sharedInstance] createSceneWithSize:conf.worldSize];
    
    self.theUniverse = [TSLUniverse universeWithConfiguration:conf];
    
    srand((unsigned) (conf.randomSeed == 0 ? (NSUInteger) time(NULL) : conf.randomSeed));
    
    /* Pick a size for the scene */
    //    SKScene *scene = [TAMyScene sceneWithSize:CGSizeMake(1024, 768)];
    
    NSInteger widthInt = scene.size.width;
    NSInteger heightInt = scene.size.height;
    
    NSPoint centerA = NSMakePoint((NSInteger) widthInt/3, (NSInteger) heightInt/3);
    NSPoint centerB = NSMakePoint(centerA.x * 2, centerA.y);
    NSPoint centerC = NSMakePoint(centerA.x * 2, centerA.y * 2);
    NSPoint centerD = NSMakePoint(centerA.x, centerA.y * 2);
    
    NSUInteger roadLength = conf.roadLength;
    
    TSLIntersection *intersectionA = [TSLIntersection intersectionAtPoint:centerA andRadius:20];
    TSLIntersection *intersectionB = [TSLIntersection intersectionAtPoint:centerB andRadius:20];
    TSLIntersection *intersectionC = [TSLIntersection intersectionAtPoint:centerC andRadius:20];
    TSLIntersection *intersectionD = [TSLIntersection intersectionAtPoint:centerD andRadius:20];
    
    NSMutableArray *zones      = [NSMutableArray array];
    NSMutableArray *roads      = [NSMutableArray array];
    NSMutableArray *semaphores = [NSMutableArray array];
    
    NSArray *intersections = @[intersectionA, intersectionB, intersectionC, intersectionD];
    
    NSUInteger numberOfLines = conf.numberOfLines;
    
    // Add road between intersections
    for (int i = 0; i < intersections.count; i++) {
        TSLRoadObject *roA = intersections[i];
        TSLRoadObject *roB = intersections[(i + 1 < intersections.count) ? i + 1 : 0];
        
        TSLRoad *newRoad = [TSLRoad roadBetweenRoadObjectA:roA andRoadObjectB:roB];
        
        newRoad.lineCountNegativeDir = numberOfLines;
        newRoad.lineCountPositiveDir = numberOfLines;
        
        [roads addObject:newRoad];
    }
    
    // Add zones and road between zones and intersections
    for (TSLIntersection *inter in intersections) {
        NSUInteger count = inter.count;
        
        for (int i = 0; i < count; i++) {
            TSLRoad *road = inter.roads[i];
            
            eTSLRoadDirection dir = [road getDirectionFromRoadObject:inter];
            NSVector direction = !dir ? road.direction : NSVectorOpossite(road.direction);
            
            NSPoint zPoint = NSVectorAdd(inter.position, NSVectorResize(direction, roadLength));
            
            TSLZone *newZone = [TSLZone zoneAtPosition:zPoint];
            TSLRoad *newRoad = [TSLRoad roadBetweenRoadObjectA:inter andRoadObjectB:newZone];
            
            newRoad.lineCountNegativeDir = numberOfLines;
            newRoad.lineCountPositiveDir = numberOfLines;
            
            [zones addObject:newZone];
            [roads addObject:newRoad];
        }
    }
    
    // Constants
    CGFloat angleStraightTolerance = conf.angleStraightTolerance;
    
    // Add semaphores
    for (TSLIntersection *inter in intersections) {
        NSUInteger count = inter.count;
        
        for (int i = 0; i < count; i++) {
            TSLRoad *road = inter.roads[i];
            
            eTSLRoadDirection roadDirection = [road getDirectionToRoadObject:inter];
            NSUInteger lineCount = [road lineCountInDirection:roadDirection];
            
            for (int n = 0; n < lineCount; n++) {
                TSLSemaphore *newSemaphore = [road createSemaphoreAtLine:n inDirection:roadDirection];
                
                if (i&1) {
                    [newSemaphore setCycleOnValue:YES inRange:NSMakeRange(0, 8)];
                } else {
                    [newSemaphore setCycleOnValue:YES inRange:NSMakeRange(11, 8)];
                }
                
                [semaphores addObject:newSemaphore];
                
            }
            
            NSVector roadVecDir = [road directionInDirection:roadDirection];
            
            for (int j = 0; j < count; j++) {
                if (i == j) continue;
                
                TSLRoad *jRoad = inter.roads[j];
                
                eTSLRoadDirection jRoadDir = [jRoad getDirectionFromRoadObject:inter];
                
                NSVector jRoadVecDir = [jRoad directionInDirection:jRoadDir];
                
                CGFloat angle = NSVectorsAngle(roadVecDir, jRoadVecDir);
                
                if (fabs(angle) < angleStraightTolerance) {
                    // Straight
                    [inter createPathFromRoad:road fromToLine:MIN(1, lineCount - 1) toRoad:jRoad];
                } else if (angle < 0) {
                    // Right
                    [inter createPathFromRoad:road fromToLine:(lineCount - 1) toRoad:jRoad];
                } else {
                    // Left
                    [inter createPathFromRoad:road fromToLine:0 toRoad:jRoad];
                }
            }
        }
    }


    
    for (int i = 0; i < conf.totalNumberOfAgents; i++) {
        TSLDriverAgent *driverAgent = [[TSLDriverAgent alloc] init];
        TSLCar *car = [TSLCar carWithType:[self getRandomCarType]];
        // Set driver's car
        driverAgent.car = car;
        
        TSLZone *zoneA = zones[rand()%zones.count];
        TSLZone *zoneB;
        
        do {
            zoneB = zones[rand()%zones.count];
        } while (zoneB == zoneA);

        
        [driverAgent.plan searchPathFromZone:zoneA toZone:zoneB];
        [zoneA.cars addObject:car];
    }
    
    // Add object to the Universe
    [self.theUniverse addObjects:zones];
    [self.theUniverse addObjects:intersections];
    [self.theUniverse addObjects:roads];
    [self.theUniverse addObjects:semaphores];
    
    scene.updateDelegate = self.theUniverse;
    
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
    
    NSInteger cP = _theUniverse.configuration.probCarTypePassenger;
    NSInteger cT = _theUniverse.configuration.probCarTypeTruck;
    NSInteger cB = _theUniverse.configuration.probCarTypeBus;
    
    NSInteger sumC = cP + cT + cB;
    
    NSInteger pP = 100 * ((CGFloat) cP / sumC);
    NSInteger pT = 100 * ((CGFloat) cT / sumC);
    
    if (n < pP) {
        return TSLCarTypePassenger;
    } else if (n < pT) {
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
