//
//  AHPDataClient+Retreival.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/8/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AHPDataClient.h"

@implementation AHPDataClient (Retreival)

- (NSArray*) getAuctionsForGroup:(NSSet*) connectedRealms;
{
    return nil;
}

- (NSArray*) getAuctionsForGroup:(NSSet*) connectedRealms
                   withPredicate:(NSPredicate*) searchPredicate
{
    return nil;
}

- (NSInteger) getLastModifiedForGroup:(NSSet *)connectedRealms
{
    return 0;
}

- (NSArray*) getRealms
{
    return nil;
}

- (NSDictionary*) getItemForId:(NSInteger) itemId
{
    return nil;
}

- (NSDictionary*) getPetForId:(NSInteger) petId
{
    return nil;
}

- (UIImage*) getImageForName:(NSString*) imageName
{
    return nil;
}

- (UIImage*) getImageForName:(NSString*) imageName
                        size:(AHPImageSize) size
{
    return nil;
}

@end