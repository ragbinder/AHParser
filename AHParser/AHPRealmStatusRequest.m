//
//  AHPRealmStatusRequest.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 10/14/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPRealmStatusRequest.h"

@implementation AHPRealmStatusRequest

//Will return an array of dictionaries that represent realm status.
+(NSArray*) realmStatus
{
    NSURL *url = [NSURL URLWithString:@"http://us.battle.net/api/wow/realm/status"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    NSURLResponse *urlResponse;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if(error)
    {
        NSLog(@"Error retreiving realm status: %@",error);
        return nil;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&error];
    if(error)
    {
        NSLog(@"Error parsing realm status: %@",error);
        return nil;
    }
    
    return [dictionary objectForKey:@"realms"];
}

@end
