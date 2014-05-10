//
//  TSLConfiguration.h
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TSLConfigurationProperty) {
    TSLConfigurationPropertyTotalNumberOfSeconds = 0,
    TSLConfigurationPropertyTotalNumberOfAgents,
    TSLConfigurationPropertyMapFileName,
    TSLConfigurationPropertyWorldSize,
    
    kTSLConfigurationPropertyCount
};

@interface TSLConfiguration : NSObject

// Init & create

- (instancetype) initFromFileNamed:(NSString *) fileName;
- (instancetype) initWithConfigurationDict:(NSDictionary *) configuration;

+ (TSLConfiguration *) configuration;
+ (TSLConfiguration *) configurationFromFileNamed:(NSString *) fileName;
+ (TSLConfiguration *) configurationWithConfigurationDict:(NSDictionary *) configuration;

// All property in dictionary

@property (nonatomic        ) NSUInteger totalNumberOfSeconds;
@property (nonatomic        ) NSUInteger totalNumberOfAgents;
@property (nonatomic, strong) NSString   *mapFile;
@property (nonatomic        ) CGSize     worldSize;

@end
