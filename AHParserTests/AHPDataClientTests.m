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
#import "AHPRequestContext.h"

@interface AHPDataClientTests : XCTestCase
@property AHPRequestContext *context;
@end

@implementation AHPDataClientTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _context = [AHPRequestContext contextWithBaseURL:nil locale:@"en_US"];
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
    __block NSArray *testRealms = nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    [_context getRealmsCompletion:^(NSArray *realms) {
        testRealms = realms;
        dispatch_semaphore_signal(sem);
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        dispatch_semaphore_signal(sem);
    }];
    
    dispatch_semaphore_wait(sem,DISPATCH_TIME_FOREVER);
    
    NSSet *connectedRealms = [AHPDataClient createConnectedRealms:testRealms];
    
    XCTAssertEqual([testRealms count], 246);
    XCTAssertEqual([connectedRealms count], 120); //There are currently 120 connected realm groups
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