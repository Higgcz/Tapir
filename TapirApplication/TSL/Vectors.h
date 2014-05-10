//
//  Vectors.h
//  TapirApplication
//
//  Created by Vojtech Micka on 07.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#pragma once

#ifndef TapirApplication_Vectors_h
#define TapirApplication_Vectors_h

#import "VectorType.h"

static BOOL NSVectorEqualZero ( NSVector vector ) {
    return vector.x == 0 && vector.y == 0;
}

static BOOL NSVectorEqualZeroWithAccurancy ( NSVector vector, CGFloat accurancy ) {
    return abs(vector.x) < accurancy && abs(vector.y) < accurancy;
}

static BOOL NSVectorsEqual ( NSVector vectorA, NSVector vectorB ) {
    return vectorA.x == vectorB.x && vectorA.y == vectorB.y;
}

static BOOL NSVectorsEqualWithAccurancy ( NSVector vectorA, NSVector vectorB, CGFloat accurancy ) {
    return abs(vectorA.x - vectorB.x) < accurancy && abs(vectorA.y - vectorB.y) < accurancy;
}

// Multiply (c * A)
static NSVector NSVectorResize ( NSVector vector, CGFloat c ) {
    return NSMakePoint(vector.x * c, vector.y * c);
}

// Add (A + B)
static NSVector NSVectorAdd ( NSVector vectorA, NSVector vectorB ) {
    return NSMakePoint(vectorA.x + vectorB.x, vectorA.y + vectorB.y);
}

// Substract (A - B)
static NSVector NSVectorSub ( NSVector vectorA, NSVector vectorB ) {
    return NSMakePoint(vectorA.x - vectorB.x, vectorA.y - vectorB.y);
}

// Dot product of two vectors
static CGFloat NSVectorDot ( NSVector vectorA, NSVector vectorB ) {
    return vectorA.x * vectorB.x + vectorA.y * vectorB.y;
}

// Cross product of two vectors
static CGFloat NSVectorCross ( NSVector vectorA, NSVector vectorB ) {
    return vectorA.x * vectorB.y - vectorA.y * vectorB.x;
}

static NSVector NSVectorMake ( NSPoint A, NSPoint B ) {
    return NSMakePoint(B.x - A.x, B.y - A.y);
}

static NSVector NSVectorOpossite ( NSVector vector ) {
    return NSMakePoint(-vector.x, -vector.y);
}

static NSVector NSVectorPerp ( NSVector vector ) {
    return NSMakePoint(vector.y, -vector.x);
}

static CGFloat NSVectorSize ( NSVector vector ) {
    return sqrt(NSVectorDot(vector, vector));
}

static NSVector NSVectorNormalize ( NSVector vector ) {
    CGFloat norm = NSVectorSize(vector);
    return NSMakePoint(vector.x / norm, vector.y / norm);
}

static CGFloat NSVectorAngle ( NSVector vector ) {
    return atan2(vector.y, vector.x);
}

static CGFloat NSVectorsAngle ( NSVector vectorA, NSVector vectorB ) {
    return atan2(NSVectorCross(vectorA, vectorB), NSVectorDot(vectorA, vectorB));
}

#endif
