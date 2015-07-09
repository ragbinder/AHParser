//
//  AHPRequestContext.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/6/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

#define GETAPIKEY @""

@interface AHPRequestContext : NSObject
@property NSDictionary* parameters;

typedef void (^realmCompletion)(NSArray* realms);
typedef void (^auctionCompletion)(NSArray* auctions);
typedef void (^lastModifiedCompletion)(NSInteger lastModified);
typedef void (^itemCompletion)(NSDictionary* item);
typedef void (^petCompletion)(NSDictionary* pet);
typedef void (^imageCompletion)(NSData* image);
typedef void (^failureBlock)(NSError* error);

typedef NS_ENUM(NSUInteger, AHPImageSize) {
    AHPImageSizeSmall = 18,
    AHPImageSizeMedium = 38,
    AHPImageSizeLarge = 56
};

+ (instancetype)contextWithBaseURL:(NSURL*) baseURL;

+ (instancetype)contextWithBaseURL:(NSURL*) baseURL
                            locale:(NSString*) localePath;

- (void) getRealmsCompletion:(realmCompletion) completionBlock
                     failure:(failureBlock) failureBlock;

- (void) getAuctionsForSlug:(NSString*) slug
                 completion:(auctionCompletion) completionBlock
                    failure:(failureBlock) failureBlock;

- (void) getLastModifiedForSlug:(NSString*) slug
                     completion:(lastModifiedCompletion) completionBlock
                        failure:(failureBlock) failureBlock;

- (void) getItemForId:(NSInteger) itemID
           completion:(itemCompletion) completionBlock
              failure:(failureBlock) failureBlock;

- (void) getPetForId: (NSInteger) petID
          completion:(petCompletion) completionBlock
             failure:(failureBlock) failureBlock;

- (void) getImageForName:(NSString*) name
                    size:(NSUInteger) size
              completion:(imageCompletion) completionBlock
                 failure:(failureBlock) failureBlock;
@end
