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
@synthesize realm = _realm;
@synthesize slug = _slug;
@synthesize auctionDataURL = _auctionDataURL;


-(id) initWithRealmURL:(NSManagedObject *)realmURL
             inContext:(NSManagedObjectContext *)context
{
    //Used to track consumption of battle.net API.
    NSLog(@"MAKING AUCTION API REQUEST");
    
    _realm = [realmURL valueForKey:@"realm"];
    _slug = [realmURL valueForKey:@"slug"];
    //NSLog(@"Initializing APIRequest with slug: %@",_slug);
    
    //Fetch the Location of the auction house data
    NSError *error = nil;
    NSURLRequest *auctionAPIRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://battle.net/api/wow/auction/data/%@",_slug]]];
    NSURLResponse *urlResponse;
    NSData *response = [NSURLConnection sendSynchronousRequest:auctionAPIRequest returningResponse:&urlResponse error:&error];
    
    if(response)
    {
        //Since the API call returns the location of the data file, and not the file itself, we need to extract the URL from the API response. We set the URL for the realmURL object now, in case it has changed since last time. The URLs are usually only changed when realms are connected to eachother.
        NSArray *auctionLines = [NSArray arrayWithObject:[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&error]];
        NSArray *filesArray = [auctionLines[0] objectForKey:@"files"];
        _auctionDataURL = [NSURL URLWithString:[[filesArray objectAtIndex:0] objectForKey:@"url"]];
        lastModified = [[filesArray objectAtIndex:0] objectForKey:@"lastModified"];
        [realmURL setValue:[_auctionDataURL description] forKey:@"url"];
        
        NSError *error;
        
        if (![context save:&error]) {
            NSLog(@"FAILED TO SAVE CONTEXT WHEN INTIAILIZING REALMURL: %@",error);
        }
        /*
        //See if the RealmURL object for this URL/slug pair exists. If not, create it.
        //NSLog(@"%@\n%@",_auctionDataURL,[[_auctionDataURL path] substringFromIndex:22]);
        //[self storeRealmURL:[_auctionDataURL path] forSlug:[[_auctionDataURL path] substringFromIndex:22] inContext:context];
        */
        
        //Fetch the data from the URL provided by the API
        NSMutableURLRequest *auctionDataRequest = [NSURLRequest requestWithURL:_auctionDataURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        NSHTTPURLResponse *APIResponse = [[NSHTTPURLResponse alloc] init];
        NSData *dataResponse = [NSURLConnection sendSynchronousRequest:auctionDataRequest returningResponse:&APIResponse error:&error];
        
        int status = [APIResponse statusCode];
        //If the APIRequest received an answer
        if(status == 200)
        {
            NSLog(@"%d",status);
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
            NSLog(@"Error in API Request to Auction House: %d",status);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"API Error" message:[NSString stringWithFormat:@"The Auction API returned error code %d. Please try again later.",status] delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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

//This is a helper method meant to be called during initialization to check if there is a RealmURL object for the given slug. If there is, check if the realm name and slug are present and add them if necessary. This will allow the user to match RealmURLs to name/slugs without calling the battle.net API.
- (NSManagedObject *)storeRealmURL:(NSString*) url
              forSlug:(NSString*) slug
              andName:(NSString*) name
            inContext:(NSManagedObjectContext*) context
{
    NSFetchRequest *realmFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *realmEntity = [NSEntityDescription entityForName:@"RealmURL" inManagedObjectContext:context];
    NSPredicate *realmPredicate = [NSPredicate predicateWithFormat:@"slug == %@",slug];
    NSError *error = nil;
    
    [realmFetch setEntity:realmEntity];
    [realmFetch setPredicate:realmPredicate];
    NSArray *results = [context executeFetchRequest:realmFetch error:&error];
    
    if(results != nil)
    {
        int numResults = [results count];
        //NSLog(@"%d",numResults);
        
        //If there are no RealmURL objects for this URL.
        if(numResults == 0)
        {
            //Create a new RealmURL object with the name, slug, and URL.
            NSLog(@"Creating new RealmURL object for: %@",url);
            NSManagedObject *realmURLObject = [[NSManagedObject alloc] initWithEntity:realmEntity insertIntoManagedObjectContext:context];
            [realmURLObject setValue:url forKey:@"url"];
            [realmURLObject setValue:slug forKey:@"slug"];
            [realmURLObject setValue:name forKey:@"realm"];
            
            if(![context save:&error]){
                NSLog(@"Error: %@",error);}
            
            return realmURLObject;
        }
        else if(numResults == 1)
        {
            return [results objectAtIndex:0];
        }
        //If somehow there is more than one RealmURL object for this URL
        else
        {
            //Delete all of the RealmURL objects and insert a new one. This should never happen.
            NSLog(@"\n\n\n\nMULTIPLE REALMURLS FOR %@\n\n\n\n",slug);
            return [results objectAtIndex:0];
        }
        
    }
    else
    {
        NSLog(@"Error searching for previously cached realm URL: %@",error);
        return nil;
    }
}

- (void)storeAuctions:(NSManagedObjectContext*) context1
         withProgress:(UIProgressView*) progressBar
           forFaction:(NSString*) faction
{
    //Unhide the progress bar. Hide the Displaying label.
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [progressBar setHidden:NO];
    });
    
    NSError *error;
    
    NSArray *auctionsArray;
    //_faction = faction;
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
    //Calling setLastDumpInContext: should also delete all of the previous auctions in the database for this realm/faction.
    NSManagedObject *auctionDumpObject = [self setLastDumpInContext:context forFaction:faction];
    [auctionDumpObject setValue:faction forKey:@"faction"];
    
    if(![context save:&error])
    {
        NSLog(@"ERROR: %@",error);
    }
    
    
    for(NSDictionary *auction in auctionsArray)
    {
        NSManagedObject *aucData =
        [[NSManagedObject alloc]
         initWithEntity:auctionEntity
         insertIntoManagedObjectContext:context];
        
        //Make sure the auction object initialized.
        if(aucData)
        {
            //sNSLog(@"%@",auction);
            //Set the properties of each auction that can be fetched from the JSON
            [aucData setValue:[auction valueForKey:@"auc"] forKey:@"auc"];
            [aucData setValue:[auction valueForKey:@"bid"] forKey:@"bid"];
            [aucData setValue:[auction valueForKey:@"buyout"] forKey:@"buyout"];
            [aucData setValue:[auction valueForKey:@"item"] forKey:@"item"];
            [aucData setValue:[auction valueForKey:@"owner"] forKey:@"owner"];
            [aucData setValue:[auction valueForKey:@"quantity"] forKey:@"quantity"];
            [aucData setValue:[auction valueForKey:@"rand"] forKey:@"rand"];
            [aucData setValue:[auction valueForKey:@"seed"] forKey:@"seed"];
            [aucData setValue:[auction valueForKey:@"petSpeciesId"] forKey:@"petSpeciesID"];
            [aucData setValue:[auction valueForKey:@"petQualityId"] forKey:@"petQualityID"];
            [aucData setValue:[auction valueForKey:@"petBreedId"] forKey:@"petBreedID"];
            [aucData setValue:[auction valueForKey:@"petLevel"] forKey:@"petLevel"];
            
            //Time Left has to be handled seperately to make it sortable in Core Data. (Custom comparator blocks are not supported for NSSortDescriptors in Core Data.)
            NSString *timeLeft = [auction valueForKey:@"timeLeft"];
            if([timeLeft isEqualToString:@"SHORT"])
                [aucData setValue:[NSNumber numberWithInt:0] forKey:@"timeLeft"];
            else if([timeLeft isEqualToString:@"MEDIUM"])
                [aucData setValue:[NSNumber numberWithInt:1] forKey:@"timeLeft"];
            else if([timeLeft isEqualToString:@"LONG"])
                [aucData setValue:[NSNumber numberWithInt:2] forKey:@"timeLeft"];
            else if([timeLeft isEqualToString:@"VERY_LONG"])
                [aucData setValue:[NSNumber numberWithInt:3] forKey:@"timeLeft"];
            
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
                //NSLog(@"Could not find item in database for ID: %d",[[auction valueForKey:@"item"] intValue]);
                //[AHPItemAPIRequest storeItem:inContext:] returns a reference to the item managed object it created for the item ID it is given.
                [aucData setValue:[AHPItemAPIRequest storeItem:[[auction valueForKey:@"item"] integerValue] inContext:context] forKey:@"itemRelationship"];
            }
            if(error)
            {
                NSLog(@"Error linking Item ID: %@",error);
            }
            
            //BattlePet API steps
            //Check if the item is actually a battlePet cage (itemID = 82800)
            if([[auction valueForKey:@"item"] integerValue] == 82800)
            {
                //NSLog(@"Auction: %@",auction);
                //NSLog(@"Attempting to fetch pet data for %d",[[auction valueForKey:@"petSpeciesId"] integerValue]);
                //First, try to fetch the pet info from the persistent store.
                NSFetchRequest *fetchPet = [[NSFetchRequest alloc] init];
                NSEntityDescription *petEntity = [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:context];
                NSPredicate *petPredicate = [NSPredicate predicateWithFormat:@"speciesID == %d",[[auction valueForKey:@"petSpeciesId"] intValue]];
                
                [fetchPet setEntity:petEntity];
                [fetchPet setPredicate:petPredicate];
                [fetchPet setIncludesPropertyValues:NO];
                
                NSArray *fetchedPet = [context executeFetchRequest:fetchPet error:&error];
                if([fetchedPet count] > 0)
                {
                    [aucData setValue:fetchedPet[0] forKey:@"petRelationship"];
                }
                //If there is no matching pet (by speciesID) in the persistent store
                else
                {
                    
                    [aucData setValue:[AHPPetAPIRequest storePet:[[auction valueForKey:@"petSpeciesId"] integerValue] inContext:context] forKey:@"petRelationship"];
                }
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
}

//Call this method to set the Last Dumped date to the current dump generation date (from the JSON), formatted as a double. Also includes the faction the dump was generated for, so the user can load only part of an auction dump.
-(NSManagedObject*) setLastDumpInContext:(NSManagedObjectContext*) context
                              forFaction:(NSString*) faction
{
    NSError *error = nil;
    
    //Remove all previous auction dumps with the same slug and faction
    NSMutableArray *dumpsForURL = [AHPAPIRequest findDumpsInContext:context withSlug:_slug forFaction:faction];
    [dumpsForURL removeObjectAtIndex:[dumpsForURL count]-1];
    
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
    NSManagedObject *dumpObject = [[NSManagedObject alloc] initWithEntity:auctionDumpDate insertIntoManagedObjectContext:context];
    [dumpObject setValue:[NSNumber numberWithDouble:[lastModified doubleValue]] forKey:@"date"];
    [dumpObject setValue:faction forKey:@"faction"];
    
    //Create a new realmURL object
    NSManagedObject *realmURLObject = [self storeRealmURL:[_auctionDataURL description] forSlug:_slug andName:_realm inContext:context];
    [realmURLObject setValue:dumpObject forKey:@"dumpRelationship"];
    
    //Set the array of realmURL objects for the dumpURL. Since the dump to realmURL relationship is a to-many relationship, we need to add this realmURL
    NSSet *realmURLSet = [dumpObject valueForKey:@"realmRelationship"];
    if(![realmURLSet member:realmURLObject])
    {
        [dumpObject setValue:[realmURLSet setByAddingObject:realmURLObject] forKey:@"realmRelationship"];
    }
    
    NSLog(@"Last Dump Date set as: %@\n URL set as: %@",dumpObject,realmURLObject);
    if(![context save:&error])
    {
        NSLog(@"Error Saving Auction Dump Date: %@",error);
    }
    
    return dumpObject;
}

//Returns an array of all dumps for the given slug, ordered by date (newest first).
+(NSMutableArray *)findDumpsInContext:(NSManagedObjectContext *)context
                             withSlug:(NSString *)slug
                           forFaction:(NSString *)faction
{
    //Find any other AuctionDumpDate objects with both:
    //1. a relationship to a RealmURL object with this slug.
    //2. the same faction attribute
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *auctionDump = [NSEntityDescription entityForName:@"AuctionDumpDate" inManagedObjectContext:context];
    [request setEntity:auctionDump];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY realmRelationship.slug == %@) AND (faction == %@)",slug,faction];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray *dumps = [NSMutableArray arrayWithArray:[context executeFetchRequest:request error:&error]];
    if([dumps count] == 0)
    {
        return nil;
    }
    else
    {
        NSLog(@"Found %d dumps", [dumps count]);
        for(NSManagedObject *aucDump in dumps)
        {
            NSLog(@"%@ - %@",
                  [aucDump valueForKey:@"realmRelationship"],
                  [AHPAPIRequest convertWOWTime:[[aucDump valueForKey:@"date"] doubleValue]]);
        }
        return dumps;
    }
}

//Returns an array of all dumps for the given slug, ordered by date (newest first).
+(NSMutableArray *)findDumpsInContext:(NSManagedObjectContext *)context
                             withURL:(NSString *)url
                           forFaction:(NSString *)faction
{
    //Find any other AuctionDumpDate objects with both:
    //1. a relationship to a RealmURL object with this URL.
    //2. the same faction attribute
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *auctionDump = [NSEntityDescription entityForName:@"AuctionDumpDate" inManagedObjectContext:context];
    [request setEntity:auctionDump];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY realmRelationship.url == %@) AND (faction == %@)",url,faction];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray *dumps = [NSMutableArray arrayWithArray:[context executeFetchRequest:request error:&error]];
    if([dumps count] == 0)
    {
        return nil;
    }
    else
    {
        NSLog(@"Found %d dumps", [dumps count]);
        for(NSManagedObject *aucDump in dumps)
        {
            NSLog(@"%@ - %@",
                  [aucDump valueForKey:@"realmRelationship"],
                  [AHPAPIRequest convertWOWTime:[[aucDump valueForKey:@"date"] doubleValue]]);
        }
        return dumps;
    }
}

//This function converts the time number given by the wow server to a string, so that it's human-readable. The wow API returns times in unix time (seconds since 1/1/1970), in milliseconds. This method will format the date correctly, inculding timezone and locale.
+(NSString*) convertWOWTime:(double) time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time/1000]];
}

//This is a function for formatting the timeLeft value returned from the JSON so that it is formatted correctly.
+(NSString*)timeLeftFormat:(NSInteger) timeLeft
{
    if(timeLeft == 0)
        return @"Short";
    if(timeLeft == 1)
        return @"Medium";
    if(timeLeft == 2)
        return @"Long";
    if(timeLeft == 3)
        return @"Very Long";
    return @"ERROR";
}

@end
