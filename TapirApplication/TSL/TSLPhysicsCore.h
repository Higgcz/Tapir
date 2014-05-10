//
//  TSLPhysicsCore.h
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLBody;

@interface TSLPhysicsCore : NSObject {
    
    NSMutableArray *_grid;
    
}

@property (nonatomic, readonly) CGSize gridSize;
@property (nonatomic, readonly) CGSize cellSize;

- (instancetype) initWithGridSize:(CGSize) gridSize andCount:(NSUInteger) count;
- (instancetype) initWithGridSize:(CGSize) gridSize andCellSize:(CGSize) cellSize;

// Objects
- (void) registrateBody:(TSLBody *) body;
- (BOOL) unregistrateBody:(TSLBody *) body; // return NO if failed

// Grid world coordinates conversions
- (CGPoint) getGridPointFromWorldPoint:(CGPoint) worldPoint;
- (CGPoint) getWorldPointFromGridPoint:(CGPoint) gridPoint;

// update
- (BOOL) updateForBody:(TSLBody *) body;

// Collisions
- (TSLBody *) getColiderWithBody:(TSLBody *) body;

- (BOOL) isBody:(TSLBody *) body colidesShape:(NSBezierPath *) shape;
- (NSSet *) getBodiesColidingShape:(NSBezierPath *) shape inSet:(NSSet *) set;

- (BOOL) isPossibleToMoveObject:(TSLBody *) anObject toPosition:(CGPoint *) point;
- (BOOL) isPossibleToMoveObject:(TSLBody *) anObject toPosition:(CGPoint *) point continuously:(BOOL) continuously;

@end
