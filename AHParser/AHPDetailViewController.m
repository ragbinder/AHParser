//
//  AHPDetailViewController.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/23/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPDetailViewController.h"
#import "AHPAppDelegate.h"


@interface AHPDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation AHPDetailViewController
{
    dispatch_queue_t _backgroundQueue;
}
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize realmSelect = _realmSelect;

#pragma mark - Managing the detail item


- (void)configureView
{
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    
//    if([[delegate.realmURL valueForKey:@"realm"] length] == 0 || [[delegate.realmSelectViewController faction] length] == 0)
//    {
//        [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:[NSString stringWithFormat:@"Please Select A Realm/Faction"]];
//
//    }
//    else
//    {
//        [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:
//         [NSString stringWithFormat:@"%@ - %@",
//          [delegate.realmURL valueForKey:@"realm"],
//          [delegate.realmSelectViewController faction]]];
//    }
    
    //NSLog(@"PREDICATES: \nFACTION:\n%@ \nREALM:\n%@ \nCATEGORY:\n%@ \nSEARCH:\n%@",[delegate factionPredicate],[delegate realmPredicate],[delegate categoryPredicate],[delegate searchPredicate]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [self configureView];
    delegate = (AHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = [delegate managedObjectContext];
    [_auctionTable setDataSource:self];
    [self.progressBar setHidden:YES];
    
    //Set the realm select button
    UIButton *realmSelectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [realmSelectButton setFrame:CGRectMake(0, 0, 200, 40)];
    [realmSelectButton setTitle:@"Choose a Realm" forState:UIControlStateNormal];
    [realmSelectButton addTarget:self action:@selector(realmSelect:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = realmSelectButton;
    
    //Set the upper right buttons - refresh table and return to realm/faction select
//    UIBarButtonItem *realmSelect = [[UIBarButtonItem alloc] initWithTitle:@"Default" style:UIBarButtonItemStyleBordered target:self action:@selector(realmSelect:)];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButton:)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButton:)];
    NSArray *array = [[NSArray alloc] initWithObjects: /*realmSelect,*/searchButton,refreshButton, nil];
    [self.navigationItem setRightBarButtonItems:array animated:YES];
    
//    _realmSelect = realmSelect;
    
    //Create a GCD queue for background loading of cells
    _backgroundQueue = dispatch_queue_create("com.ragbinder.backgroundAuctionCell",nil);
}

-(void) refreshAuctionDatabase
{
    NSArray *auctions = [AHPAPIRequest auctionsForSlug:[self slug]];
    [self setAuctions:auctions];
    [[self auctionTable] reloadData];
}
//Will refresh the auction database if and only if it is out of date.
/*
-(void) refreshAuctionDatabase
{
    //NSLog(@"REALM SELECT: %@",_realmSelect.title);
    //Make sure a realm and faction are selected.
        //HAHAHA THERE IS CERTAINLY A BETTER WAY TO DO THIS.
    if(![_realmSelect.title isEqualToString:@"Please Select A Realm/Faction"])
    {
        //Grab the link to the JSON file and its lastModified date.
        AHPAPIRequest *auctionData = [[AHPAPIRequest alloc] initWithRealmURL:[delegate realmURL]
                                                                   inContext:_managedObjectContext];
        NSManagedObjectContext *context = [delegate managedObjectContext];
        NSString *urlString = [[auctionData auctionDataURL] description];
        NSString *slugString = [auctionData slug];
        
        //Problem Here
//        NSMutableArray *array = [AHPAPIRequest findDumpsInContext:context
//                                                          withURL:urlString];
//    NSLog(@"%@",[AHPAPIRequest findDumpsInContext:context withURL:urlString]);
        NSLog(@"%@",[AHPAPIRequest findDumpsInContext:context withURL:urlString]);
        NSMutableArray *array;
        
        NSManagedObject *latestDump = [array objectAtIndex:0];
        NSLog(@"Latest Dump: %@",array);
        //Give the delegate a reference to the latest dump for this realmURL.
        [delegate setDump:latestDump];
        
        //If the auction data dump is more recent than the one in coredata, delete all of the coredata Auction objects and repopulate the database.
 
         NSLog(@"Auction Data last Generated: %@",
         [AHPAPIRequest convertWOWTime:[[auctionData lastModified] doubleValue]]);
         NSLog(@"Auction Data in persistent store last generated: %@",
         [AHPAPIRequest convertWOWTime:[[latestDump valueForKey:@"date"] doubleValue]]);
         NSLog(@"Auction Data pulled from: %@",[latestDump valueForKey:@"realmRelationship.url"]);
 
        
        if([[latestDump valueForKey:@"date"] doubleValue] != [[auctionData lastModified] doubleValue])
        {
            NSLog(@"AUCTION DATA NEEDS TO BE REFRESHED.\n%@ - latest dump\n%@ - current dump",[latestDump valueForKey:@"date"],[auctionData lastModified]);
            
            //Disable the button until the refresh is completed.
            UIBarButtonItem *refreshButton = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
            [refreshButton setEnabled:NO];
            
            //Insert the new auctions into the persistent store. A new AuctionDump object will be created and assigned to the objects.
//            dispatch_queue_t backgroundQueue;
//            backgroundQueue = dispatch_queue_create("com.ragbinder.AHParser.background", NULL);
            dispatch_async(_backgroundQueue, ^(void){
                [auctionData storeAuctions: [delegate managedObjectContext] withProgress:[self progressBar] forFaction:[delegate.realmSelectViewController faction]];
                
                //Re-enable the refresh button and filter the auction table after the data operation is complete.
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [refreshButton setEnabled:YES];
                    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dumpRelationship == %@",[[AHPAPIRequest findDumpsInContext:[delegate managedObjectContext] WithURL:[[auctionData auctionDataURL] description]] objectAtIndex:0]];
                    NSLog(@"latest dump after filter (fetched) %@",[[AHPAPIRequest findDumpsInContext:context
                                                                                             withSlug:slugString] objectAtIndex:0]);
                    NSLog(@"Latest Dump after fitlering: %@",latestDump);
                    [delegate setDump:[[AHPAPIRequest findDumpsInContext:context
                                                                withSlug:slugString] objectAtIndex:0]];
                    NSError *error;
                    if(![delegate.managedObjectContext save:&error])
                    {   NSLog(@"Error saving context after refresh: %@",error);}
                    [self applyCurrentFilters];
                });
            });
        }
        else
        {
            UIAlertView *upToDateAlert = [[UIAlertView alloc] initWithTitle:@"Auctions up to Date" message:[NSString stringWithFormat:@"The auctions for this realms are already up to date!\nLast Generated: %@", [AHPAPIRequest convertWOWTime:[[latestDump valueForKey:@"date"] doubleValue]]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [upToDateAlert show];
            NSLog(@"DATABASE IS UP TO DATE.\n%@ - latest dump\n%@ - current dump",[latestDump valueForKey:@"date"],[auctionData lastModified]);
            //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dumpRelationship == %@",[[AHPAPIRequest findDumpsInContext:[delegate managedObjectContext] WithURL:[[auctionData auctionDataURL] description]] objectAtIndex:0]];
            [self applyCurrentFilters];
        }
    }
    else
    {
        UIAlertView *noSelectionAlert = [[UIAlertView alloc] initWithTitle:@"No Realm/Faction Selected" message:@"Please choose a realm and faction." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [noSelectionAlert show];
    }
}
*/

//This method is only for the noSelectionAlert UIAlertView. The other alert view (upToDateAlert) has a nil delegate so this will not be called.
//#JustUIAlertViewDelegateThings
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"%@\n%ld",alertView,(long)buttonIndex);
    [self realmSelect:self];
}

//Will refresh the auction database, even if it is up to date
/*
-(void) forceRefreshAuctionDatabase
{
    //Disable the button until the refresh is completed.
    UIBarButtonItem *refreshButton = [self.navigationItem.rightBarButtonItems objectAtIndex:3];
    [refreshButton setEnabled:NO];
    
    //Grab the link to the JSON file and its lastModified date.
    AHPAPIRequest *auctionData = [[AHPAPIRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://battle.net/api/wow/auction/data/%@",[delegate realm]]]];
    
    //Insert the new auctions into the persistent store
    dispatch_queue_t backgroundQueue;
    backgroundQueue = dispatch_queue_create("com.ragbinder.AHParser.background", NULL);
    dispatch_async(backgroundQueue, ^(void){
        [auctionData storeAuctions: [delegate managedObjectContext] withProgress:[self progressBar] forFaction:[delegate faction]];
        
        //Re-enable the refresh button after the data operation is complete.
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [refreshButton setEnabled:YES];
            [self filterAuctionTable:nil];
        });
    });
}
 */

//Prints out the stored Items in coredata
/*
-(void) printStoredItems
{
    NSFetchRequest *fetchItems = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"itemClass" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"itemSubClass" ascending:YES];
    [fetchItems setEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:[delegate managedObjectContext]]];
    [fetchItems setSortDescriptors: [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,nil]];

    NSArray *fetchedItems = [[delegate managedObjectContext] executeFetchRequest:fetchItems error:nil];
    for(NSManagedObject *object in fetchedItems)
    {
        NSLog(@"[%@-%@] %@ - %@",[object valueForKey:@"itemClass"],[object valueForKey:@"itemSubClass"],[object valueForKey:@"itemID"],[object valueForKey:@"name"]);
    }
}
 */

- (void)applyCurrentFilters
{
    NSLog(@"Delegate Dump object: %@",[delegate dump]);
    NSLog(@"Delegate Realm object: %@",[delegate realmURL]);
    NSPredicate *factionPredicate = [NSPredicate predicateWithFormat:@"dumpRelationship.faction == %@",[delegate.dump valueForKey:@"faction"]];
    NSPredicate *realmPredicate = [NSPredicate predicateWithFormat:@"ANY dumpRelationship.realmRelationship.url == %@",[delegate.realmURL valueForKey:@"url"]];
    NSPredicate *searchPredicate = [delegate searchPredicate];
    NSPredicate *filterPredicate = [delegate categoryPredicate];

    //NSLog(@"SORT DESCRIPTOR ARRAY: %@",sortDescriptorArray);
    //Need to combine the predicates into an array, making sure that none of them are nil. If any are nil, then any predicates after them will be ignored.
    NSMutableArray *predicatesArray = [[NSMutableArray alloc] initWithCapacity:4];
    if(factionPredicate)
    {   [predicatesArray addObject:factionPredicate];}
    if(realmPredicate)
    {   [predicatesArray addObject:realmPredicate];}
    if(searchPredicate)
    {   [predicatesArray addObject:searchPredicate];}
    if(filterPredicate)
    {   [predicatesArray addObject:filterPredicate];}
    
    for(NSObject *object in predicatesArray)
    {
        NSLog(@"FILTERING WITH: %@",object);
    }
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    /*
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Auction" inManagedObjectContext:[delegate managedObjectContext]];
    //NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"auc" ascending:YES];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:compoundPredicate];
    [fetch setSortDescriptors:[delegate sortDescriptors]];
     */
    /*
    if([sortDescriptorArray count] != 0)
    {
        
        [fetch setSortDescriptors:[sortDescriptorArray arrayByAddingObject:sortDescriptor1]];
    }
    else
    {
        [fetch setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor1, nil]];
    }
    */
    NSError *error;
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    [[self fetchedResultsController].fetchRequest setSortDescriptors:[delegate sortDescriptors]];
    [[self fetchedResultsController].fetchRequest setPredicate:compoundPredicate];
    [[self fetchedResultsController] performFetch:&error];
    NSLog(@"Performing Fetch with FetchRequest: %@",[_fetchedResultsController fetchRequest]);
    NSLog(@"Fetch Returned %d Results",[[_fetchedResultsController fetchedObjects] count]);
    if(error)
    {
        NSLog(@"Error filtering auction table: %@",error);
    }
    [_managedObjectContext executeFetchRequest:[_fetchedResultsController fetchRequest] error:&error];
    [_auctionTable reloadData];
}

//********************************************
//
//          MANDATORY METHODS
//
//********************************************

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController*)fetchedResultsController
{
    if(_fetchedResultsController != nil)
        return _fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Auction" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"auc" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [fetchRequest setFetchBatchSize:20];
    
    //NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = frc;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Filter", @"Filter");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

//Mandatory method for UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%@",[_fetchedResultsController fetchedObjects]);
//    return [[_fetchedResultsController fetchedObjects] count];
    return [[self auctions] count];
}

