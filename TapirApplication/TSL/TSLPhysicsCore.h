//
//  TSLPhysicsCore.h
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSLEntity;

@interface TSLPhysicsCore : NSObject {
    
    NSMutableArray *_grid;
    
}

@property (nonatomic, readonly) CGSize gridSize;
@property (nonatomic, readonly) CGSize cellSize;

- (instancetype) initWithGridSize:(CGSize) gridSize andCount:(NSUInteger) count;
- (instancetype) initWithGridSize:(CGSize) gridSize andCellSize:(CGSize) cellSize;

// Grid world coordinates conversions
- (CGPoint) getGridPointFromWorldPoint:(CGPoint) worldPoint;
- (CGPoint) getWorldPointFromGridPoint:(CGPoint) gridPoint;

// Collisions
- (BOOL) isPossibleToMoveObject:(TSLEntity *) anObject toPosition:(CGPoint *) point;
- (BOOL) isPossibleToMoveObject:(TSLEntity *) anObject toPosition:(CGPoint *) point continuously:(BOOL) continuously;


@end
