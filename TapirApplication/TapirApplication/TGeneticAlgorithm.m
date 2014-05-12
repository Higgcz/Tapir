//
//  TEvolution.m
//  TapirApplication
//
//  Created by Vojtech Micka on 12.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TGeneticAlgorithm.h"
#import "TIndividual.h"

#define NIL [NSNull null]

#pragma mark - Parameters of evolutionary algorithm

#define MAX_GENERATIONS (10) // Maximal number of generations
#define ELITISM         (YES)  // Elitism

#define POPULATION_SIZE (20)   // Size of population

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
        TIndividual *newIndividual = [TIndividual new];
        [self.population addObject:newIndividual];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) run
////////////////////////////////////////////////////////////////////////////////////////////////
{
    for (self.generations = 0;
         self.generations < MAX_GENERATIONS;
         self.generations++)
    {
        [self evaluatePopulation];
        [self log];
        [self breedPopulation];
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
    
    return @[parentA, parentB];
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




































