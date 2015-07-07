//
//  AHPRealmStatusRequest.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 10/14/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPRealmStatusRequest.h"
#import "AHPRequestContext.h"

@implementation AHPRealmStatusRequest

+(NSArray*) realmStatus
{
    NSString *locale = [[NSUserDefaults standardUserDefaults] stringForKey:@"locale"];
    if(!locale){
        locale = @"en_US";
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://us.api.battle.net/wow/realm/status?locale=%@&apikey=%@",locale,GETAPIKEY]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
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
