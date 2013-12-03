//
//  AHPPetAPIRequest.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 11/21/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPPetAPIRequest.h"

@implementation AHPPetAPIRequest

+(NSDictionary*)petAPIRequest:(NSInteger)speciesID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://us.battle.net/api/wow/battlePet/species/%d",speciesID]];
    //NSLog(@"Initializing ItemAPIRequest with url: %@", url);
    
    NSURLRequest *petAPIRequest = [[NSURLRequest alloc] initWithURL:url];
    
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:petAPIRequest returningResponse:nil error:&error];
    //NSLog(@"Response: %@",response);
    if(response)
    {
        //Return a dictionary that has all of the item data in it.
        NSDictionary *petDictionary = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        return petDictionary;
    }
    else
    {
        NSLog(@"Error retreiving data from Item API: %@",error);
        return nil;
    }
}

@end
