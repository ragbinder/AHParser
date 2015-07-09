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
#define FAIL ^(AFHTTPRequestOperation *operation, NSError *error) {failureBlock(error);}

@implementation AHPRequestContext
@synthesize parameters;

+ (instancetype)contextWithBaseURL:(NSURL*) baseURL
{
    AHPRequestContext *context = [[super alloc] init];
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
    NSString *parametersString = [NSString stringWithFormat:@"?locale=%@&apikey=%@",parameters[@"locale"],parameters[@"apikey"]];
    NSString *requestString = [kRealmUrl stringByAppendingString:parametersString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [request setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [operation setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject[@"realms"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
    }];
    
    [operation start];
}

- (void) getAuctionsForSlug:(NSString*) slug
                 completion:(auctionCompletion) completionBlock
                    failure:(failureBlock) failureBlock
{
    NSString *parametersString = [NSString stringWithFormat:@"?locale=%@&apikey=%@",parameters[@"locale"],parameters[@"apikey"]];
    NSString *requestString = [[NSString stringWithFormat:kAuctionUrl,slug] stringByAppendingString:parametersString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [request setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [operation setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *auctionsUrl = responseObject[@"files"][0][@"url"];
        
        NSURLRequest *auctionDumpRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:auctionsUrl]];
        AFHTTPRequestOperation *auctionDumpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:auctionDumpRequest];
        [auctionDumpOperation setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [auctionDumpOperation setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [auctionDumpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            completionBlock(responseObject[@"auctions"][@"auctions"]);
        } failure:FAIL];
        
        [auctionDumpOperation start];
    } failure:FAIL];
    
    [operation start];
    
//    ^(NSURLSessionDataTask *task, id response)
//     {
//         NSArray *filesArray = [response valueForKey:@"files"];
//         NSString *auctionURL = filesArray[0][@"url"];
//         [self GET:auctionURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//             completionBlock(responseObject[@"auctions"][@"auctions"]);
//         } failure:FAIL];
//     } failure:FAIL];
}

- (void) getLastModifiedForSlug:(NSString*) slug
                     completion:(lastModifiedCompletion) completionBlock
                        failure:(failureBlock) failureBlock
{
    NSString *parametersString = [NSString stringWithFormat:@"?locale=%@&apikey=%@",parameters[@"locale"],parameters[@"apikey"]];
    NSString *requestString = [[NSString stringWithFormat:kAuctionUrl,slug] stringByAppendingString:parametersString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [request setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [operation setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock([responseObject[@"files"][0][@"lastModified"] intValue]);
    } failure:FAIL];
    
    [operation start];
}

- (void) getItemForId:(NSInteger) itemID
           completion:(itemCompletion) completionBlock
              failure:(failureBlock) failureBlock
{
    NSString *parametersString = [NSString stringWithFormat:@"?locale=%@&apikey=%@",parameters[@"locale"],parameters[@"apikey"]];
    NSString *requestString = [[NSString stringWithFormat:kItemUrl,(long)itemID] stringByAppendingString:parametersString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [request setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [operation setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:FAIL];
    
    [operation start];
}

- (void) getPetForId:(NSInteger) petID
          completion:(petCompletion) completionBlock
             failure:(failureBlock) failureBlock
{
    NSString *parametersString = [NSString stringWithFormat:@"?locale=%@&apikey=%@",parameters[@"locale"],parameters[@"apikey"]];
    NSString *requestString = [[NSString stringWithFormat:kPetUrl,(long)petID] stringByAppendingString:parametersString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [request setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [operation setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:FAIL];
    
    [operation start];
}
@end
