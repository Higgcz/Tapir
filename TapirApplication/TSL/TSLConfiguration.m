//
//  TSLConfiguration.m
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLConfiguration.h"

@interface TSLConfiguration ()

- (void) loadPropertyFromDict:(NSDictionary *) dict withKey:(TSLConfigurationProperty) key;
- (void) setup;

@end

@implementation TSLConfiguration

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) init
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initFromFileNamed:(NSString *) fileName
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        [self setup]; // set defaults
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithConfigurationDict:(NSDictionary *) configuration
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        [self setup]; // set defaults
        
        for (NSUInteger i = 0; i < kTSLConfigurationPropertyCount; i++) {
            [self loadPropertyFromDict:configuration withKey:i];
        }
        
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setup
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.totalNumberOfAgents = 1;
    self.totalNumberOfSeconds = 1000;
    self.mapFile = nil;
    self.worldSize = CGSizeMake(1024, 768);
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadPropertyFromDict:(NSDictionary *) dict withKey:(TSLConfigurationProperty) key
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSNumber *tmp = nil;
    NSArray  *worldSize = nil;
    switch (key) {
        case TSLConfigurationPropertyTotalNumberOfSeconds:
            tmp = [dict objectForKey:@(TSLConfigurationPropertyTotalNumberOfSeconds)];
            if (tmp != nil) {
                self.totalNumberOfSeconds = tmp.unsignedIntegerValue;
            }
            break;
        case TSLConfigurationPropertyTotalNumberOfAgents:
            tmp = [dict objectForKey:@(TSLConfigurationPropertyTotalNumberOfAgents)];
            if (tmp != nil) {
                self.totalNumberOfAgents = tmp.unsignedIntegerValue;
            }
            break;
        case TSLConfigurationPropertyMapFileName:
            self.mapFile = [dict objectForKey:@(TSLConfigurationPropertyMapFileName)];
            break;
        case TSLConfigurationPropertyWorldSize:
            worldSize = (NSArray *) [dict objectForKey:@(TSLConfigurationPropertyWorldSize)];
            NSAssert(worldSize.count == 2, @"World size must have two values (width and height).");
            self.worldSize = CGSizeMake(((NSNumber *) worldSize[0]).floatValue, ((NSNumber *) worldSize[1]).floatValue);
            break;
        default:
            ERROR(@"No such key exist.");
            break;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TSLConfiguration *) configuration
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLConfiguration alloc] init];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TSLConfiguration *) configurationFromFileNamed:(NSString *) fileName
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLConfiguration alloc] initFromFileNamed:fileName];
}

////////////////////////////////////////////////////////////////////////////////////////////////
+ (TSLConfiguration *) configurationWithConfigurationDict:(NSDictionary *) configuration
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [[TSLConfiguration alloc] initWithConfigurationDict:configuration];
}

@end
