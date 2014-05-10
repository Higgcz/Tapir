//
//  TSLWaypoint.h
//  TapirApplication
//
//  Created by Vojtech Micka on 07.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSLWaypoint : NSObject

@property (nonatomic, readonly) NSPoint position;

@property (nonatomic, strong) TSLWaypoint *nextWaypoint;

- (instancetype) initWithPosition:(NSPoint) position;

+ (instancetype) waypointWithPosition:(NSPoint) position;

@end
