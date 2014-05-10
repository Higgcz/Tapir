//
//  TSLPhysicsCore.m
//  TapirApplication
//
//  Created by Vojtech Micka on 27.04.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import "TSLPhysicsCore.h"
#import "TSLBody.h"

#import "../TGL/TGL.h"

@interface TSLPhysicsCore ()

- (void) setupWithGridSize:(CGSize) gridSize andCellSize:(CGSize) cellSize;

- (NSUInteger) getIndexFromWorldPoint:(CGPoint) worldPoint;
- (NSUInteger) getIndexFromGridPoint:(CGPoint) gridPoint;

- (NSMutableSet *) getSetForIndex:(NSUInteger) index;
- (NSMutableSet *) getSetForBody:(TSLBody *) body usingOld:(BOOL) useOld;

- (BOOL) removeBody:(TSLBody *) body atGridPoint:(CGPoint) gridPoint;

@end

@implementation TSLPhysicsCore {
    
    CGFloat _ratioHeight;
    CGFloat _ratioWidth;
    
}

#pragma mark - Private setters

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setGridSize:(CGSize) gridSize
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _gridSize = gridSize;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setCellSize:(CGSize) cellSize
////////////////////////////////////////////////////////////////////////////////////////////////
{
    _cellSize = cellSize;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithGridSize:(CGSize) gridSize andCount:(NSUInteger) count
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        CGSize cellSize = CGSizeMake(gridSize.width / count, gridSize.height / count);
        [self setupWithGridSize:gridSize andCellSize:cellSize];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype) initWithGridSize:(CGSize) gridSize andCellSize:(CGSize) cellSize
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self = [super init];
    if (self) {
        [self setupWithGridSize:gridSize andCellSize:cellSize];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setupWithGridSize:(CGSize) gridSize andCellSize:(CGSize) cellSize
////////////////////////////////////////////////////////////////////////////////////////////////
{
    self.gridSize = gridSize;
    self.cellSize = cellSize;
    
    _ratioHeight = 1 / cellSize.height;
    _ratioWidth  = 1 / cellSize.width;
    
    NSUInteger colCount = gridSize.width / cellSize.width;
    NSUInteger rowCount = gridSize.height / cellSize.height;
    
    NSUInteger size = colCount * rowCount;
    _grid = [NSMutableArray arrayWithCapacity:size];
    
    for (int i = 0; i < size; i++) {
        _grid [ i ] = [NSMutableSet set];
    }
    
//    [TGLSceneManager registerLayer:[TGLLayer layerWithGridInRectSize:gridSize gridSize:CGSizeMake(colCount, rowCount) andStrokeColor:[SKColor redColor]]];
}

#pragma mark - Object registration

////////////////////////////////////////////////////////////////////////////////////////////////
- (void) registrateBody:(TSLBody *) body
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger idx = [self getIndexFromWorldPoint:body.position];
    
    NSLog(@"index: %lu\n", idx);
    
    [[self getSetForIndex:idx] addObject:body];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) unregistrateBody:(TSLBody *) body
////////////////////////////////////////////////////////////////////////////////////////////////
{
    CGPoint gridPoint = [self getGridPointFromWorldPoint:body.position];
    NSUInteger idx = [self getIndexFromGridPoint:gridPoint];
    
    NSMutableSet *set = [self getSetForIndex:idx];
    
    BOOL isRemoved = NO;
    
    if ([set containsObject:body]) {
        [set removeObject:body];
        isRemoved = YES;
    } else {
        // Find entity
        CGPoint tmpPoint = gridPoint;
        // Test for neighbourhood
        for (NSInteger i = 0; (i < 9) && !isRemoved; i++) {
            if (i == 4) continue;
            
            NSInteger x = i / 3 - 1;
            NSInteger y = i % 3 - 1;
            
            tmpPoint.x += x;
            tmpPoint.y += y;
            
            isRemoved = [self removeBody:body atGridPoint:tmpPoint];
            
            tmpPoint = gridPoint;
        }
    }
    
    return isRemoved;
}

#pragma mark - Grid

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableSet *) getSetForIndex:(NSUInteger) index
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return (NSMutableSet *) _grid [ index ];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableSet *) getSetForBody:(TSLBody *) body usingOld:(BOOL) useOld
////////////////////////////////////////////////////////////////////////////////////////////////
{
    CGPoint gridPoint = [self getGridPointFromWorldPoint:useOld ? body.oldPosition : body.position];
    CGPoint tmpPoint = gridPoint;
    NSMutableSet *set = [self getSetForIndex:[self getIndexFromGridPoint:gridPoint]];
    
    if ([set containsObject:body] == NO) {
        // Test for neighbourhood
        for (NSInteger i = 0; (i < 9); i++) {
            if (i == 4) continue;
            
            NSInteger x = i / 3 - 1;
            NSInteger y = i % 3 - 1;
            
            tmpPoint.x += x;
            tmpPoint.y += y;
            
            set = [self getSetForIndex:[self getIndexFromGridPoint:tmpPoint]];
            
            if ([set containsObject:body]) {
                break;
            }
            
            // Reset variables
            tmpPoint = gridPoint;
            set      = nil;
        }
    }
    
    return set;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) removeBody:(TSLBody *) body atGridPoint:(CGPoint) gridPoint
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger idx = [self getIndexFromGridPoint:gridPoint];
    NSMutableSet *set = [self getSetForIndex:idx];
    if ([set containsObject:body]) {
        [set removeObject:body];
    } else {
        return NO;
    }
    return YES;
}

