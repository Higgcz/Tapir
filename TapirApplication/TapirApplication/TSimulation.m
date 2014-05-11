//
//  TSimulation.m
//  TapirApplication
//
//  Created by Vojtech Micka on 11.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSimulation.h"

#import <TGL/TGL.h>

static NSString * kConfigurationFileName = @"Configuration";

@interface TSimulation ()

- (eTSLCarType) getRandomCarType;

@end

@implementation TSimulation {
    BOOL _builded;
    BOOL _carsAdded;
    BOOL _carsRemoved;
    BOOL _finished;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        _builded     = NO;
        _carsAdded   = NO;
        _carsRemoved = YES;
        _finished    = NO;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) simulation
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [TSimulation new];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) buildSimulationWithDefaultConfigFile
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self buildSimulationWithConfigFile:kConfigurationFileName];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) buildSimulationWithConfigFile:(NSString *) fileName
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _builded = YES;
    
    // Create configureation
    TSLConfiguration *conf = [TSLConfiguration configurationFromFileNamed:fileName];
    
    self.universe = [TSLUniverse universeWithConfiguration:conf];
    self.universe.delegate = self;
    
    srand((unsigned) (conf.randomSeed == 0 ? (NSUInteger) time(NULL) : conf.randomSeed));
    
    NSInteger widthInt  = conf.worldSize.width;
    NSInteger heightInt = conf.worldSize.height;
    
    NSPoint centerA = NSMakePoint((NSInteger) widthInt / 3, (NSInteger) heightInt / 3);
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

    // Save usefull objects for easy
    self.semaphores = [NSArray arrayWithArray:semaphores];
    self.zones      = [NSArray arrayWithArray:zones];
    
    // Add object to the Universe
    [self.universe addObjects:zones];
    [self.universe addObjects:intersections];
    [self.universe addObjects:roads];
    [self.universe addObjects:semaphores];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) prepareCars
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (_carsAdded == YES) {
        [self removeAllCars];
    }
    [self createCars];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) createCars
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(_carsRemoved == YES, @"Cars have to be free for creating new.");
    _carsAdded = YES;
    _carsRemoved = NO;
    
    NSMutableArray *cars = [NSMutableArray array];
    
    for (int i = 0; i < self.universe.configuration.totalNumberOfAgents; i++) {
        TSLDriverAgent *driverAgent = [[TSLDriverAgent alloc] init];
        TSLCar *car = [TSLCar carWithType:[self getRandomCarType]];
        
        // Add car object
        [cars addObject:car];
        
        // Set driver's car
        driverAgent.car = car;
        
        TSLZone *zoneA = _zones[rand() % [_zones count]];
        TSLZone *zoneB;
        
        do {
            zoneB = _zones[rand() % [_zones count]];
        } while (zoneB == zoneA);
        
        
        [driverAgent.plan searchPathFromZone:zoneA toZone:zoneB];
        [zoneA.cars addObject:car];
    }
    
    self.cars = [NSArray arrayWithArray:cars];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (eTSLCarType) getRandomCarType
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSInteger n = rand() % 100;
    
//    NSLog(@"Type: %ld", n);
    
    NSInteger cP = self.universe.configuration.probCarTypePassenger;
    NSInteger cT = self.universe.configuration.probCarTypeTruck;
    NSInteger cB = self.universe.configuration.probCarTypeBus;
    
    NSInteger sumC = cP + cT + cB;
    
    NSInteger pP = 100 * ((CGFloat) cP / sumC);
    NSInteger pT = 100 * ((CGFloat) cT / sumC);
    
    if (n < pP) {
        return TSLCarTypePassenger;
    } else if (n < pP + pT) {
        return TSLCarTypeTruck;
    } else {
        return TSLCarTypeBus;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) removeAllCars
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSAssert(_carsAdded == YES, @"Cars first have to be added to be removed.");
    _carsRemoved = YES;
    _carsAdded = NO;
    
    for (TSLCar *car in self.cars) {
        if (car.isDead) continue;
        [car removeFromUniverse];
    }
    
    self.cars = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isReady
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return _builded && (_carsAdded || (_carsRemoved && _finished));
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) runSimulationWithCompletion:(void (^)(NSUInteger)) completion
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if ([self isReady] == NO) return;
    
    self.simulationQueue = [NSOperationQueue new];
    
    self.simulationQueue.maxConcurrentOperationCount = 1;
    
    [self.simulationQueue addOperationWithBlock:^{
        [self.universe bang];
    }];
    
    [self.simulationQueue addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completion(self.universe.numberOfSteps);
        }];
    }];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) runSimulationInScene:(TGLScene *) scene
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if ([self isReady] == NO) return;

    scene.updateDelegate = self.universe;
}

#pragma mark - TSLUniverseDelegate

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) shouldDie:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didUniverseDie:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _finished = YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didEvaluateUpdate:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) didSimulatePhysics:(TSLUniverse *) universe
////////////////////////////////////////////////////////////////////////////////////////////////
{
    
}

@end
