//
//  TSLAgent.h
//  TapirApplication
//
//  Created by Vojtech Micka on 26.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLBody.h"
#import "TSLEntity.h"

@class TSLPhysicsBody;

@interface TSLAgent : TSLEntity <TSLColisionDelegate>

// Other properties
@property (nonatomic, getter = isActive) BOOL active;

- (void) setup;

@end
