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


-(id) initWithURL:(NSURL *)url
{
    //NSLog(@"Initializing APIRequest with URL: %@",url);
    //Fetch the Location of the auction house data
    NSURLRequest *auctionAPIRequest = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    NSURLResponse *urlResponse;
    NSData *response = [NSURLConnection sendSynchronousRequest:auctionAPIRequest returningResponse:&urlResponse error:&error];
    if(response)
    {
        NSArray *auctionLines = [NSArray arrayWithObject:[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil]];
        NSArray *filesArray = [auctionLines[0] objectForKey:@"files"];
        
        //Store the location of the AH data and the last modified date
        _auctionDataURL = [NSURL URLWithString:[[filesArray objectAtIndex:0] objectForKey:@"url"]];
        NSLog(@"Retrieving Auction Cache from: %@",_auctionDataURL);
        lastModified = [[filesArray objectAtIndex:0] objectForKey:@"lastModified"];
        
        //Fetch the data from the URL provided by the API
        NSMutableURLRequest *auctionDataRequest = [NSURLRequest requestWithURL:_auctionDataURL];
        NSHTTPURLResponse *APIResponse = [[NSHTTPURLResponse alloc] init];
        NSData *dataResponse = [NSURLConnection sendSynchronousRequest:auctionDataRequest returningResponse:&APIResponse error:&error];
        
        //If the APIRequest received an answer
        if([APIResponse statusCode] == 200)
        {
            NSLog(@"%ld",(long)[APIResponse statusCode]);
            if(dataResponse)
            {
                NSDictionary *auctionData = [NSJSONSerialization JSONObjectWithData:dataResponse options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *allianceData = [auctionData objectForKey:@"alliance"];
                NSDictionary *hordeData = [auctionData objectForKey:@"horde"];
                NSDictionary *neutralData = [auctionData objectForKey:@"neutral"];
                
                //Store the Alliance and Horde Auctions for this server
                _allianceAuctions = [allianceData objectForKey:@"auctions"];
                _hordeAuctions = [hordeData objectForKey:@"auctions"];
                _neutralAuctions = [neutralData objectForKey:@"auctions"];
                
                NSLog(@"Data Stored Successfully");
                
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
            NSLog(@"Error in API Request to Auction House: %d",[APIResponse statusCode]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"API Error" message:@"The Auction API returned error code 404. Please try again later." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return self;
        }
    }
    else
    {
        NSLog(@"Error getting data from web API: %@",error);
        return self;
    }
}

-(void) storeAuctions:(NSManagedObjectContext *)context1 withProgress:(UIProgressView *)progressBar forFaction:(NSString *)faction
{
    //Unhide the progress bar. Hide the Displaying label.
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [progressBar setHidden:NO];
    });
    
    NSError *error;
    
    NSArray *auctionsArray;
    _faction = faction;
    if([faction isEqualToString:@"Horde"])
    {
        NSLog(@"Storing Horde Auctions");
        auctionsArray = [NSArray arrayWithArray:_hordeAuctions];
    }
    else if ([faction isEqualToString:@"Alliance"])
    {
        NSLog(@"Storing Alliance Auctions");
        auctionsArray = [NSArray arrayWithArray:_allianceAuctions];
    }
    else if ([faction isEqualToString:@"Neutral"])
    {
        NSLog(@"Storing Neutral Auctions");
        auctionsArray = [NSArray arrayWithArray:_neutralAuctions];
    }
    
    int numAuctions = [auctionsArray count];
    
    //Stop if there are no auctions to store (Likely an API 404)
    if(numAuctions == 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            NSLog(@"No Auctions to display!");
            [progressBar setHidden:YES];
        });
        return;
    }
    //This stores the progress of the auction parsing.
    float currentAuction = 0;
    
    //Coredata variables that are used while looping through the auction list.
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setUndoManager:nil];
    [context setPersistentStoreCoordinator:[context1 persistentStoreCoordinator]];
    NSEntityDescription *auctionEntity = [NSEntityDescription entityForName:@"Auction" inManagedObjectContext:context];
    NSEntityDescription *itemEntity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    NSManagedObject *auctionDumpObject = [self setLastDumpInContext:context];
    [auctionDumpObject setValue:faction forKey:@"faction"];
    
    
    for(NSDictionary *auction in auctionsArray)
    {
        NSManagedObject *aucData =
        [[NSManagedObject alloc]
         initWithEntity:auctionEntity
         insertIntoManagedObjectContext:context];
        
        //Make sure the auction object initialized.
        if(aucData)
        {
            //Set the properties of each auction that can be fetched from the JSON
            [aucData setValue:[auction valueForKey:@"auc"] forKey:@"auc"];
            [aucData setValue:[auction valueForKey:@"bid"] forKey:@"bid"];
            [aucData setValue:[auction valueForKey:@"buyout"] forKey:@"buyout"];
            [aucData setValue:[auction valueForKey:@"item"] forKey:@"item"];
            [aucData setValue:[auction valueForKey:@"owner"] forKey:@"owner"];
            [aucData setValue:[auction valueForKey:@"quantity"] forKey:@"quantity"];
            [aucData setValue:[auction valueForKey:@"rand"] forKey:@"rand"];
            [aucData setValue:[auction valueForKey:@"seed"] forKey:@"seed"];
            [aucData setValue:[auction valueForKey:@"timeLeft"] forKey:@"timeLeft"];
            [aucData setValue:[auction valueForKey:@"petSpeciesId"] forKey:@"petSpeciesID"];
            [aucData setValue:[auction valueForKey:@"petQualityId"] forKey:@"petQualityID"];
            [aucData setValue:[auction valueForKey:@"petBreedId"] forKey:@"petBreedID"];
            [aucData setValue:[auction valueForKey:@"petLevel"] forKey:@"petLevel"];
            //[aucData setValue:faction forKey:@"faction"];
            
            //Set the item relationship for each auction
            NSFetchRequest *fetchItem = [[NSFetchRequest alloc] init];
            
            //First, try to fetch the item info from the persistent store.
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID == %d",[[auction valueForKey:@"item"] intValue]];
            [fetchItem setEntity:itemEntity];
            [fetchItem setPredicate:predicate];
            [fetchItem setIncludesPropertyValues:NO];
            NSArray *fetchedItem = [context executeFetchRequest:fetchItem error:&error];
            if([fetchedItem count] > 0)
            {
                [aucData setValue:fetchedItem[0] forKey:@"itemRelationship"];
            }
            //If there is no matching record, try to fetch the item info from the API, and then set the itemRelationship to the newly created item object.
            else
            {
                NSLog(@"Could not find item in database for ID: %d",[[auction valueForKey:@"item"] intValue]);
                //[AHPItemAPIRequest storeItem:inContext:] returns a reference to the item managed object it created for the item ID it is given.
                [aucData setValue:[AHPItemAPIRequest storeItem:[[auction valueForKey:@"item"] integerValue] inContext:context] forKey:@"itemRelationship"];
            }
            if(error)
            {
                NSLog(@"Error linking Item ID: %@",error);
            }
            
            //Set the dump date that the auction is generated from.
            [aucData setValue:auctionDumpObject forKey:@"dumpRelationship"];
        }
        currentAuction++;
        float progress = currentAuction/numAuctions;
        //NSLog(@"%f - %f \n%@",currentAuction,progress,aucData);
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [progressBar setProgress:progress animated:YES];
        });
    }
    
    if(![context save:&error])
    {
        NSLog(@"Error saving context: %@",error);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [progressBar setHidden:YES];
    });
    
    //NSLog(@"%d auctions in horde auctions",[_hordeAuctions count]);
}

