//
//  TEvolution.h
//  TapirApplication
//
//  Created by Vojtech Micka on 12.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TIndividual;

@interface TGeneticAlgorithm : NSObject

@property (nonatomic, readonly, assign) NSUInteger generations;

@property (nonatomic, readonly, assign) CGFloat avgFitness;
@property (nonatomic, readonly, assign) CGFloat bestFitness;

@property (nonatomic, readonly, strong) TIndividual *bestIndividual;

@property (nonatomic, readonly, strong) NSArray *simulations;

+ (instancetype) algorithmWithSimulations:(NSArray *) simulations;
- (void) execute;

- (void) writeToFile;

@end
