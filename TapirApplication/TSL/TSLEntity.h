//
//  TSLBaseEntity.h
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLUniverse, TSLBody;

@interface TSLEntity : NSObject {
    
@protected
    TSLUniverse *_universe;
}

// Body
@property (nonatomic, strong) TSLBody *body;

- (instancetype) initWithBodySize:(CGSize) size;

// Updating
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime;

// Lifecycle methods
- (void) didCreatedAtUniverse:(TSLUniverse *) universe;
- (void) didDeleted;

@end