//Call this method to set the Last Dumped date to the current dump generation date (from the JSON), formatted as a double. Also includes the URL a dump was generated from, for keeping multiple different sets of auction data at one time, and the faction the dump was generated for, so the user can load only part of an auction dump.
-(NSManagedObject*) setLastDumpInContext: (NSManagedObjectContext*)context
{
    NSError *error = nil;
    
    //Remove all previous auction dumps with the same url
    NSMutableArray *dumpsForURL = [AHPAPIRequest findDumpsInContext:context WithURL:[_auctionDataURL description] forFaction:_faction];
    [dumpsForURL removeObjectAtIndex:0];
    for(NSManagedObject *dump in dumpsForURL)
    {
        NSLog(@"Deleting dump: %@",dump);
        [context deleteObject:dump];
    }
    if(![context save:&error])
    {
        NSLog(@"Error Removing Old Dates: %@",error);
    }
    
    //Insert the new dump date
    NSEntityDescription *auctionDumpDate = [NSEntityDescription entityForName:@"AuctionDumpDate" inManagedObjectContext:context];
    NSManagedObject *time = [[NSManagedObject alloc] initWithEntity:auctionDumpDate insertIntoManagedObjectContext:context];
    [time setValue:[NSNumber numberWithDouble:[lastModified doubleValue]] forKey:@"date"];
    [time setValue:[_auctionDataURL description] forKey:@"dumpURL"];
    [time setValue:_faction forKey:@"faction"];
    NSLog(@"Last Dump Date set as: %@\n URL set as: %@",[AHPAPIRequest convertWOWTime: [lastModified doubleValue]],[_auctionDataURL description]);
    if(![context save:&error])
    {
        NSLog(@"Error Saving Auction Dump Date: %@",error);
    }
    
    return time;
}

//Returns an array of all dumps for the given URL, ordered by date (newest first).
+(NSMutableArray *)findDumpsInContext:(NSManagedObjectContext*) context WithURL:(NSString*)dumpURL forFaction:(NSString *)faction
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *auctionDump = [NSEntityDescription entityForName:@"AuctionDumpDate" inManagedObjectContext:context];
    [request setEntity:auctionDump];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(dumpURL == %@) AND (faction == %@)",dumpURL,faction];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSError *error;
    
    NSMutableArray *dumps = [NSMutableArray arrayWithArray:[context executeFetchRequest:request error:&error]];
    if([dumps count] == 0)
        return nil;
    else
    {
        NSLog(@"Found %d dumps", [dumps count]);
        for(NSManagedObject *aucDump in dumps)
        {
            NSLog(@"%@ - %@",
                  [aucDump valueForKey:@"dumpURL"],
                  [AHPAPIRequest convertWOWTime:[[aucDump valueForKey:@"date"] doubleValue]]);
        }
        return dumps;
    }
}

//This function converts the time number given by the wow server to a string, so that it's human-readable. The wow API returns times in unix time (seconds since 1/1/1970), in milliseconds. This method will format the date correctly, inculding timezone and locale.
+(NSString*) convertWOWTime:(double)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time/1000]];
}

//This is a function for formatting the timeLeft value returned from the JSON so that it is formatted correctly.
+(NSString*)timeLeftFormat:(NSString*)timeLeft
{
    if([timeLeft isEqualToString:@"SHORT"])
        return @"Short";
    if([timeLeft isEqualToString:@"MEDIUM"])
        return @"Medium";
    if([timeLeft isEqualToString:@"LONG"])
        return @"Long";
    if([timeLeft isEqualToString:@"VERY_LONG"])
        return @"Very Long";
    return @"ERROR";
}

@end