//Second Mandatory method for UITableView. This handles constructing the individual cells as they are needed.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingsCell";
    AHPAuctionTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    /*
     if (cell == nil)
     {
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
     }
     */
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

//Long, messy method for configuring each auction cell.
- (void)configureCell:(AHPAuctionTableCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    //Try statement is necessary for when the table is refreshing. If the user is scrolling as the refresh completes, this function will generate an exception.
    @try
    {
        //#######################################
        //
        //Set all of the information that is contained in the auction lines JSON
        //(not including some battlePet information)
        //
        //#######################################
//        NSManagedObject *auction = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSManagedObject *auction = [self.auctions objectAtIndex:[indexPath row]];
        
        NSString *owner = [auction valueForKey:@"owner"];
        int timeLeft = [[auction valueForKey:@"timeLeft"] integerValue];
        
        NSString *bidC,*bidS,*bidG,*buyoutC,*buyoutS,*buyoutG;
        //int quant = [[auction valueForKey:@"quantity"] integerValue];
        NSString *quantity = [NSString stringWithFormat:@"%@",[auction valueForKey:@"quantity"]];
        
        bidG = [NSString stringWithFormat:@"%d",[[auction valueForKey:@"bid"] integerValue]/10000];
        bidS = [NSString stringWithFormat:@"%02d",[[auction valueForKey:@"bid"] integerValue]/100 %100];
        bidC = [NSString stringWithFormat:@"%02d",[[auction valueForKey:@"bid"] integerValue]%100];
        buyoutG = [NSString stringWithFormat:@"%d",[[auction valueForKey:@"buyout"] integerValue]/10000];
        buyoutS = [NSString stringWithFormat:@"%02d",[[auction valueForKey:@"buyout"] integerValue]/100 %100];
        buyoutC = [NSString stringWithFormat:@"%02d",[[auction valueForKey:@"buyout"] integerValue]%100];
        
        
        //Hide the quantity number for single items
        if([quantity isEqualToString:@"1"])
        {    quantity = @"";}
        
        [cell.owner setText:owner];
        [cell.bidG setText:bidG];
        [cell.bidS setText:bidS];
        [cell.bidC setText:bidC];
        [cell.buyoutG setText:buyoutG];
        [cell.buyoutS setText:buyoutS];
        [cell.buyoutC setText:buyoutC];
        [cell.timeLeft setText:[AHPAPIRequest timeLeftFormat:timeLeft]];
        [cell.quantity setText:quantity];
        
        //Hide the buyout value if it is 0 (there is no buyout price)
        if([[auction valueForKey:@"buyout"] integerValue] == 0)
        {
            [cell.buyoutC setHidden:YES];
            [cell.buyoutS setHidden:YES];
            [cell.buyoutG setHidden:YES];
            [cell.buyoutCImage setHidden:YES];
            [cell.buyoutGImage setHidden:YES];
            [cell.buyoutSImage setHidden:YES];
        }
        else
        {
            [cell.buyoutC setHidden:NO];
            [cell.buyoutS setHidden:NO];
            [cell.buyoutG setHidden:NO];
            [cell.buyoutCImage setHidden:NO];
            [cell.buyoutGImage setHidden:NO];
            [cell.buyoutSImage setHidden:NO];
        }
        
        //This array lets us change the name color based on item quality (given as a number from the JSON)
        NSArray *qualityColors = [NSArray arrayWithObjects:
                                  //Poor
                                  [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1],
                                  //Common
                                  [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0],
                                  //Uncommon
                                  [UIColor colorWithRed:31.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1],
                                  //Rare
                                  [UIColor colorWithRed:0.0/255.0 green:112.0/255.0 blue:221.0/255.0 alpha:1],
                                  //Epic
                                  [UIColor colorWithRed:163.0/255.0 green:43.0/255.0 blue:238.0/255.0 alpha:1],
                                  //Legendary
                                  [UIColor colorWithRed:255.0/255.0 green:128.0/255.0 blue:0.0/255.0 alpha:1],
                                  //Artifact
                                  [UIColor colorWithRed:230.0/255.0 green:204.0/255.0 blue:128.0/255.0 alpha:1],
                                  //Heirloom
                                  [UIColor colorWithRed:230.0/255.0 green:204.0/255.0 blue:128.0/255.0 alpha:1],
                                  nil];
        
        
        //Blizzard handles pets differently from normal items in the auction API, so this code deals with correctly displaying them. Otherwise, they'd all display as Pet Cages (Item ID 82800).
        NSDictionary *itemDictionary;
        if([[auction valueForKey:@"item"] integerValue] == 82800)
        {
            NSFetchRequest *internalPetReq = [[NSFetchRequest alloc] init];
            NSEntityDescription *pet = [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:[delegate managedObjectContext]];
            NSPredicate *petPredicate = [NSPredicate predicateWithFormat:@"(speciesID == %@)", [auction valueForKey:@"petSpeciesID"]];
            [internalPetReq setEntity:pet];
            [internalPetReq setPredicate:petPredicate];
            NSError *petError;
            NSArray *result = [[delegate managedObjectContext] executeFetchRequest:internalPetReq error:&petError];
            
            if(petError)
            {
                NSLog(@"Pet Error: %@",petError);
            }
            
            if([result count] != 0)
            {
                //If there is an existing item with the itemID we want, use that as the itemDictionary.
                itemDictionary = result[0];
                //NSLog(@"Found pet in internal DB for: %@",[auction valueForKey:@"petSpeciesID"]);
            }
            else
            {
                itemDictionary = [AHPPetAPIRequest petAPIRequest:[[auction valueForKey:@"petSpeciesID"] integerValue]];
            }
            
            [cell.itemName setTextColor:[qualityColors objectAtIndex: [[auction valueForKey:@"petQualityID"] integerValue]]];
            [cell.itemName setHighlightedTextColor:[qualityColors objectAtIndex: [[auction valueForKey:@"petQualityID"] integerValue]]];
            [cell.level setText:
             [NSString stringWithFormat:@"%@",[auction valueForKey:@"petLevel"]]];
            [cell.itemName setText: [itemDictionary valueForKey:@"name"]];
            [cell.level setText: [NSString stringWithFormat:@"%d",[[auction valueForKey:@"petLevel"] integerValue]]];
        }
        else
        {
            //#######################################
            //
            //Set the Item name, quality, and level from the item database
            //
            //#######################################
            //Check if the item needed by the next cell is in the internal item database. If it is, then load it from there. Else get it from the WoW web API and store it in the internal database.
            NSFetchRequest *internalItemReq = [[NSFetchRequest alloc] init];
            NSEntityDescription *item = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:[delegate managedObjectContext]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemID == %@)", [auction valueForKey:@"item"]];
            [internalItemReq setEntity:item];
            [internalItemReq setPredicate:predicate];
            NSError *itemError;
            NSArray *result = [[delegate managedObjectContext] executeFetchRequest:internalItemReq error:&itemError];
            
            if(itemError)
            {
                NSLog(@"Item Error: %@",itemError);
            }
            
            if([result count] != 0)
            {
                //If there is an existing item with the itemID we want, use that as the itemDictionary.
                itemDictionary = result[0];
            }
            else
            {
                //If an existing item with the desired itemID can't be found, fetch the data from the web and make a new core data object for it.
                [AHPItemAPIRequest storeItem:[[auction valueForKey:@"item"] integerValue] inContext:[delegate managedObjectContext]];
                
                result = [[delegate managedObjectContext] executeFetchRequest:internalItemReq error:&itemError];
                
                if(itemError)
                {
                    NSLog(@"Item Error: %@",itemError);
                }
                
                if([result count] != 0)
                {
                    itemDictionary = result[0];
                }
                else
                {
                    NSLog(@"Could not find item data for %@",[auction valueForKey:@"item"]);
                }
            }
            
            [cell.itemName setTextColor:[qualityColors objectAtIndex: [[itemDictionary valueForKey:@"quality"] intValue]]];
            [cell.itemName setHighlightedTextColor:[qualityColors objectAtIndex: [[itemDictionary valueForKey:@"quality"] intValue]]];
            if([itemDictionary valueForKey:@"itemLevel"])
            {
                [cell.level setText: [NSString stringWithFormat:@"%@",[itemDictionary valueForKey:@"itemLevel"]]];
            }
            else
            {
                [cell.level setText:@"Err"];
            }
            if([itemDictionary valueForKey:@"name"])
            {
                [cell.itemName setText: [itemDictionary valueForKey:@"name"]];
            }
            else
            {
                [cell.itemName setText:@""];
            }
        }
        
        
        //#######################################
        //
        // Set Icons and Thumbnails
        //
        //#######################################
        NSFetchRequest *fetchIcon = [[NSFetchRequest alloc] init];
        [fetchIcon setEntity:[NSEntityDescription entityForName:@"Icon" inManagedObjectContext:[delegate managedObjectContext]]];
        [fetchIcon setPredicate:[NSPredicate predicateWithFormat:@"icon == %@",[itemDictionary valueForKey:@"icon"]]];
        NSError *iconError = nil;
        NSArray *fetchedIcons = [[delegate managedObjectContext] executeFetchRequest:fetchIcon error:&iconError];
        
        if(iconError)
        {
            NSLog(@"Error with Icons: %@",iconError);
        }
        
        if([fetchedIcons count] > 0)
        {
            NSData *thumbnailData = [fetchedIcons[0] valueForKey:@"thumbnail"];
            UIImage *thumbnailImage = [UIImage imageWithData:thumbnailData];
            [cell.icon setImage:thumbnailImage];
        }
        else
        {
            NSData *thumbnailData = [[AHPImageRequest storeImageWithPath:[itemDictionary valueForKey:@"icon"] inContext:[delegate managedObjectContext]] valueForKey:@"thumbnail"];
            UIImage *thumbnailImage = [UIImage imageWithData:thumbnailData];
            [cell.icon setImage:thumbnailImage];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cell was deleted while loading: %@",exception);
    }
    @finally {}
}

