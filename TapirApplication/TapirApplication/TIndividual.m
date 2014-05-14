//
//  TIndividual.m
//  TapirApplication
//
//  Created by Vojtech Micka on 12.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TIndividual.h"
#import "TSimulation.h"
#import "TGeneticAlgorithm.h"
#import "TSLSemaphore.h"

#define SEMAPHORES_COUNT (32) // IntersectionCount * NumberOfRoadsByIntersection * NumberOfLinesByRoad (4 * 4 * 2)

#define RAND()          (arc4random())
#define RAND_MOD(__MOD) (arc4random_uniform(__MOD))
#define RAND_100()      (arc4random_uniform(100)) // Choose a random number in range [0, 100)

#define USE_HEURISTIC_TO_CYCLE_GENERATION (1)
#define P_SAME (20)
#define P_OVER (60)

@interface TIndividual ()

@property (nonatomic, readwrite, weak) TGeneticAlgorithm *geneticAlgorithm;
@property (nonatomic, readwrite, assign) CGFloat fitness;
@property (nonatomic, readwrite, strong) NSArray *cycles;
@property (nonatomic, readwrite) BOOL mutated;

- (NSArray *) fillCyclesRandom;
- (NSArray *) createRandomCycle;
- (NSArray *) createRandomCycleUniform;
- (NSArray *) createRandomCycleWithRegion;

+ (instancetype) empty;
- (instancetype) initEmpty;

@end

@implementation TIndividual

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *) dictionaryAsDescription
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:@(_fitness) forKey:@"Fitness"];
    [dict setObject:_cycles forKey:@"Cycles"];
    return dict;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        _mutated  = YES;
        _fitness = NSNotFound;
        _cycles   = [self fillCyclesRandom];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initEmpty
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        _mutated  = YES;
        _fitness = NSNotFound;
        _cycles   = nil;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) copy
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TIndividual *copied     = [TIndividual empty];

    copied.geneticAlgorithm = self.geneticAlgorithm;
    copied.mutated          = self.mutated;
    copied.fitness          = self.fitness;
    copied.cycles           = [self.cycles copy];
    
    return copied;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) individualInGeneticAlgorithm:(TGeneticAlgorithm *) geneticAlgorithm
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TIndividual *ind = [TIndividual new];
    ind.geneticAlgorithm = geneticAlgorithm;
    return ind;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) empty
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TIndividual alloc] initEmpty];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *) fillCyclesRandom
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSMutableArray *cycles = [NSMutableArray new];
    
    for (unsigned i = 0; i < SEMAPHORES_COUNT; i++) {
        // Create cycle for i-th semaphore
        NSArray *newCycle = [self createRandomCycle];
        
        [cycles addObject:newCycle];
    }
    
    return cycles;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *) createRandomCycle
////////////////////////////////////////////////////////////////////////////////////////////////
{
#if USE_HEURISTIC_TO_CYCLE_GENERATION == 0
    return [self createRandomCycleUniform];
#else
    return [self createRandomCycleWithRegion];
#endif
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *) createRandomCycleUniform
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSMutableArray *newCycle = [NSMutableArray new];
    
    // Fill the cycle with random
    for (unsigned j = 0; j < kTSLSemaphorePeriodLength; j++) {
        [newCycle addObject:@(RAND_MOD(2))];
    }
    
    return newCycle;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *) createRandomCycleWithRegion
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSMutableArray *newCycle = [NSMutableArray new];
    
    NSUInteger countOfOnes = 0;
    NSUInteger countOfZeros = 0;
    NSUInteger maxOnes = kTSLSemaphorePeriodLength / 2 - 2;
    BOOL lastState = RAND_MOD(2);
    NSUInteger probOfOne = 50;
    // Fill the cycle with random
    for (unsigned j = 0; j < kTSLSemaphorePeriodLength; j++) {
        BOOL state = RAND_100() < probOfOne;
        
        if (state == YES) {
            countOfOnes++;
            if (countOfOnes < maxOnes && lastState == state) {
                probOfOne += P_SAME;
            } else if (countOfOnes > maxOnes) {
                probOfOne -= P_OVER;
            }
        } else {
            countOfZeros++;
            if (countOfZeros < maxOnes && lastState == state) {
                probOfOne -= P_SAME;
            } else if (countOfZeros > maxOnes) {
                probOfOne += P_OVER;
            }
            probOfOne %= 100;
        }
        lastState = state;
        
        [newCycle addObject:@(state)];
    }
    
    return newCycle;
}

