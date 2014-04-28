//
//  TSLConfiguration.m
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLConfiguration.h"

@implementation TSLConfiguration

- (instancetype) initFromFileNamed:(NSString *) fileName
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype) initWithConfigurationDict:(NSDictionary *) configuration
{
    self = [super init];
    if (self) {
        self.totalNumberOfAgents  = configuration[@"totalNumberOfAgents"];
        self.totalNumberOfSeconds = configuration[@"totalNumberOfSeconds"];
        self.mapFile              = configuration[@"mapFile"];
    }
    return self;
}

+ (TSLConfiguration *) configuration
{
    return [[TSLConfiguration alloc] init];
}

+ (TSLConfiguration *) configurationFromFileNamed:(NSString *) fileName
{
    return [[TSLConfiguration alloc] initFromFileNamed:fileName];
}

+ (TSLConfiguration *) configurationWithConfigurationDict:(NSDictionary *) configuration
{
    return [[TSLConfiguration alloc] initWithConfigurationDict:configuration];
}

@end