//Disabled selection for now, since there isn't anything the user can do by selecting a cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    //NSManagedObject *auction = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //Code to fetch item dictionary from internal item database
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:[delegate managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID == %@",[auction valueForKey:@"item"]];
    [fetch setEntity:entity];
    [fetch setPredicate:predicate];
    [fetch setReturnsObjectsAsFaults:NO];
    NSArray *result = [[delegate managedObjectContext] executeFetchRequest:fetch error:nil];
    
    //Code to fetch item dictionary from web API
    //AHPItemAPIRequest *item = [[AHPItemAPIRequest alloc] init];
    //NSDictionary *result = [item itemAPIRequest:[[auction valueForKey:@"item"] intValue]];
    
    //NSLog(@"Selected Cell: %@",result);
    //if([[auction valueForKey:@"itemFetch"] count] != 0)
    //NSLog(@"[%@ - %@] %@: %@",[[[auction valueForKey:@"itemFetch"] objectAtIndex:0] valueForKey:@"itemClass"],[[[auction valueForKey:@"itemFetch"] objectAtIndex:0] valueForKey:@"itemSubClass"],[[[auction valueForKey:@"itemFetch"] objectAtIndex:0] valueForKey:@"itemID"],[[[auction valueForKey:@"itemFetch"] objectAtIndex:0] valueForKey:@"name"]);
    //NSLog(@"%@",[auction valueForKey:@"buyout"]);
     */
}

