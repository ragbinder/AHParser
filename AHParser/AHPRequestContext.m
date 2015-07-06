//
//  AHPRequestContext.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/6/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPRequestContext.h"
#define BNETURL @"sldflasn"

@implementation AHPRequestContext
@synthesize parameters;

+ (instancetype)contextWithAPIKey:(NSString*) apiKey
                       localePath:(NSString*) localePath
{
    AHPRequestContext *context = [[AHPRequestContext alloc] init];
    [context setParameters: @{@"locale" : localePath,
                              @"apikey" : apiKey}];
    
    return context;
}

- (void) auctionsForSlug:(NSString*) slug
              completion:(auctionCompletion) completionBlock
{
//    [self GET:<#(NSString *)#>
//   parameters:[self parameters]
//      success:<#^(NSURLSessionDataTask *task, id responseObject)success#>
//      failure:<#^(NSURLSessionDataTask *task, NSError *error)failure#>];
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
