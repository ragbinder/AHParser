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
    //Used to track consumption of battle.net API.
    NSLog(@"MAKING PET API REQUEST");
    
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

+ (NSManagedObject*)storePet:(NSInteger) petID
                   inContext:(NSManagedObjectContext*) context
{
    NSDictionary *petDictionary = [self petAPIRequest:petID];
    NSEntityDescription *pet = [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:context];
    NSError *error;
    NSManagedObject *petData = [[NSManagedObject alloc] initWithEntity:pet insertIntoManagedObjectContext:context];
    
    [petData setValue:[petDictionary valueForKey:@"speciesId"] forKey:@"speciesID"];
    [petData setValue:[petDictionary valueForKey:@"petTypeId"] forKey:@"petTypeID"];
    [petData setValue:[petDictionary valueForKey:@"breedId"] forKey:@"breedID"];
    [petData setValue:[petDictionary valueForKey:@"icon"] forKey:@"icon"];
    [petData setValue:[petDictionary valueForKey:@"name"] forKey:@"name"];
    
    if(![context save:&error])
    {
        NSLog(@"Error saving new pet %d: %@",petID, error);
    }
    NSLog(@"Saved Pet Data for %d: %@",petID,petData);
    return petData;
}

@end
