//
//  TSLConfiguration.m
//  Tapir
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLConfiguration.h"

@interface TSLConfiguration ()

- (void) loadPropertyWithValue:(id) value withKey:(NSString *) key;
- (void) setup;

@property (nonatomic, readwrite, strong) NSString *pathName;

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
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        
        NSString *plistPath = [[[[[NSBundle mainBundle] bundlePath]
                                 stringByDeletingPathExtension]
                                stringByDeletingLastPathComponent]
                               stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]];
        
        if ([fileManager fileExistsAtPath:plistPath] == NO) {
            NSString *resourcePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
            [fileManager copyItemAtPath:resourcePath toPath:plistPath error:&error];
        }
        
        self.pathName = plistPath;
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            [self loadPropertyWithValue:obj withKey:key];
        }];
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
        
        [configuration enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            [self loadPropertyWithValue:obj withKey:key];
        }];
        
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setup
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.roadLength             = 200;
    self.numberOfLines          = 2;
    self.angleStraightTolerance = M_PI / 6.0f;
    
    self.randomSeed             = 0;
    
    self.semaphoreTickLength = 5;
    self.semaphoreStateDelay = 2;
    
    self.probCarTypePassenger = 70;
    self.probCarTypeTruck     = 20;
    self.probCarTypeBus       = 10;
    
    self.probDriverSpeedUp = 70;
    
    self.totalNumberOfAgents = 1;
    self.totalNumberOfSteps  = 1000;
    self.mapFile = nil;
    self.worldSize = CGSizeMake(1024, 768);
    
    self.sempahoreCycles = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadPropertyWithValue:(id) value withKey:(NSString *) key
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSNumber *tmp = nil;
    NSArray  *worldSize = nil;
    if ([key isEqualToString:@"TotalNumberOfSteps"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.totalNumberOfSteps = tmp.unsignedIntegerValue;
        }
        
    } else if ([key isEqualToString:@"TotalNumberOfAgents"]) {
    
        tmp = value;
        if (tmp != nil) {
            self.totalNumberOfAgents = tmp.unsignedIntegerValue;
        }
    
    } else if ([key isEqualToString:@"MapFileName"]) {
    
        self.mapFile = value;
    
    } else if ([key isEqualToString:@"WorldSize"]) {
        
        worldSize = (NSArray *) value;
        NSAssert(worldSize.count == 2, @"World size must have two values (width and height).");
        self.worldSize = CGSizeMake(((NSNumber *) worldSize[0]).floatValue, ((NSNumber *) worldSize[1]).floatValue);
    
    } else if ([key isEqualToString:@"RoadLength"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.roadLength = tmp.unsignedIntegerValue;
        }
        
    } else if ([key isEqualToString:@"NumberOfLines"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.numberOfLines = tmp.unsignedIntegerValue;
        }
        
    } else if ([key isEqualToString:@"AngleStraightTolerance"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.angleStraightTolerance = tmp.floatValue;
        }
        
    } else if ([key isEqualToString:@"ProbDriverSpeedUp"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.probDriverSpeedUp = tmp.unsignedIntegerValue;
        }
        
    } else if ([key isEqualToString:@"RandomSeed"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.randomSeed = tmp.unsignedIntegerValue;
        }
        
    } else if ([key isEqualToString:@"ProbCarTypePassenger"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.probCarTypePassenger = tmp.unsignedIntegerValue;
        }
        
    } else if ([key isEqualToString:@"ProbCarTypeTruck"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.probCarTypeTruck = tmp.unsignedIntegerValue;
        }
        
    } else if ([key isEqualToString:@"ProbCarTypeBus"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.probCarTypeBus = tmp.unsignedIntegerValue;
        }
        
    } else if ([key isEqualToString:@"SemaphoreStateDelay"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.semaphoreStateDelay = tmp.unsignedIntegerValue;
        }
        
    } else if ([key isEqualToString:@"SemaphoreTickLength"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.semaphoreTickLength = tmp.unsignedIntegerValue;
        }
        
    } else if ([key isEqualToString:@"SemaphoreCycles"]) {
        
        self.sempahoreCycles = [NSArray arrayWithArray:value];
        
    } else if ([key isEqualToString:@"UseEvolution"]) {
        
        tmp = value;
        if (tmp != nil) {
            self.useEvolution = tmp.boolValue;
        }
        
    } else {
        ERROR(@"No such key exist.");
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
