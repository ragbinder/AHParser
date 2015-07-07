//
//  AHPRequestContext.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/6/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//
#warning TODO: add localization using baseurl instead of us.api.battle.net

#import "AHPRequestContext.h"
NSString *const kRealmUrl = @"https://us.api.battle.net/wow/realm/status";
NSString *const kAuctionUrl = @"https://us.api.battle.net/wow/auction/data/%@";
NSString *const kItemUrl = @"https://us.api.battle.net/wow/item/%lu";
NSString *const kPetUrl = @"https://us.api.battle.net/wow/battlePet/species/%lu";
//NSString *const kImageUrl = @"http://us.media.blizzard.com/wow/icons/56/%@.jpg";
#define FAIL ^(NSURLSessionDataTask *task, NSError *error) {failureBlock(error);}

@implementation AHPRequestContext
@synthesize parameters;

+ (instancetype)contextWithBaseURL:(NSURL*) baseURL
{
    AHPRequestContext *context = [[super alloc] initWithBaseURL:baseURL];
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"image/jpeg"];
    return context;
}

+ (instancetype)contextWithBaseURL:(NSURL*) baseURL
                            locale:(NSString*) localePath
{
    AHPRequestContext *context = [AHPRequestContext contextWithBaseURL:baseURL];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"apiKey" ofType:@"plist"];
    NSDictionary *apiDict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *apiKey = apiDict[@"apiKey"];
    
    [context setParameters: @{@"locale" : localePath,
                              @"apikey" : apiKey}];
    
    return context;
}

- (void) getRealmsCompletion:(realmCompletion) completionBlock
                     failure:(failureBlock) failureBlock
{
    [self GET:kRealmUrl parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completionBlock(responseObject[@"realms"]);
      } failure:FAIL];
}

- (void) getAuctionsForSlug:(NSString*) slug
                 completion:(auctionCompletion) completionBlock
                    failure:(failureBlock) failureBlock
{
    NSString *url = [NSString stringWithFormat:kAuctionUrl,slug];
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

- (void) getLastModifiedForSlug:(NSString*) slug
                     completion:(lastModifiedCompletion) completionBlock
                        failure:(failureBlock) failureBlock
{
    NSString *url = [NSString stringWithFormat:kAuctionUrl,slug];
    [self GET:url parameters:parameters
      success:^(NSURLSessionDataTask *task, id response)
     {
         NSArray *filesArray = [response valueForKey:@"files"];
         NSInteger lastModified = [filesArray[0][@"lastModified"] integerValue];
         completionBlock(lastModified);
     } failure:FAIL];
}

- (void) getItemForId:(NSInteger) itemID
           completion:(itemCompletion) completionBlock
              failure:(failureBlock) failureBlock
{
    NSString *url = [NSString stringWithFormat:kItemUrl,itemID];
    [self GET:url parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completionBlock(responseObject);
      } failure:FAIL];
}

- (void) getPetForId:(NSInteger) petID
          completion:(petCompletion) completionBlock
             failure:(failureBlock) failureBlock
{
    NSString *url = [NSString stringWithFormat:kPetUrl,petID];
    [self GET:url parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completionBlock(responseObject);
      } failure:FAIL];
}
@end
