//
//  TIndividual.h
//  TapirApplication
//
//  Created by Vojtech Micka on 12.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TGeneticAlgorithm;

@interface TIndividual : NSObject

@property (nonatomic, readonly, assign) CGFloat fitness;
@property (nonatomic, readonly, strong) NSArray *cycles;

+ (instancetype) individualInGeneticAlgorithm:(TGeneticAlgorithm *) geneticAlgorithm;

// Create new pair of individuals by crossover this individual with other
- (NSArray *) crossWithIndividual:(TIndividual *) other;

// Mutate with specified mutation threshold
- (void) mutateWithThreshold:(NSUInteger) threshold;

// Evaluate fitness and test who is better
- (BOOL) isBetterThen:(TIndividual *) other;

// Create few simulations with configuration from this individual
- (void) calculateFitness;

// Return description just for cycle on given index
- (NSString *) descriptionOfCycleOnIndex:(NSUInteger) index;

- (NSDictionary *) dictionaryAsDescription;

@end
