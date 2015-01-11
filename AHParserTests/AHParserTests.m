//
//  AHParserTests.m
//  AHParserTests
//
//  Created by Steven Jordan Kozmary on 7/23/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHParserTests.h"
#import "AHPAPIRequest.h"
#import "AHPRealmStatusRequest.h"

@implementation AHParserTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}
/*
- (void)testExample
{
    XCTFail(@"Unit tests are not implemented yet in AHParserTests");
}
*/
- (void)testAuctionAPI
{
    
    NSURL *auctionURL = [AHPAPIRequest auctionDumpURLForSlug:@"medivh"];
    XCTAssertNotNil(auctionURL);
    
    NSArray *auctionArray = [AHPAPIRequest auctionsForSlug:@"medivh"];
    XCTAssertGreaterThan([auctionArray count],0);
}

- (void)testRealmStatus
{
    NSArray *realmStatus = [AHPRealmStatusRequest realmStatus];
    XCTAssertGreaterThan([realmStatus count], 0);
}

- (void)testItemAPI
{
    NSDictionary *itemRequest = [AHPItemAPIRequest itemAPIRequest:18803];
    XCTAssertEqual([[itemRequest objectForKey:@"buyPrice"] integerValue], 474384);
}

@end
