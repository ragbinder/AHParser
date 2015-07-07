//
//  AHPRequestContext.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/6/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

#define GETAPIKEY @"8garu7z6rtewtep4zabznubprejp6w67"

@interface AHPRequestContext : AFHTTPSessionManager
@property NSDictionary* parameters;

typedef void (^realmCompletion)(NSArray* realms);
typedef void (^auctionCompletion)(NSArray* auctions);
typedef void (^lastModifiedCompletion)(NSInteger lastModified);
typedef void (^itemCompletion)(NSDictionary* item);
typedef void (^petCompletion)(NSDictionary* pet);
typedef void (^imageCompletion)(NSData* image);
typedef void (^failureBlock)(NSError* error);

+ (instancetype)contextWithBaseURL:(NSURL*)baseURL;

+ (instancetype)contextWithBaseURL:(NSURL*)baseURL
                            locale:(NSString*)localePath
                            apiKey:(NSString*)apiKey;

- (void) realmsCompletion:(realmCompletion) completionBlock
                  failure:(failureBlock) failureBlock;

- (void) auctionsForSlug:(NSString*) slug
              completion:(auctionCompletion) completionBlock
                 failure:(failureBlock) failureBlock;

- (void) lastModifiedForSlug:(NSString*) slug
                  completion:(lastModifiedCompletion) completionBlock
                     failure:(failureBlock) failureBlock;

- (void) itemAPIRequest:(NSInteger) itemID
             completion:(itemCompletion) completionBlock
                failure:(failureBlock) failureBlock;

- (void) petAPIRequest: (NSInteger) petID
            completion:(petCompletion) completionBlock
               failure:(failureBlock) failureBlock;
@end
