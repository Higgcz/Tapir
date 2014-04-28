//
//  TSLColisionDelegate.h
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLBody;

@protocol TSLColisionDelegate <NSObject>

- (void) colidesWith:(TSLBody *) otherBody;

@end
