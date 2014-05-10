//
//  TSLPathTest.m
//  TapirApplication
//
//  Created by Vojtech Micka on 10.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TSLPath.h"

@interface TSLPathTest : XCTestCase

@end

@implementation TSLPathTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testCrossConnectionOfPathSimple
{
    TSLPath *pathBase = [TSLPath pathFromPoint:NSMakePoint(0, 0) toPoint:NSMakePoint(10, 0)];

    TSLPath *pathA = [TSLPath pathFromPoint:NSMakePoint(5, 5) toPoint:NSMakePoint(5, -5)];
    
    [pathBase addCrossConnectedPath:[NSSet setWithObject:pathA]];
    
    XCTAssertEqual([pathBase indexForConnectedPath:pathA], 5, @"Index of connected path should be 5.");
    XCTAssertEqual([pathA indexForConnectedPath:pathBase], 5, @"Index of connected path should be 5.");
}

- (void) testCrossConnectionOfPathMore
{
    TSLPath *pathBase = [TSLPath pathFromPoint:NSMakePoint(0, 0) toPoint:NSMakePoint(10, 0)];
    
    // First path
    TSLPath *pathA = [TSLPath pathFromPoint:NSMakePoint(5, 5) toPoint:NSMakePoint(5, -5)];
    
    [pathBase addCrossConnectedPath:[NSSet setWithObject:pathA]];
    
    XCTAssertEqual([pathBase indexForConnectedPath:pathA], 5, @"Index of connected path should be 5.");
    XCTAssertEqual([pathA indexForConnectedPath:pathBase], 5, @"Index of connected path should be 5.");
    
    // Second path
    TSLPath *pathB = [TSLPath pathFromPoint:NSMakePoint(10, 4) toPoint:NSMakePoint(3, -3)];
    
    [pathBase addCrossConnectedPath:[NSSet setWithObject:pathB]];
    
    XCTAssertEqual([pathBase indexForConnectedPath:pathB], 6, @"Index of connected path should be 6.");
    XCTAssertEqual([pathB indexForConnectedPath:pathBase], 5, @"Index of connected path should be 5.");
}

@end