#pragma mark - Public methods

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *) crossWithIndividual:(TIndividual *) other
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TIndividual *childA = [TIndividual empty];
    TIndividual *childB = [TIndividual empty];
    
    childA.geneticAlgorithm = self.geneticAlgorithm;
    childB.geneticAlgorithm = self.geneticAlgorithm;
    
    NSMutableArray *childAcycles = [NSMutableArray new];
    NSMutableArray *childBcycles = [NSMutableArray new];
    
    [self.cycles enumerateObjectsUsingBlock:^(NSArray *myCycle, NSUInteger idx, BOOL *stop) {
        NSArray *otherCycle = other.cycles [idx];
        
        NSUInteger randomPosition = RAND_MOD((unsigned)[myCycle count]);
        NSRange frontRange = NSMakeRange(0, randomPosition);
        NSRange backRange  = NSMakeRange(randomPosition, [otherCycle count] - randomPosition);
        
        NSMutableArray *arrayA = [NSMutableArray arrayWithArray:[myCycle subarrayWithRange:frontRange]];
        [arrayA addObjectsFromArray:[otherCycle subarrayWithRange:backRange]];
        
        NSMutableArray *arrayB = [NSMutableArray arrayWithArray:[otherCycle subarrayWithRange:frontRange]];
        [arrayB addObjectsFromArray:[myCycle subarrayWithRange:backRange]];
        
        [childAcycles addObject:arrayA];
        [childBcycles addObject:arrayB];
    }];
    
    childA.cycles = childAcycles;
    childB.cycles = childBcycles;
    
    return @[childA, childB];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) mutateWithThreshold:(NSUInteger) threshold
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _mutated = YES;
    
    // Mutate
    for (NSMutableArray *cycle in self.cycles) {
        for (int i = 0; i < [cycle count]; i++) {
            
            if (RAND_100() < threshold) {
                BOOL state = ((NSNumber *) cycle[i]).boolValue;
                cycle[i] = @(!state);
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isBetterThen:(TIndividual *) other
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return self.fitness < other.fitness;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) calculateFitness
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (_mutated == NO) return;
    _mutated = NO;
    
    // Run simulation SIMULATIONS_COUNT times and return the average of the total number of steps
    NSArray *simulations = self.geneticAlgorithm.simulations;
    
    __block NSUInteger sumTotalNumberOfSteps      = 0;
    __block NSUInteger sumTotalNumberOfStayingCar = 0;
    
    dispatch_group_t group = dispatch_group_create();
    
    for (TSimulation *simulation in simulations) {
        
        [simulation configurateSemaphoresWithArray:self.cycles];
        [simulation resetSimulation];
        
        dispatch_group_enter(group);
        [simulation runSimulationWithCompletion:^(NSUInteger simulationSteps, NSUInteger stayingCars) {
            //            NSLog(@"Simulation step: %lu", simulationSteps);
            @synchronized(simulations) {
                sumTotalNumberOfSteps      += simulationSteps;
                sumTotalNumberOfStayingCar += stayingCars;
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    self.fitness = (CGFloat) (sumTotalNumberOfSteps + sumTotalNumberOfStayingCar) / simulations.count;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) fitness
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return _fitness;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *) descriptionOfCycleOnIndex:(NSUInteger) index
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSMutableString *description = [NSMutableString new];
    for (NSNumber *state in self.cycles[index]) {
        [description appendString:[NSString stringWithFormat:@"%d ", state.boolValue]];
    }
    return description;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *) description
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSMutableString *description = [NSMutableString new];
    
    for (NSArray *cycle in self.cycles) {
        for (NSNumber *state in cycle) {
            [description appendString:[NSString stringWithFormat:@"%d ", state.boolValue]];
        }
        [description appendString:[NSString stringWithFormat:@"\n"]];
    }
    
    return description;
}

@end
