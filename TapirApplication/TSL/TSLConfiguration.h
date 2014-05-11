//
//  TSLConfiguration.h
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSLConfiguration : NSObject

// Init & create

- (instancetype) initFromFileNamed:(NSString *) fileName;
- (instancetype) initWithConfigurationDict:(NSDictionary *) configuration;

+ (TSLConfiguration *) configuration;
+ (TSLConfiguration *) configurationFromFileNamed:(NSString *) fileName;
+ (TSLConfiguration *) configurationWithConfigurationDict:(NSDictionary *) configuration;

// All property in dictionary

@property (nonatomic) NSUInteger roadLength;
@property (nonatomic) NSUInteger numberOfLines;
@property (nonatomic) CGFloat angleStraightTolerance;

@property (nonatomic) NSUInteger probDriverSpeedUp;

@property (nonatomic) NSUInteger semaphoreTickLength;
@property (nonatomic) NSUInteger semaphoreStateDelay;

//@property (nonatomic) NSUInteger carMaxRange;
//
//@property (nonatomic) CGFloat carTypePassengerMaxSpeed;
//@property (nonatomic) CGFloat carTypePassengerAcceleration;
//
//@property (nonatomic) CGFloat carTypeTruckMaxSpeed;
//@property (nonatomic) CGFloat carTypeTruckAcceleration;
//
//@property (nonatomic) CGFloat carTypeBusMaxSpeed;
//@property (nonatomic) CGFloat carTypeBusAcceleration;

@property (nonatomic) NSUInteger randomSeed;

@property (nonatomic) NSUInteger probCarTypePassenger;
@property (nonatomic) NSUInteger probCarTypeTruck;
@property (nonatomic) NSUInteger probCarTypeBus;

@property (nonatomic        ) NSUInteger totalNumberOfSeconds;
@property (nonatomic        ) NSUInteger totalNumberOfAgents;
@property (nonatomic, strong) NSString   *mapFile;
@property (nonatomic        ) CGSize     worldSize;

@end
