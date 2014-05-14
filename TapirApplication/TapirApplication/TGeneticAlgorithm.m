//
//  TEvolution.m
//  TapirApplication
//
//  Created by Vojtech Micka on 12.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TGeneticAlgorithm.h"
#import "TIndividual.h"
#import "TSimulation.h"

#define NIL [NSNull null]

#pragma mark - Parameters of evolutionary algorithm

#define MAX_GENERATIONS (100) // Maximal number of generations
#define ELITISM         (YES) // Elitism
#define MAX_SAME_BEST   (10)  // Maximal number of generations with the same best

#define POPULATION_SIZE (30)   // Size of population

#define CROSSOVER_RATE  (75)   // Percentage of the childrens that will be choosen by croosover
#define MUTATION_RATE   (5)    // Percentage of the childrens that will be mutated
#define MUTATION_TRESHOLD (5)

#define RAND()          (arc4random())
#define RAND_MOD(__MOD) (arc4random_uniform(__MOD))
#define RAND_IND()      (arc4random_uniform(POPULATION_SIZE)) // Choose a random number in range [0, population size)
#define RAND_100()      (arc4random_uniform(100)) // Choose a random number in range [0, 100)

#define TOURNAMENT_SIZE (3)

@interface TGeneticAlgorithm ()

@property (nonatomic, readwrite, assign) NSUInteger generations;

@property (nonatomic, readwrite, assign) CGFloat avgFitness;
@property (nonatomic, readwrite, assign) CGFloat bestFitness;

@property (nonatomic, strong) NSMutableArray *population;
@property (nonatomic, readwrite, strong) TIndividual *bestIndividual;

@property (nonatomic, readwrite, strong) NSArray *simulations;

// Private methods
- (void) populate;
- (void) run;

- (void) evaluatePopulation;
- (void) breedPopulation;
- (void) log;

- (NSArray *) crossoverParents:(NSArray *) parents;
- (void) mutateChildren:(NSArray *) children;
- (NSArray *) selectParents;
- (TIndividual *) selectWith:(NSUInteger) tournamentSize;

@end

@implementation TGeneticAlgorithm

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) writeToFile
////////////////////////////////////////////////////////////////////////////////////////////////
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
//    
    NSDateFormatter *timeStamp = [[NSDateFormatter alloc] init];
    [timeStamp setDateFormat:@"MMdd_hhmmss"];
    
    NSString *timeString = [timeStamp stringFromDate:[NSDate date]];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *plistPath = [[[[[NSBundle mainBundle] bundlePath]
                             stringByDeletingPathExtension]
                            stringByDeletingLastPathComponent]
                           stringByAppendingPathComponent:@"Results.plist"];
    
    NSArray *sortedPopulation = [self.population sortedArrayUsingComparator:^NSComparisonResult(TIndividual *obj1, TIndividual *obj2) {
        if ([obj1 isBetterThen:obj2]) {
            return NSOrderedAscending;
        } else if ([obj2 isBetterThen:obj1]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];

    if ([fileManager fileExistsAtPath:plistPath] == NO) {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"Results" ofType:@"plist"];
        [fileManager copyItemAtPath:resourcePath toPath:plistPath error:&error];
    }
    
    NSMutableArray *cycles = [NSMutableArray arrayWithCapacity:POPULATION_SIZE];
    [sortedPopulation enumerateObjectsUsingBlock:^(TIndividual* obj, NSUInteger idx, BOOL *stop) {
        [cycles addObject:[obj dictionaryAsDescription]];
    }];
    
    NSMutableDictionary *plistContent = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    [plistContent setObject:cycles forKey:[NSString stringWithFormat:@"ALG_%lu_%@", ((TSimulation*) self.simulations[0]).universe.configuration.totalNumberOfAgents, timeString]];
    [plistContent writeToFile:plistPath atomically:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) writeBestToConfiguration
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSString *path = ((TSimulation*) self.simulations[0]).universe.configuration.pathName;
    NSMutableDictionary *plistContent = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [plistContent setObject:self.bestIndividual.cycles forKey:@"SemaphoreCycles"];
    [plistContent writeToFile:path atomically:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        self.population = [NSMutableArray arrayWithCapacity:POPULATION_SIZE];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype) algorithmWithSimulations:(NSArray *) simulations
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TGeneticAlgorithm *alg = [TGeneticAlgorithm new];
    alg.simulations = simulations;
    return alg;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) execute
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self populate];
    [self run];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) populate
