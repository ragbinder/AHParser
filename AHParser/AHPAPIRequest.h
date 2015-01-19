//
//  AHPAPIRequest.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/12/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

//This APIRequest class, unlike the rest, keeps an internal state instead of having a static method that returns a dictionary. I wanted to keep the data logic in this class instead of the detail view controller, so I put keeping code in area of concern ahead of consistency.

#import <UIKit/UIKit.h>
#import "AHPItemAPIRequest.h"
#import "AHPPetAPIRequest.h"

@interface AHPAPIRequest : UIResponder

//@property (strong, nonatomic) NSString *realm, *slug;
//@property (strong, nonatomic) NSURL *auctionDataURL;
////Last modified is in unix time, in milliseconds
//@property (strong, nonatomic) NSNumber *lastModified;
//@property (strong, nonatomic) NSArray *allianceAuctions, *hordeAuctions, *neutralAuctions;

//This method needs to be called with the API URL, not the data dump URL. This is responsible for fetching the auction data and setting all of the properties of the AHPAPIRequest object.
//- (id)initWithRealmURL: (NSManagedObject*) realmURL inContext:(NSManagedObjectContext*) context;

//This method is the one that stores the auctions in the managed object context. It is designed to be run via GCD from the detail view controller class. This part was taken out of the init method because it takes a long time to run.
//- (void)storeAuctions:(NSManagedObjectContext *)context withProgress:(UIProgressView*) progressBar forFaction:(NSString*)faction;
//-(void) setLastDumpInContext: (NSManagedObjectContext*)context;

//Useful static functions that don't belong in any particular place
+ (NSMutableArray*)findDumpsInContext:(NSManagedObjectContext*)context withSlug:(NSString*)slug;

+ (NSMutableArray *)findDumpsInContext:(NSManagedObjectContext *)context withURL:(NSString *)url;

//This converts the unix time that the API uses to a human-readable time.
+ (NSString*) convertWOWTime:(double)time;
//This formats the time_left field in the auction JSON for display in the detail view controller.
+ (NSString*)timeLeftFormat:(NSInteger)timeLeft;

//New static library functions, similar to how the other API classes function.
+ (NSURL*)auctionDumpURLForSlug:(NSString *)slug;
+ (NSArray*)auctionsForSlug:(NSString *)slug;
+ (NSInteger*)lastModifiedForSlug:(NSString *)slug;

@end
