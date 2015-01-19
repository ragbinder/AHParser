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
#import "AHPImageRequest.h"

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
    NSLog(@"%zd auctions found for URL: %@",[auctionArray count],auctionURL);
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

- (void)testImageAPI
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",@"inv_gizmo_02"]];
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:localFilePath error:&error]) {
            XCTFail(@"Could not delete file!");
        }
        XCTAssertNil(error);
    }
    
    UIImage *image = [AHPImageRequest imageWithName:@"inv_gizmo_02"];
    NSLog(@"%@",image);
    XCTAssertNotNil(image);
    
    UIImage *localImage = [AHPImageRequest localImageWithName:@"inv_gizmo_02"];
    XCTAssertNil(localImage);
    
    XCTAssertTrue([AHPImageRequest saveImageWithName:@"inv_gizmo_02"]);
    
    localImage = [AHPImageRequest localImageWithName:@"inv_gizmo_02"];
    XCTAssertNotNil(localImage);
}

@end
