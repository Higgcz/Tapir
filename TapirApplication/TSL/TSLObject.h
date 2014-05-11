//
//  TSLObject.h
//  TapirApplication
//
//  Created by Vojtech Micka on 07.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLUniverse;

@interface TSLObject : NSObject

// Other properties
@property (nonatomic, getter = isActive) BOOL active;
@property (nonatomic, getter = isReady)  BOOL ready;
@property (nonatomic, getter = isDead)   BOOL dead;
@property (nonatomic, readonly, weak) TSLUniverse *universe;

// Updating
- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval) deltaTime;

// Lifecycle methods
- (void) didCreatedAtUniverse:(TSLUniverse *) universe;
- (void) didDeleted;

- (void) removeFromUniverse;

@end
