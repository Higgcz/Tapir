//
//  TSLRoadTest.m
//  TapirApplication
//
//  Created by Vojtech Micka on 07.05.14.
//  Copyright (c) 2014 Vojtech Micka. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TSLRoad.h"
#import "TSLWaypoint.h"

@interface TSLRoadTest : XCTestCase

@end

@implementation TSLRoadTest

- (void) setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testStartPoints
{
    TSLRoad *roadA = [TSLRoad roadWithStart:NSMakePoint(0, 0) andEnd:NSMakePoint(10, 0)];
    XCTAssertTrue(NSEqualPoints(roadA.startPoint, NSMakePoint(0, 0)), @"Start point has to be (0,0)");
    XCTAssertTrue(NSEqualPoints(roadA.endPoint, NSMakePoint(10, 0)), @"Start point has to be (10,0)");
}

- (void) testInterconnection
{
    TSLRoad *roadA = [TSLRoad roadWithStart:NSMakePoint(0, 0) andEnd:NSMakePoint(10, 0)];
    TSLRoad *roadB = [TSLRoad roadWithStart:NSMakePoint(10, 10) andEnd:NSMakePoint(0, 10)];
    TSLRoad *roadC = [TSLRoad roadBetweenRoadObjectA:roadA andRoadObjectB:roadB];
    
    XCTAssertTrue(NSEqualPoints(roadC.startPoint, NSMakePoint(10, 0)), @"Start point of roadC has to be (10,0)");
    XCTAssertTrue(NSEqualPoints(roadC.endPoint, NSMakePoint(10, 10)), @"Start point of roadC has to be (10,10)");
}

@end
