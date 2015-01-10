//
//  AHPRealmStatusRequest.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 10/14/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPRealmStatusRequest.h"

@implementation AHPRealmStatusRequest

+(NSArray*) realmStatus
{
    NSString *locale = [[NSUserDefaults standardUserDefaults] stringForKey:@"locale"];
    if(!locale){
        locale = @"us.api.battle.net";
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/wow/realm/status?locale=en_US&apikey=8garu7z6rtewtep4zabznubprejp6w67",locale]];
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
