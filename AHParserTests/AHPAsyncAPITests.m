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

NSInteger const kDefaultTestTimeout = 15.0;

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
                                                                locale:@"en_US"];
    XCTAssertNotNil(context);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"realms API CALL"];
    [context getRealmsCompletion:^(NSArray *realms) {
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertGreaterThan([realms count], 0);
        [expectation fulfill];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
    [self waitForExpectationsWithTimeout:kDefaultTestTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out: %@",error);
        }
    }];
}

- (void)testGetAuctionsAsync {
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:[NSURL URLWithString:@"https://us.api.battle.net/wow/auction/data/"]
                                                                locale:@"en_US"];
    XCTAssertNotNil(context);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"auctions API CALL"];
    [context getAuctionsForSlug:@"medivh"
                     completion:^(NSArray *array) {
                         XCTAssertFalse([NSThread isMainThread]);
                         NSLog(@"%d auctions found",[array count]);
                         XCTAssertGreaterThan([array count], 0);
                         [expectation fulfill];
                     }
                        failure:^(NSError *error) {
                            NSLog(@"%@",error);
                        }];
    
    [self waitForExpectationsWithTimeout:kDefaultTestTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out");
        }
    }];
}

- (void)testGetLastModifiedAsync
{
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:[NSURL URLWithString:@"https://us.api.battle.net/wow/auction/data/"]
                                                                locale:@"en_US"];
    XCTAssertNotNil(context);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"lastmodified API CALL"];
    [context getLastModifiedForSlug:@"medivh" completion:^(NSInteger lastModified) {
        XCTAssertGreaterThan(lastModified, 0);
        XCTAssertFalse([NSThread isMainThread]);
        NSLog(@"Last Modified: %lu",(long)lastModified);
        [expectation fulfill];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
    [self waitForExpectationsWithTimeout:kDefaultTestTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out");
        }
    }];
}

- (void)testGetItemAsync
{
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:[NSURL URLWithString:@"https://us.api.battle.net/wow/auction/data/"]
                                                                locale:@"en_US"];
    XCTAssertNotNil(context);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"item API CALL"];
    [context getItemForId:18803
               completion:^(NSDictionary *item) {
                   XCTAssertEqual([item[@"id"] integerValue], 18803);
                   XCTAssertFalse([NSThread isMainThread]);
                   [expectation fulfill];
               }
                  failure:^(NSError *error) {
                      NSLog(@"%@",error);
                  }];
    
    [self waitForExpectationsWithTimeout:kDefaultTestTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out");
        }
    }];
}

- (void)testGetPetAsync
{
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:[NSURL URLWithString:@"https://us.api.battle.net/wow/auction/data/"]
                                                                locale:@"en_US"];
    XCTAssertNotNil(context);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"pet API CALL"];
    [context getPetForId:258
              completion:^(NSDictionary *pet) {
                  XCTAssertEqual([pet[@"speciesId"] intValue], 258);
                  XCTAssertFalse([NSThread isMainThread]);
                  [expectation fulfill];
              } failure:^(NSError *error) {
                  NSLog(@"%@",error);
              }];
    
    [self waitForExpectationsWithTimeout:kDefaultTestTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out");
        }
    }];
}

- (void)testGetImageAsync
{
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:nil];
    XCTAssertNotNil(context);
    
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ability_mount_rocketmount" ofType:@"jpg"];
    __block NSData *expectedResponse = [NSData dataWithContentsOfFile:filePath];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"image fetch"];
    [context getImageForName:@"ability_mount_rocketmount"
                        size:AHPImageSizeLarge
                  completion:^(NSData *image) {
                      XCTAssertNotNil(image);
                      XCTAssertFalse([NSThread isMainThread]);
                      XCTAssertTrue([image isEqualToData:expectedResponse]);
                      [expectation fulfill];
    }
                     failure:^(NSError *error) {
                         XCTFail(@"Error: %@",error);
                     }];
    
    [self waitForExpectationsWithTimeout:kDefaultTestTimeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timed out: %@",error);
        }
    }];
}

- (void)testImageSizes
{
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:nil];
    XCTAssertNotNil(context);
    
    NSUInteger MAX_CONCURRENT_REQUESTS = 64;
    dispatch_semaphore_t sem = dispatch_semaphore_create(MAX_CONCURRENT_REQUESTS);
    dispatch_group_t requestGroup = dispatch_group_create();
    __block NSUInteger completedRequests = 0;
    id syncToken;
    
    for (NSUInteger i = 1; i <= 200; i++) {
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_group_enter(requestGroup);
        [context getImageForName:@"ability_mount_rocketmount"
                            size:i
                      completion:^(NSData *image) {
                          NSLog(@"Image for size %lu",(unsigned long)i);
                          @synchronized(syncToken)
                          {
                              completedRequests++;
                          }
                          dispatch_semaphore_signal(sem);
                          dispatch_group_leave(requestGroup);
                      } failure:^(NSError *error) {
//                          NSLog(@"No Image for Size: %lu",(unsigned long)i);
                          @synchronized(syncToken)
                          {
                              completedRequests++;
                          }
                          dispatch_semaphore_signal(sem);
                          dispatch_group_leave(requestGroup);
                      }];
    }
    
    dispatch_group_wait(requestGroup, DISPATCH_TIME_FOREVER);
    XCTAssertEqual(completedRequests, 200);
}

@end
