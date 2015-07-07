//
//  AHPRequestContext.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/6/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//
#warning TODO: add localization using baseurl instead of us.api.battle.net

#import "AHPRequestContext.h"
#define REALMURL @"https://us.api.battle.net/wow/realm/status"
#define AUCTIONURL @"https://us.api.battle.net/wow/auction/data/%@"
#define ITEMURL @"https://us.api.battle.net/wow/item/%lu"
#define PETURL @"https://us.api.battle.net/wow/battlePet/species/%lu"
#define IMAGEURL @"http://us.media.blizzard.com/wow/icons/56/%@.jpg"
#define FAIL ^(NSURLSessionDataTask *task, NSError *error) {failureBlock(error);}

@implementation AHPRequestContext
@synthesize parameters;

+ (instancetype)contextWithBaseURL:(NSURL*)baseURL
{
    AHPRequestContext *context = [[super alloc] initWithBaseURL:baseURL];
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"image/jpeg"];
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

- (void) realmsCompletion:(realmCompletion)completionBlock
                  failure:(failureBlock)failureBlock
{
    [self GET:REALMURL parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completionBlock(responseObject[@"realms"]);
      } failure:FAIL];
}

- (void) auctionsForSlug:(NSString*) slug
              completion:(auctionCompletion) completionBlock
                 failure:(failureBlock)failureBlock
{
    NSString *url = [NSString stringWithFormat:AUCTIONURL,slug];
    [self GET:url parameters:parameters
      success:^(NSURLSessionDataTask *task, id response)
     {
         NSArray *filesArray = [response valueForKey:@"files"];
         NSString *auctionURL = filesArray[0][@"url"];
         [self GET:auctionURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
             completionBlock(responseObject[@"auctions"][@"auctions"]);
         } failure:FAIL];
     } failure:FAIL];
}

- (void) lastModifiedForSlug:(NSString*) slug
                  completion:(lastModifiedCompletion) completionBlock
                     failure:(failureBlock)failureBlock
{
    NSString *url = [NSString stringWithFormat:AUCTIONURL,slug];
    [self GET:url parameters:parameters
      success:^(NSURLSessionDataTask *task, id response)
     {
         NSArray *filesArray = [response valueForKey:@"files"];
         NSInteger lastModified = [filesArray[0][@"lastModified"] integerValue];
         completionBlock(lastModified);
     } failure:FAIL];
}

- (void) itemAPIRequest:(NSInteger) itemID
             completion:(itemCompletion) completionBlock
                failure:(failureBlock)failureBlock
{
    NSString *url = [NSString stringWithFormat:ITEMURL,itemID];
    [self GET:url parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completionBlock(responseObject);
    } failure:FAIL];
}

- (void) petAPIRequest: (NSInteger) petID
            completion:(petCompletion) completionBlock
               failure:(failureBlock)failureBlock
{
    NSString *url = [NSString stringWithFormat:PETURL,petID];
    [self GET:url parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completionBlock(responseObject);
      } failure:FAIL];
}
@end
