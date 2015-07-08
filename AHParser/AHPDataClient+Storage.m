//
//  AHPDataClient+Storage.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/8/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AHPDataClient.h"

@implementation AHPDataClient (Storage)

- (BOOL) cacheAuction:(NSDictionary*) auction
                error:(NSError*)error
{
    return NO;
}

- (BOOL) cacheRealmList:(NSArray*) realmList
                  error:(NSError*)error
{
    return NO;
}

- (BOOL) cacheItem:(NSDictionary*) item forId:(NSInteger) itemId
             error:(NSError*)error
{
    return NO;
}

- (BOOL) cachePet:(NSDictionary*) pet forId:(NSInteger) petId
            error:(NSError*)error
{
    return NO;
}

- (BOOL) cacheImage:(UIImage*) image forPath:(NSString*) path
              error:(NSError*)error
{
    return NO;
}

@end