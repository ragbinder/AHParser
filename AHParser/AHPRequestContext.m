//
//  AHPRequestContext.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/6/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPRequestContext.h"
#define BNETURL @"https://us.api.battle.net/wow/auction/data/%@"

@implementation AHPRequestContext
@synthesize parameters;

+ (instancetype)contextWithBaseURL:(NSURL*)baseURL
{
    AHPRequestContext *context = [[super alloc] initWithBaseURL:baseURL];
    
    return context;
}

+ (instancetype)contextWithBaseURL:(NSURL*)baseURL
                            locale:(NSString*)localePath
                            apiKey:(NSString*)apiKey
{
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:baseURL];
    [context setParameters: @{@"locale" : localePath,
                              @"apikey" : apiKey}];
    
    return context;
}

- (void) auctionsForSlug:(NSString*) slug
              completion:(auctionCompletion) completionBlock
{
    NSString *url = [NSString stringWithFormat:BNETURL,slug];
    [self GET:url
   parameters:parameters
      success:^(NSURLSessionDataTask *task, id response)
     {
         completionBlock(response);
     }
      failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"Error: %@",error);
     }];
}

- (void) lastModifiedForSlug:(NSString*) slug
                  completion:(lastModifiedCompletion) completionBlock
{
    
}

- (void) itemAPIRequest:(NSInteger) itemID
             completion:(itemCompletion) completionBlock
{
    
}

- (void) petAPIRequest: (NSInteger) petID
            completion:(petCompletion) completionBlock
{
    
}

- (void)imageRequestWithPath:(NSString *) path
                  completion:(NSData*) completionBlock
{
    
}
@end
