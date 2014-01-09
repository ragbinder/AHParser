//
//  AHPAPIRequest.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/12/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

//This APIRequest class, unlike the rest, keeps an internal state instead of having a static method that returns a dictionary. I wanted to keep the data logic in this class instead of the detail view controller, so I put keeping code in area of concern ahead of consistency.
//I should rewrite this code to be more consistent with the rest of the classes later (more like APIItemRequest)

#import <UIKit/UIKit.h>
#import "AHPItemAPIRequest.h"

@interface AHPAPIRequest : UIResponder

@property (strong, nonatomic) NSURL *auctionDataURL;
//Last modified is in unix time, in milliseconds
@property (strong, nonatomic) NSNumber *lastModified;
@property (strong, nonatomic) NSString *realm, *slug, *faction;
@property (strong, nonatomic) NSArray *allianceAuctions, *hordeAuctions, *neutralAuctions;
//@property (strong, nonatomic) NSMutableArray *realmsInGroup;

//This method needs to be called with the API URL, not the data dump URL. This is responsible for fetching the auction data and setting all of the properties of the AHPAPIRequest object.
- (id) initWithURL: (NSURL*) url;
//This method is the one that stores the auctions in the managed object context. It is designed to be run via GCD from the detail view controller class.
- (void) storeAuctions:(NSManagedObjectContext *)context withProgress:(UIProgressView*) progressBar forFaction:(NSString*)faction;
//-(void) setLastDumpInContext: (NSManagedObjectContext*)context;
+ (NSMutableArray*)findDumpsInContext:(NSManagedObjectContext*)context WithURL:(NSString*)dumpURL forFaction:(NSString*)faction;
//This converts the unix time that the API uses to a human-readable time.
+ (NSString*) convertWOWTime:(double)time;
//This formats the time_left field in the auction JSON for display in the detail view controller.
+ (NSString*)timeLeftFormat:(NSString*)timeLeft;

@end
