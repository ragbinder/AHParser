//
//  AHPRequestContext.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/6/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

#define GETAPIKEY [[[NSProcessInfo processInfo] environment] objectForKey:@"apiKey"]

@interface AHPRequestContext : AFHTTPSessionManager
@property NSDictionary* parameters;

typedef void (^auctionCompletion)(NSArray*);
typedef void (^lastModifiedCompletion)(NSInteger);
typedef void (^itemCompletion)(NSDictionary*);
typedef void (^petCompletion)(NSDictionary*);

+ (instancetype)contextWithBaseURL:(NSURL*)baseURL;

+ (instancetype)contextWithBaseURL:(NSURL*)baseURL
                            locale:(NSString*)localePath
                            apiKey:(NSString*)apiKey;

- (void) auctionsForSlug:(NSString*) slug
              completion:(auctionCompletion) completionBlock;

- (void) lastModifiedForSlug:(NSString*) slug
                  completion:(lastModifiedCompletion) completionBlock;

- (void) itemAPIRequest:(NSInteger) itemID
             completion:(itemCompletion) completionBlock;

- (void) petAPIRequest: (NSInteger) petID
            completion:(petCompletion) completionBlock;

- (void)imageRequestWithPath:(NSString *) path
                  completion:(NSData*) completionBlock;
@end
