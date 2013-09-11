//
//  AHPAPIRequest.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/12/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPAPIRequest.h"

@implementation AHPAPIRequest
@synthesize lastModified;

//Still need to implement the error and url responses.
-(id) initWithURL:(NSURL *)url
{
    NSLog(@"Initializing APIRequest");
    //Fetch the Location of the auction house data
    NSURLRequest *auctionAPIRequest = [NSURLRequest requestWithURL:url];
    NSData *response = [NSURLConnection sendSynchronousRequest:auctionAPIRequest returningResponse:nil error:nil];
    NSArray *auctionLines = [NSArray arrayWithObject:[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil]];
    NSArray *filesArray = [auctionLines[0] objectForKey:@"files"];
    
    //Store the location of the AH data and the last modified date
    _auctionDataURL = [NSURL URLWithString:[[filesArray objectAtIndex:0] objectForKey:@"url"]];
    lastModified = [[filesArray objectAtIndex:0] objectForKey:@"lastModified"];
    NSTimeInterval epoch = [lastModified doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:epoch/1000];
    
    NSLog(@"Current Time: %@",[NSDate date]);
    NSLog(@"Retreiving Auction Data From: \n%@",_auctionDataURL);
    NSLog(@"Auction Dump Last Generated: \n%@",[NSString stringWithFormat:@"%@",date]);
    
    //Fetch the data from the URL provided by the API
    NSURLRequest *auctionDataRequest = [NSURLRequest requestWithURL:_auctionDataURL];
    NSData *dataResponse = [NSURLConnection sendSynchronousRequest:auctionDataRequest returningResponse:nil error:nil];
    NSDictionary *auctionData = [NSJSONSerialization JSONObjectWithData:dataResponse options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *allianceData = [auctionData objectForKey:@"alliance"];
    NSDictionary *hordeData = [auctionData objectForKey:@"horde"];
    
    //Store the Alliance and Horde Auctions for this server
    _allianceAuctions = [allianceData objectForKey:@"auctions"];
    _hordeAuctions = [hordeData objectForKey:@"auctions"];
    
    return self;
}

-(void) storeAuctions:(NSManagedObjectContext*) context
{
    NSError *error;
    for(NSDictionary *auction in _hordeAuctions)
    {
        NSEntityDescription *description = [NSEntityDescription entityForName:@"Auction" inManagedObjectContext:context];
        NSManagedObject *aucData = [[NSManagedObject alloc] initWithEntity:description insertIntoManagedObjectContext:context];
        //Set the properties of each auction
        [aucData setValue:[auction valueForKey:@"auc"] forKey:@"auc"];
        [aucData setValue:[auction valueForKey:@"bid"] forKey:@"bid"];
        [aucData setValue:[auction valueForKey:@"buyout"] forKey:@"buyout"];
        [aucData setValue:[auction valueForKey:@"item"] forKey:@"item"];
        [aucData setValue:[auction valueForKey:@"owner"] forKey:@"owner"];
        [aucData setValue:[auction valueForKey:@"quantity"] forKey:@"quantity"];
        [aucData setValue:[auction valueForKey:@"rand"] forKey:@"rand"];
        [aucData setValue:[auction valueForKey:@"seed"] forKey:@"seed"];
        [aucData setValue:[auction valueForKey:@"timeLeft"] forKey:@"timeLeft"];
        //Set the item relationship for each auction
        NSFetchRequest *fetchItem = [[NSFetchRequest alloc] init];
        [fetchItem setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:context]];
        [fetchItem setPredicate:[NSPredicate predicateWithFormat:@"itemID == %d",[auction valueForKey:@"item"]]];
        NSArray *fetchedItem = [context executeFetchRequest:fetchItem error:&error];
        if([fetchedItem count] > 0)
        {
            NSLog(@"Auction %@ has item ID %@",[auction valueForKey:@"auc"],[auction valueForKey:@"item"]);
            [aucData setValue:fetchedItem[0] forKey:@"itemID"];
        }
    }
    if(![context save:&error])
    {
        NSLog(@"Error saving context: %@",error);
    }
    
    [self setLastDumpInContext:context];
}

//Call this method to set the Last Dumped date to the current dump generation date (from the JSON), formatted as an NSDate Object. Will remove all other saved dump dates.
-(void) setLastDumpInContext: (NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"AuctionDumpDate" inManagedObjectContext:context]];
    NSError *error = nil;
    NSArray *dates = [context executeFetchRequest:fetchRequest error:&error];
    for(NSManagedObject *date in dates)
    {
        [context deleteObject:date];
    }
    if(![context save:&error])
    {
        NSLog(@"Error Removing Old Dates: %@",error);
    }
    
    
    NSEntityDescription *description = [NSEntityDescription entityForName:@"AuctionDumpDate" inManagedObjectContext:context];
    NSManagedObject *time = [[NSManagedObject alloc] initWithEntity:description insertIntoManagedObjectContext:context];
    [time setValue:[NSNumber numberWithDouble:[lastModified doubleValue]] forKey:@"date"];
    NSLog(@"Last Dump Date set as: %@",[time valueForKey:@"date"]);
}

-(double)getLastDumpInContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"AuctionDumpDate" inManagedObjectContext:context]];
    NSError *error = nil;
    NSArray *dates = [context executeFetchRequest:fetchRequest error:&error];
    if([dates count] > 0)
    {
        return [[dates[0] valueForKey:@"date"] doubleValue];
    }
    else
    {
        NSLog(@"%d dates found",[dates count]);
        return -1;
    }
}

@end