////////////////////////////////////////////////////////////////////////////////////////////////
{
    for (NSUInteger i = 0; i < POPULATION_SIZE; i++) {
        TIndividual *newIndividual = [TIndividual individualInGeneticAlgorithm:self];
        [self.population addObject:newIndividual];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) run
////////////////////////////////////////////////////////////////////////////////////////////////
{
    [self evaluatePopulation];
    
    TIndividual *lastBest      = nil;
    NSUInteger sameBestCounter = 0;
    
    for (self.generations = 0;
         self.generations < MAX_GENERATIONS && sameBestCounter < MAX_SAME_BEST;
         self.generations++)
    {
        @autoreleasepool {
            [self log];
            [self breedPopulation];
            [self evaluatePopulation];
            
            if (lastBest == self.bestIndividual) {
                sameBestCounter++;
            } else {
                sameBestCounter = 0;
                lastBest = self.bestIndividual;
            }
            
            [self writeBestToConfiguration];
        }
    }
    
    --self.generations;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) log
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSLog(@"In Generation #%lu - best fitness is %f, average fitness is %f", self.generations, self.bestFitness, self.avgFitness);
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) evaluatePopulation
////////////////////////////////////////////////////////////////////////////////////////////////
{
    // Calculate fitness for each individuals
    // Also looks for best individual to preserve
    __block CGFloat sumFitness = 0;
    __block TIndividual *elite = nil;
    [self.population enumerateObjectsUsingBlock:^(TIndividual *ind, NSUInteger idx, BOOL *stop) {
        // Calculate fitness, this can take a while
        [ind calculateFitness];
        
        @synchronized(self.population) {
            // Save elite individual
            if (elite == nil || [ind isBetterThen:elite]) {
                elite = ind;
            }
            
            sumFitness += ind.fitness;
        }
    }];
    
    self.bestIndividual = elite;
    self.bestFitness    = elite.fitness;
    self.avgFitness     = sumFitness / POPULATION_SIZE;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) breedPopulation
////////////////////////////////////////////////////////////////////////////////////////////////
{
    // Generate new population from the old one
    // Pass best individual to the new population
    
    NSMutableArray *newPopulation = [NSMutableArray arrayWithCapacity:POPULATION_SIZE];
    
    if (ELITISM) {
        [newPopulation addObject:self.bestIndividual];
    }
    
    while ([newPopulation count] < POPULATION_SIZE) {
        // Tournament selection
        NSArray *children = [self selectParents];
        
        if (RAND_100() < CROSSOVER_RATE) {
            // Crossover parents (in the variable childrens are parents selected in the tournament selection)
            children = [self crossoverParents:children];
        }
        
        if (RAND_100() < MUTATION_RATE) {
            // Mutate children
            [self mutateChildren:children];
        }
        
        if ([newPopulation count] < POPULATION_SIZE - 1) {
            // Add both childrens
            [newPopulation addObjectsFromArray:children];
        } else {
            // Population size is odd number, add just one children at the end
            [newPopulation addObject:children[0]];
        }
    }
    
    self.population = newPopulation;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) mutateChildren:(NSArray *) children
////////////////////////////////////////////////////////////////////////////////////////////////
{
    // Mutate children with wpecified mutation threshold
    [(TIndividual *) children[0] mutateWithThreshold:MUTATION_TRESHOLD];
    [(TIndividual *) children[1] mutateWithThreshold:MUTATION_TRESHOLD];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *) crossoverParents:(NSArray *) parents
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [(TIndividual *) parents[0] crossWithIndividual:parents[1]];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *) selectParents
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TIndividual *parentA = [self selectWith:TOURNAMENT_SIZE];
    TIndividual *parentB;
    do {
        parentB = [self selectWith:TOURNAMENT_SIZE];
    } while (parentA == parentB);
    
    return @[[parentA copy], [parentB copy]];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (TIndividual *) selectWith:(NSUInteger) tournamentSize
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TIndividual *best = self.population[RAND_IND()];
    TIndividual *cand;
    tournamentSize--;
    
    while (tournamentSize) {
        cand = self.population[RAND_IND()];
        
        if ([cand isBetterThen:best]) {
            best = cand;
        }
        
        tournamentSize--;
    }
    
    return best;
}

@end




































