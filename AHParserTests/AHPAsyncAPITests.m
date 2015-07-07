//
//  AHPAsyncAPITests.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/6/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AHPRequestContext.h"

@interface AHPAsyncAPITests : XCTestCase

@end

@implementation AHPAsyncAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetDumpURLAsync {
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:[NSURL URLWithString:@"https://us.api.battle.net/wow/auction/data/"]
                                                                locale:@"en_US"
                                                                apiKey:GETAPIKEY];
    XCTAssertNotNil(context);
    XCTestExpectation *expectation = [self expectationWithDescription:@"API CALL"];
    [context auctionsForSlug:@"medivh" completion:^(NSArray *array) {
        NSLog(@"%@",array);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out");
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
