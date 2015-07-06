//
//  AHPRequestContext.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/6/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface AHPRequestContext : AFHTTPSessionManager
@property NSDictionary* parameters;

typedef void (^auctionCompletion)(NSArray*);
typedef void (^lastModifiedCompletion)(NSInteger);
typedef void (^itemCompletion)(NSDictionary*);
typedef void (^petCompletion)(NSDictionary*);

+ (instancetype)contextWithAPIKey:(NSString*) apiKey
                       localePath:(NSString*) localePath;

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
