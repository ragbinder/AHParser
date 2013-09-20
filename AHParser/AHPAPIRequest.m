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
    NSLog(@"Initializing APIRequest with URL: %@",url);
    //Fetch the Location of the auction house data
    NSURLRequest *auctionAPIRequest = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:auctionAPIRequest returningResponse:nil error:&error];
    if(response)
    {
        NSArray *auctionLines = [NSArray arrayWithObject:[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil]];
        NSArray *filesArray = [auctionLines[0] objectForKey:@"files"];
        
        //Store the location of the AH data and the last modified date
        _auctionDataURL = [NSURL URLWithString:[[filesArray objectAtIndex:0] objectForKey:@"url"]];
        lastModified = [[filesArray objectAtIndex:0] objectForKey:@"lastModified"];
        //NSDate *date = [AHPAPIRequest convertWOWTime: [lastModified doubleValue]];
        /*
        NSLog(@"Current Time: %@",[NSDate date]);
        NSLog(@"Retreiving Auction Data From: \n%@",_auctionDataURL);
        NSLog(@"Auction Dump Last Generated: \n%@",[NSString stringWithFormat:@"%@",date]);
        */
        //Fetch the data from the URL provided by the API
        NSMutableURLRequest *auctionDataRequest = [NSURLRequest requestWithURL:_auctionDataURL];
        //[auctionDataRequest setHTTPMethod:@"POST"];
        NSData *dataResponse = [NSURLConnection sendSynchronousRequest:auctionDataRequest returningResponse:nil error:&error];
        if(dataResponse)
        {
            NSDictionary *auctionData = [NSJSONSerialization JSONObjectWithData:dataResponse options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *allianceData = [auctionData objectForKey:@"alliance"];
            NSDictionary *hordeData = [auctionData objectForKey:@"horde"];
            
            //Store the Alliance and Horde Auctions for this server
            _allianceAuctions = [allianceData objectForKey:@"auctions"];
            _hordeAuctions = [hordeData objectForKey:@"auctions"];
            
            return self;
        }
        else
        {
            NSLog(@"Error getting data from web dump: %@ \n %@",auctionDataRequest, error);
            return self;
        }
    }
    else
    {
        NSLog(@"Error getting data from web API: %@",error);
        return self;
    }
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
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID == %d",[[auction valueForKey:@"item"] intValue]];
        NSLog(@"%@",predicate);
        [fetchItem setEntity:entity];
        [fetchItem setPredicate:predicate];
        NSArray *fetchedItem = [context executeFetchRequest:fetchItem error:&error];
        if([fetchedItem count] > 0)
        {
            NSLog(@"Auction %@ has item ID %@",[auction valueForKey:@"auc"],[auction valueForKey:@"item"]);
            [aucData setValue:fetchedItem[0] forKey:@"itemRelationship"];
        }
        else
        {
            //NSLog(@"Could not find item in database for ID: %d",[[auction valueForKey:@"item"] intValue]);
        }
        if(error)
        {
            NSLog(@"Error linking Item ID: %@",error);
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
    NSLog(@"Last Dump Date set as: %@",[AHPAPIRequest convertWOWTime: [lastModified doubleValue]]);
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

//This function converts the time number given by the wow server to an NSDate object, so that it's human-readable. The wow API returns times in unix time (seconds since 1/1/1970), in milliseconds.
+(NSDate*) convertWOWTime:(double)time
{
    return [NSDate dateWithTimeIntervalSince1970:time/1000];
}

@end
