//
//  AHPDataClientTests.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/8/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AHPDataClient.h"

@interface AHPDataClientTests : XCTestCase

@end

@implementation AHPDataClientTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateSharedClient {
    AHPDataClient *sharedClient = [AHPDataClient sharedClient];
    XCTAssertNotNil(sharedClient);
    XCTAssertNotNil([sharedClient context]);
    XCTAssertNotNil([sharedClient manager]);
}

- (void)testCreateRealmsList {
    NSArray *realms;
    
    NSArray *connectedRealms = [AHPDataClient createConnectedRealms:realms];
    
    XCTAssertEqual([connectedRealms count], 16); //There should be 16 connected realm groups, with 3 realms each in the test data.
    XCTFail(@"NYI");
}

#pragma mark - File Storage Tests
- (void)testCacheImage {
    //Delete image from Filesystem & verify not exist
    
    
    //Cache Image call
    NSError *error = nil;
    XCTAssertTrue([[AHPDataClient sharedClient] cacheImage:[UIImage imageWithData:[NSData data]]
                                                   forPath:@"test"
                                                     error:error]);
    XCTAssertNil(error);
    
    //Verify image exists in filesystem
    XCTAssertNotNil([[AHPDataClient sharedClient] getImageForName:@"test"]);
}

- (void)testRetreiveImage {
    //Verify image exist in cache
    
    //Verify image integrity
}

#pragma mark - Core Data Caching Tests
- (void)testCacheItem {
    
}

- (void)testCachePet {
    
}

- (void)testCacheAuction {
    
}
@end