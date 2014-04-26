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

+ (TSLConfiguration *) createFromFileNamed:(NSString *) fileName;
+ (TSLConfiguration *) createWithConfigurationDict:(NSDictionary *) configuration;

// All property in dictionary

@property (nonatomic) NSUInteger totalNumberOfSeconds;
@property (nonatomic) NSUInteger totalNumberOfAgents;
@property (nonatomic, strong) NSString *map;

@end
