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

@property (nonatomic, strong) NSNumber *totalNumberOfSeconds;
@property (nonatomic, strong) NSNumber *totalNumberOfAgents;
@property (nonatomic, strong) NSString *mapFile;

@end