#pragma mark - Math

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint) getWorldPointFromGridPoint:(CGPoint) gridPoint
////////////////////////////////////////////////////////////////////////////////////////////////
{
    CGPoint worldPoint = gridPoint;
    worldPoint.x /= _ratioWidth;
    worldPoint.y /= _ratioHeight;
    return worldPoint;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint) getGridPointFromWorldPoint:(CGPoint) worldPoint
////////////////////////////////////////////////////////////////////////////////////////////////
{
    if (worldPoint.x < 0 || worldPoint.x > _gridSize.width || worldPoint.y < 0 || worldPoint.y > _gridSize.height) {
        // Off-world
        
        if (worldPoint.x > _gridSize.width) {
            worldPoint.x = _gridSize.width;
        } else if (worldPoint.x < 0) {
            worldPoint.x = 0;
        }
        
        if (worldPoint.y > _gridSize.height) {
            worldPoint.y = _gridSize.height;
        } else if (worldPoint.y < 0) {
            worldPoint.y = 0;
        }
    }
    
    CGPoint gridPoint = worldPoint;
    gridPoint.x = (int) (gridPoint.x * _ratioWidth);
    gridPoint.y = (int) (gridPoint.y * _ratioHeight);
    return gridPoint;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger) getIndexFromWorldPoint:(CGPoint) worldPoint
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self getIndexFromGridPoint:[self getGridPointFromWorldPoint:worldPoint]];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger) getIndexFromGridPoint:(CGPoint) gridPoint
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger countX = self.gridSize.width / self.cellSize.width;
    return gridPoint.x + countX * gridPoint.y;
}

#pragma mark - Updating

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) updateForBody:(TSLBody *) body
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSUInteger oldIndex = [self getIndexFromWorldPoint:body.oldPosition];
    NSUInteger newIndex = [self getIndexFromWorldPoint:body.position];
    
    NSLog(@"oldIndex: %lu\n", oldIndex);
    NSLog(@"newIndex: %lu\n", newIndex);
    
    if (oldIndex == newIndex) {
        // Doesn't need to update the grid
        return YES;
    }
    
    // Try to find the set, which contains the entity
    NSMutableSet *set = [self getSetForBody:body usingOld:YES];
    if (set == nil) {
        // Didn't find the entity at the old coordinates
        // Try the new one
        set = [self getSetForBody:body usingOld:NO];
        if (set == nil) {
            // Did't find the entity at the new coordinates neither
            // Fail to find
            return NO;
        }
    }
    
    // Remove the entity from the old set
    [set removeObject:body];
    
    // Add the entity to the new set
    set = [self getSetForIndex:[self getIndexFromWorldPoint:body.position]];
    [set addObject:body];
    
    return YES;
}

#pragma mark - Collisions

////////////////////////////////////////////////////////////////////////////////////////////////
- (TSLBody *) getColiderWithBody:(TSLBody *) body
////////////////////////////////////////////////////////////////////////////////////////////////
{
    TSLBody *colider = nil;
    
    NSBezierPath *entityBody = [body getShape];
    
    NSUInteger index = [self getIndexFromWorldPoint:body.position];
    
    // TODO
    
    return colider;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isBody:(TSLBody *) body colidesShape:(NSBezierPath *) shape
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSBezierPath *bodyShape = [body getShape];
    
    NSRect bodyBounds  = [bodyShape controlPointBounds];
    NSRect shapeBounds = [shape controlPointBounds];
    
    // Test for bounding box
    if (NSIntersectsRect(bodyBounds, shapeBounds) == NO) {
        return NO;
    }
    
    // Test for corner points of body
    NSBezierPath *flattenBodyShape = [bodyShape bezierPathByFlatteningPath];
    
    NSInteger count = [flattenBodyShape elementCount];
    NSPoint curr;
    
    for (NSInteger i = 0; i < count; ++i) {
        NSBezierPathElement type = [flattenBodyShape elementAtIndex:i associatedPoints:&curr];
        
        NSLog(@"Curr: %@", NSStringFromPoint(curr));
        
        
        if ([shape containsPoint:curr]) {
            // Given shape contatins corner point of body shape
            return YES;
        }
    }
    
    
    // Test for corner points of shape
    NSBezierPath *flattenShape     = [shape bezierPathByFlatteningPath];
    
    count = [flattenShape elementCount];
    curr  = NSZeroPoint;
    
    for (NSInteger i = 0; i < count; ++i) {
        NSBezierPathElement type = [flattenShape elementAtIndex:i associatedPoints:&curr];
        
        NSLog(@"Curr: %@", NSStringFromPoint(curr));
        
        
        if ([bodyShape containsPoint:curr]) {
            // Given shape contatins corner point of body shape
            return YES;
        }
    }
    
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (NSSet *) getBodiesColidingShape:(NSBezierPath *) shape inSet:(NSSet *) set
////////////////////////////////////////////////////////////////////////////////////////////////
{
    NSMutableSet *colidingBodies = [NSMutableSet set];
    [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        
        NSAssert([obj isKindOfClass:[TSLBody class]], @"Object in set have to be an body");
        
        TSLBody *otherBody = (TSLBody *) obj;
        
        if ([self isBody:otherBody colidesShape:shape]) {
            // Other body is colliding given shape
            [colidingBodies addObject:otherBody];
        }
    }];
    
    return colidingBodies;
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isPossibleToMoveObject:(TSLBody *)anObject toPosition:(CGPoint *)point
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return [self isPossibleToMoveObject:anObject toPosition:point continuously:NO];
}

////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isPossibleToMoveObject:(TSLBody *)anObject toPosition:(CGPoint *)point continuously:(BOOL)continuously
////////////////////////////////////////////////////////////////////////////////////////////////
{
    return NO;
}

@end
