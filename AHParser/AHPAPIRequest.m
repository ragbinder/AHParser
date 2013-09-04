//
//  AHPAPIRequest.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/12/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPAPIRequest.h"

@implementation AHPAPIRequest

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
    _lastModified = [[filesArray objectAtIndex:0] objectForKey:@"lastModified"];
    NSTimeInterval epoch = [_lastModified doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:epoch/1000];
    
    NSLog(@"%@",[NSDate date]);
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
        [aucData setValue:[auction valueForKey:@"auc"] forKey:@"auc"];
        [aucData setValue:[auction valueForKey:@"bid"] forKey:@"bid"];
        [aucData setValue:[auction valueForKey:@"buyout"] forKey:@"buyout"];
        [aucData setValue:[auction valueForKey:@"item"] forKey:@"item"];
        [aucData setValue:[auction valueForKey:@"owner"] forKey:@"owner"];
        [aucData setValue:[auction valueForKey:@"quantity"] forKey:@"quantity"];
        [aucData setValue:[auction valueForKey:@"rand"] forKey:@"rand"];
        [aucData setValue:[auction valueForKey:@"seed"] forKey:@"seed"];
        [aucData setValue:[auction valueForKey:@"timeLeft"] forKey:@"timeLeft"];
        /*
        if(![context save:&error])
        {
            NSLog(@"Error saving context: %@",error);
        }
        */
    }
    if(![context save:&error])
    {
        NSLog(@"Error saving context: %@",error);
    }
}

@end
