//
//  AHPItemAPIRequest.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/26/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPItemAPIRequest.h"

@implementation AHPItemAPIRequest

+(NSDictionary*) itemAPIRequest: (NSInteger) itemID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://us.battle.net/api/wow/item/%d",itemID]];
    //NSLog(@"Initializing ItemAPIRequest with url: %@", url);
    
    NSURLRequest *itemAPIRequest = [[NSURLRequest alloc] initWithURL:url];
    
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:itemAPIRequest returningResponse:nil error:&error];
    //NSLog(@"Response: %@",response);
    if(response)
    {
        //Return a dictionary that has all of the item data in it.
        NSDictionary *itemDictionary = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        return itemDictionary;
    }
    else
    {
        NSLog(@"Error retreiving data from Item API: %@",error);
        return nil;
    }
}

+ (NSManagedObject*)storeItem:(NSInteger) itemID inContext:(NSManagedObjectContext*) context
{
    NSDictionary *itemDictionary = [self itemAPIRequest:itemID];
    NSEntityDescription *item = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    NSError *error;
    NSManagedObject *itemData = [[NSManagedObject alloc] initWithEntity:item insertIntoManagedObjectContext:context];
    [itemData setValue:[itemDictionary valueForKey:@"itemClass"] forKey:@"itemClass"];
    [itemData setValue:[itemDictionary valueForKey:@"id"] forKey:@"itemID"];
    [itemData setValue:[itemDictionary valueForKey:@"itemLevel"] forKey:@"itemLevel"];
    [itemData setValue:[itemDictionary valueForKey:@"itemSubClass"] forKey:@"itemSubClass"];
    [itemData setValue:[itemDictionary valueForKey:@"name"] forKey:@"name"];
    [itemData setValue:[itemDictionary valueForKey:@"quality"] forKey:@"quality"];
    [itemData setValue:[itemDictionary valueForKey:@"requiredLevel"] forKey:@"requiredLevel"];
    [itemData setValue:[itemDictionary valueForKey:@"icon"] forKey:@"icon"];
    [itemData setValue:[itemDictionary valueForKey:@"inventoryType"] forKey:@"inventoryType"];
    if(![context save:&error])
    {
        NSLog(@"Error saving new item %d: %@",itemID, error);
    }
    return itemData;
}

@end