//********************************************
//
//Functions for the rightBarButtonItems Array.
//
//********************************************

-(IBAction)refreshButton:(id)sender
{
    [self refreshAuctionDatabase];
}

- (IBAction)searchButton:(id)sender
{
    /*
    NSEntityDescription *petEntity = [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:[delegate managedObjectContext]];
    NSFetchRequest *fetchAllPets = [[NSFetchRequest alloc] init];
    
    [fetchAllPets setEntity:petEntity];
    [fetchAllPets setReturnsObjectsAsFaults:NO];
    //NSLog(@"All Pets: %@",[[delegate managedObjectContext] executeFetchRequest:fetchAllPets error:nil]);
    for(NSManagedObject *object in [[delegate managedObjectContext] executeFetchRequest:fetchAllPets error:nil])
    {
        NSLog(@"Pet: %@",object);
    }
    */
    
    AHPSearchViewController *searchView = [delegate searchViewController];
    [searchView setDetailView:self];
    [self.navigationController pushViewController:searchView animated:YES];
}

-(IBAction)realmSelect:(id)sender
{
    if(![delegate realmSelectViewController])
    {
        //NSLog(@"creating realm select view controller");
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
//        AHPRealmSelectViewController *realmSelect = [self.storyboard instantiateViewControllerWithIdentifier:@"RealmSelectSB"];
//        [realmSelect setDetailView:self];
//        [delegate setRealmSelectViewController:realmSelect];
//        [self.navigationController pushViewController:realmSelect animated:YES];
        
        AHPRealmSelectViewController *realmSelectVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RealmSelectSB"];
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:realmSelectVC];
        [realmSelectVC setDetailView:self];
        [popoverController setPopoverContentSize:CGSizeMake(300, 300)];
//        [popoverController presentPopoverFromBarButtonItem:[self.navigationItem.rightBarButtonItems objectAtIndex:0] permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
        [popoverController presentPopoverFromRect:[self.navigationItem.titleView frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    }
    else
    {
        [self.navigationController pushViewController:[delegate realmSelectViewController] animated:YES];
    }
}

@end
