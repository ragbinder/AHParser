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
#define DEFAULT_TEST_TIMEOUT 15.0

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

- (void)testGetRealmsAsync {
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:[NSURL URLWithString:@"https://us.api.battle.net/wow/auction/data/"]
                                                                locale:@"en_US"
                                                                apiKey:GETAPIKEY];
    XCTAssertNotNil(context);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"realms API CALL"];
    [context realmsCompletion:^(NSArray *realms) {
        XCTAssertGreaterThan([realms count], 0);
//        [realms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            NSLog(@"FOUND REALM: %@", obj[@"name"]);
//        }];
        [expectation fulfill];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
    [self waitForExpectationsWithTimeout:DEFAULT_TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out");
        }
    }];
}

- (void)testGetAuctionsAsync {
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:[NSURL URLWithString:@"https://us.api.battle.net/wow/auction/data/"]
                                                                locale:@"en_US"
                                                                apiKey:GETAPIKEY];
    XCTAssertNotNil(context);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"auctions API CALL"];
    [context auctionsForSlug:@"medivh"
                  completion:^(NSArray *array) {
                      NSLog(@"%lu auctions found",[array count]);
                      XCTAssertGreaterThan([array count], 0);
                      [expectation fulfill];
                  }
                     failure:^(NSError *error) {
                         NSLog(@"%@",error);
                     }];
    
    [self waitForExpectationsWithTimeout:DEFAULT_TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out");
        }
    }];
}

- (void)testGetLastModifiedAsync
{
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:[NSURL URLWithString:@"https://us.api.battle.net/wow/auction/data/"]
                                                                locale:@"en_US"
                                                                apiKey:GETAPIKEY];
    XCTAssertNotNil(context);

    XCTestExpectation *expectation = [self expectationWithDescription:@"lastmodified API CALL"];
    [context lastModifiedForSlug:@"medivh" completion:^(NSInteger lastModified) {
        XCTAssertGreaterThan(lastModified, 0);
        NSLog(@"Last Modified: %lu",lastModified);
        [expectation fulfill];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
    [self waitForExpectationsWithTimeout:DEFAULT_TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out");
        }
    }];
}

- (void)testGetItemAsync
{
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:[NSURL URLWithString:@"https://us.api.battle.net/wow/auction/data/"]
                                                                locale:@"en_US"
                                                                apiKey:GETAPIKEY];
    XCTAssertNotNil(context);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"item API CALL"];
    [context itemAPIRequest:18803
                 completion:^(NSDictionary *item) {
                     XCTAssertEqual([item[@"id"] integerValue], 18803);
                     [expectation fulfill];
                 }
                    failure:^(NSError *error) {
                        NSLog(@"%@",error);
                    }];
    
    [self waitForExpectationsWithTimeout:DEFAULT_TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out");
        }
    }];
}

- (void)testGetPetAsync
{
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:[NSURL URLWithString:@"https://us.api.battle.net/wow/auction/data/"]
                                                                locale:@"en_US"
                                                                apiKey:GETAPIKEY];
    XCTAssertNotNil(context);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"pet API CALL"];
    [context petAPIRequest:258
                completion:^(NSDictionary *pet) {
                    XCTAssertEqual([pet[@"speciesId"] intValue], 258);
                    [expectation fulfill];
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
    
    [self waitForExpectationsWithTimeout:DEFAULT_TEST_TIMEOUT handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out");
        }
    }];
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
