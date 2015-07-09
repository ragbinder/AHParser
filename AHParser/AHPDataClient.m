//
//  AHPDataClient.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/8/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPDataClient.h"

@implementation AHPDataClient
@synthesize context,manager;

+ (instancetype) sharedClient
{
    static dispatch_once_t onceToken;
    static AHPDataClient *sharedClient = nil;
    dispatch_once(&onceToken, ^{
        sharedClient = [[AHPDataClient alloc] init];
    });
    return sharedClient;
}

+ (NSSet*) createConnectedRealms:(NSArray *)realms
{
    NSMutableSet *connectedRealms = [[NSMutableSet alloc] init];
    
    [realms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSSet *connectedRealmsForRealm = [NSSet setWithArray:[obj valueForKey:@"connected_realms"]];
        [connectedRealms addObject:connectedRealmsForRealm];
    }];
    
    return connectedRealms;
}

@end