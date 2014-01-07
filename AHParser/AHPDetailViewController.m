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
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize pricePerUnit = _pricePerUnit;

#pragma mark - Managing the detail item


- (void)configureView
{
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if([delegate.faction isEqualToString:@""] || [delegate.realm isEqualToString:@""])
    {
        [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:@"Please Select A Realm/Faction"];
    }
    else
    {
        [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setTitle:[NSString stringWithFormat:@"%@ - %@",[delegate realmProper],[delegate faction]]];
    }
    
    //[self filterAuctionTable:nil];
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
    self.pricePerUnit = NO;
    
    //Set the upper right buttons - refresh table and return to realm/faction select
    NSString *currentRealm = [delegate realm];
    UIBarButtonItem *realmSelect = [[UIBarButtonItem alloc] initWithTitle:currentRealm style:UIBarButtonItemStyleBordered target:self action:@selector(realmSelect:)];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButton:)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButton:)];
    NSArray *array = [[NSArray alloc] initWithObjects: realmSelect,searchButton,refreshButton, nil];
    
    [self.navigationItem setRightBarButtonItems:array animated:YES];
}

//Will refresh the auction database if and only if it is out of date.
-(void) refreshAuctionDatabase
{
    
    //Grab the link to the JSON file and its lastModified date.
    AHPAPIRequest *auctionData = [[AHPAPIRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://battle.net/api/wow/auction/data/%@",[delegate realm]]]];
    NSManagedObject *latestDump = [[AHPAPIRequest findDumpsInContext:[delegate managedObjectContext] WithURL:[[auctionData auctionDataURL] description] forFaction:[delegate faction]] objectAtIndex:0];
    
    //If the auction data dump is more recent than the one in coredata, delete all of the coredata Auction objects and repopulate the database.
    NSLog(@"Auction Data last Generated: %@",
          [AHPAPIRequest convertWOWTime:[[auctionData lastModified] doubleValue]]);
    NSLog(@"Auction Data in persistent store last generated: %@",
          [AHPAPIRequest convertWOWTime:[[latestDump valueForKey:@"date"] doubleValue]]);
    NSLog(@"Auction Data pulled from: %@",[latestDump valueForKey:@"dumpURL"]);
    
    if([[latestDump valueForKey:@"date"] doubleValue] != [[auctionData lastModified] doubleValue])
    {
        NSLog(@"Auction Data needs to be refreshed.\n%@ - latest dump\n%@ - current dump",[latestDump valueForKey:@"date"],[auctionData lastModified]);
        
        //Disable the button until the refresh is completed.
        UIBarButtonItem *refreshButton = [self.navigationItem.rightBarButtonItems objectAtIndex:2];
        [refreshButton setEnabled:NO];
        
        //Insert the new auctions into the persistent store. A new AuctionDump object will be created and assigned to the objects.
        dispatch_queue_t backgroundQueue;
        backgroundQueue = dispatch_queue_create("com.ragbinder.AHParser.background", NULL);
        dispatch_async(backgroundQueue, ^(void){
            [auctionData storeAuctions: [delegate managedObjectContext] withProgress:[self progressBar] forFaction:[delegate faction]];
            
            //Re-enable the refresh button and filter the auction table after the data operation is complete.
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [refreshButton setEnabled:YES];
                //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dumpRelationship == %@",[[AHPAPIRequest findDumpsInContext:[delegate managedObjectContext] WithURL:[[auctionData auctionDataURL] description]] objectAtIndex:0]];
                [self filterAuctionTable:nil];
            });
        });
    }
    else
    {
        NSLog(@"%@ - latest dump\n%@ - current dump",[latestDump valueForKey:@"date"],[auctionData lastModified]);
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dumpRelationship == %@",[[AHPAPIRequest findDumpsInContext:[delegate managedObjectContext] WithURL:[[auctionData auctionDataURL] description]] objectAtIndex:0]];
        [self filterAuctionTable:nil];
    }
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

//This method changes the contents of the UITableView in the detail view to only contain auctions matching the predicate you pass in.
//It will include by default the currently selected realm and faction.
//Sample Predicate: "(item == 72095)" for trillium bar
- (void)filterAuctionTable: (NSPredicate *) predicate
{
    NSPredicate *factionPredicate = [NSPredicate predicateWithFormat:@"dumpRelationship.faction == %@",[delegate faction]];
    NSPredicate *realmPredicate = [NSPredicate predicateWithFormat:@"dumpRelationship.dumpURL == %@",delegate.realmURL];
    
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects: factionPredicate, realmPredicate, predicate, nil]];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Auction" inManagedObjectContext:[delegate managedObjectContext]];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"auc" ascending:YES];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:predicate];
    [fetch setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor1, nil]];
    
    NSError *error;
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    [[self fetchedResultsController].fetchRequest setPredicate:compoundPredicate];
    [[self fetchedResultsController] performFetch:&error];
    //NSLog(@"Performing Fetch with FetchRequest: %@",[_fetchedResultsController fetchRequest]);
    //NSLog(@"Fetch Returned %d Results",[[_fetchedResultsController fetchedObjects] count]);
    if(error)
    {
        NSLog(@"Error filtering auction table: %@",error);
    }
    [_managedObjectContext executeFetchRequest:[_fetchedResultsController fetchRequest] error:&error];
    [_auctionTable reloadData];
}

- (void)filterAuctionTable: (NSPredicate *) predicate andSort: (NSSortDescriptor*) sort
{
    NSPredicate *factionPredicate = [NSPredicate predicateWithFormat:@"dumpRelationship.faction == %@",[delegate faction]];
    NSPredicate *realmPredicate = [NSPredicate predicateWithFormat:@"dumpRelationship.dumpURL == %@",delegate.realmURL];
    
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects: factionPredicate, realmPredicate, predicate, nil]];
    /*
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Auction" inManagedObjectContext:[delegate managedObjectContext]];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"auc" ascending:YES];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:predicate];
    //[fetch setSortDescriptors:[NSArray arrayWithObjects:sort,sortDescriptor1, nil]];
    [fetch setSortDescriptors:[NSArray arrayWithObjects:sort,sortDescriptor1, nil]];
    */
    NSError *error;
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    [[self fetchedResultsController].fetchRequest setPredicate:compoundPredicate];
    [[self fetchedResultsController].fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
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

-(void)filterWithCategoryPredicate:(NSPredicate *)predicate
{
    NSPredicate *currentPredicate;
    
    NSLog(@"Current Predicate Pieces:\n%@\n%@\n%@\n%@",[delegate factionPredicate],[delegate realmPredicate],[delegate categoryPredicate],[delegate searchPredicate]);
    //Make sure the given predicate is not nil, or else the compound predicate array will terminate early.
    if(predicate != nil)
    {
        currentPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[delegate factionPredicate],[delegate realmPredicate],predicate,[delegate searchPredicate], nil]];
    }
    else
    {
        currentPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[delegate factionPredicate],[delegate realmPredicate],[delegate searchPredicate], nil]];
    }
    
    NSLog(@"Current Predicate: %@",currentPredicate);
    [self filterAuctionTable:currentPredicate];
}

-(void)filterWithSearchPredicate:(NSPredicate *)predicate
{
    NSPredicate *currentPredicate;
    NSLog(@"Current Predicate Pieces:\n%@\n%@\n%@\n%@",[delegate factionPredicate],[delegate realmPredicate],[delegate categoryPredicate],[delegate searchPredicate]);
    //Make sure the given predicate is not nil, or else the compound predicate array will terminate early.
    if(predicate != nil)
    {
        currentPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[delegate factionPredicate],[delegate realmPredicate],predicate,[delegate categoryPredicate], nil]];
    }
    else
    {
        currentPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[delegate factionPredicate ],[delegate realmPredicate],[delegate categoryPredicate], nil]];
    }
    
    NSLog(@"Current Predicate: %@",currentPredicate);
    [self filterAuctionTable:currentPredicate];
}

- (void)filterWithSearchPredicate:(NSPredicate *)predicate andSort:(NSSortDescriptor *)sort
{
    NSPredicate *currentPredicate;
    NSLog(@"Current Predicate Pieces:\n%@\n%@\n%@\n%@",[delegate factionPredicate],[delegate realmPredicate],[delegate categoryPredicate],[delegate searchPredicate]);
    //Make sure the given predicate is not nil, or else the compound predicate array will terminate early.
    if(predicate != nil)
    {
        currentPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[delegate factionPredicate],[delegate realmPredicate],[delegate searchPredicate],[delegate categoryPredicate], nil]];
    }
    else
    {
        currentPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[delegate factionPredicate],[delegate realmPredicate],[delegate categoryPredicate], nil]];
    }
    
    NSLog(@"Current Predicate: %@",currentPredicate);
    [self filterAuctionTable:currentPredicate andSort:sort];
}

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
    barButtonItem.title = NSLocalizedString(@"Browse", @"Browse");
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
    return [[_fetchedResultsController fetchedObjects] count];
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

- (void)configureCell:(AHPAuctionTableCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    //Try statement is necessary for when the table is refreshing. If the user is scrolling as the refresh completes, this function will generate an exception.
    @try {
        //#######################################
        //
        //Set all of the information that is contained in the auction lines JSON
        //
        //#######################################
        NSString *owner = [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"owner"];
        NSString *timeLeft = [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"timeLeft"];
        
        NSString *bidC,*bidS,*bidG,*buyoutC,*buyoutS,*buyoutG;
        int quant = [[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"quantity"] integerValue];
        NSString *quantity = [NSString stringWithFormat:@"%d",quant];
        if(_pricePerUnit)
        {
            bidG = [NSString stringWithFormat:@"%d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"bid"] integerValue]/10000/quant];
            bidS = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"bid"] integerValue]/100 %100 /quant];
            bidC = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"bid"] integerValue]%100 /quant];
            buyoutG = [NSString stringWithFormat:@"%d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"buyout"] integerValue]/10000 /quant];
            buyoutS = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"buyout"] integerValue]/100 %100 /quant];
            buyoutC = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"buyout"] integerValue]%100 /quant];
        }
        else
        {
            bidG = [NSString stringWithFormat:@"%d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"bid"] integerValue]/10000];
            bidS = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"bid"] integerValue]/100 %100];
            bidC = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"bid"] integerValue]%100];
            buyoutG = [NSString stringWithFormat:@"%d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"buyout"] integerValue]/10000];
            buyoutS = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"buyout"] integerValue]/100 %100];
            buyoutC = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"buyout"] integerValue]%100];
        }
        
        //Hide the quantity number for single items
        if(quant == 1)
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
        if([[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"buyout"] integerValue] == 0)
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
        if([[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"item"] integerValue] == 82800)
        {
            itemDictionary = [AHPPetAPIRequest petAPIRequest:[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"petSpeciesID"] integerValue]];
            
            [cell.itemName setTextColor:[qualityColors objectAtIndex: [[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"petQualityID"] integerValue]]];
            [cell.itemName setHighlightedTextColor:[qualityColors objectAtIndex: [[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"petQualityID"] integerValue]]];
            [cell.level setText: [NSString stringWithFormat:@"%@",[itemDictionary valueForKey:@"itemLevel"]]];
            [cell.itemName setText: [itemDictionary valueForKey:@"name"]];
            [cell.level setText: [NSString stringWithFormat:@"%d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"petLevel"] integerValue]]];
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
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemID == %@)", [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"item"]];
            [internalItemReq setEntity:item];
            [internalItemReq setPredicate:predicate];
            NSArray *result = [[delegate managedObjectContext] executeFetchRequest:internalItemReq error:nil];
            
            if([result count] != 0)
            {
                //If there is an existing item with the itemID we want, use that as the itemDictionary.
                itemDictionary = result[0];
            }
            else
            {
                //If an existing item with the desired itemID can't be found, fetch the data from the web and make a new coredata object for it.
                [AHPItemAPIRequest storeItem:[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"item"] integerValue] inContext:[delegate managedObjectContext]];
            }
            
            [cell.itemName setTextColor:[qualityColors objectAtIndex: [[itemDictionary valueForKey:@"quality"] intValue]]];
            [cell.itemName setHighlightedTextColor:[qualityColors objectAtIndex: [[itemDictionary valueForKey:@"quality"] intValue]]];
            [cell.level setText: [NSString stringWithFormat:@"%@",[itemDictionary valueForKey:@"itemLevel"]]];
            [cell.itemName setText: [itemDictionary valueForKey:@"name"]];
        }
        
        
        //#######################################
        //
        // Set Icons and Thumbnails
        //
        //#######################################
        NSFetchRequest *fetchIcon = [[NSFetchRequest alloc] init];
        [fetchIcon setEntity:[NSEntityDescription entityForName:@"Icon" inManagedObjectContext:[delegate managedObjectContext]]];
        [fetchIcon setPredicate:[NSPredicate predicateWithFormat:@"icon == %@",[itemDictionary valueForKey:@"icon"]]];
        NSError *error = nil;
        NSArray *fetchedIcons = [[delegate managedObjectContext] executeFetchRequest:fetchIcon error:&error];
        if([fetchedIcons count] > 0)
        {
            NSData *thumbnailData = [fetchedIcons[0] valueForKey:@"thumbnail"];
            UIImage *thumbnailImage = [UIImage imageWithData:thumbnailData];
            [cell.icon setImage:thumbnailImage];
        }
        else
        {
            NSData *thumbnailData = [AHPImageRequest imageRequestWithPath:[itemDictionary valueForKey:@"icon"]];
            UIImage *thumbnailImage = [UIImage imageWithData:thumbnailData];
            [cell.icon setImage:thumbnailImage];
            
            NSManagedObject *newIcon = [NSEntityDescription insertNewObjectForEntityForName:@"Icon" inManagedObjectContext:[delegate managedObjectContext]];
            [newIcon setValue:thumbnailData forKey:@"thumbnail"];
            [newIcon setValue:[itemDictionary valueForKey:@"icon"] forKey:@"icon"];
            if(![[delegate managedObjectContext] save:&error])
            {
                NSLog(@"Error Saving Thumbnail: %@",error);
            }
            else
            {
                //NSLog(@"New thumbnail saved as: %@",[itemDictionary valueForKey:@"icon"]);
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cell was deleted while loading");
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

//Functions for the rightBarButtonItems Array.
-(IBAction)refreshButton:(id)sender
{
    [self refreshAuctionDatabase];
}

- (IBAction)searchButton:(id)sender {
    /*
    NSEntityDescription *dumps = [NSEntityDescription entityForName:@"AuctionDumpDate" inManagedObjectContext:[delegate managedObjectContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:dumps];
    NSArray *array = [[delegate managedObjectContext] executeFetchRequest:fetchRequest error:Nil];
    
    for(NSManagedObject *object in array)
    {
        NSLog(@"%@ - %@",
              [object valueForKey:@"dumpURL"],
              [AHPAPIRequest convertWOWTime:[[object valueForKey:@"date"] doubleValue]]);
    }
    */
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    AHPSearchViewController *searchView = [storyboard instantiateViewControllerWithIdentifier:@"searchViewSB"];
    [searchView setDetailView:self];
    [self.navigationController pushViewController:searchView animated:YES];
    
}

-(IBAction)realmSelect:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    AHPRealmSelectViewController *realmSelect = [storyboard instantiateViewControllerWithIdentifier:@"RealmSelectSB"];
    [realmSelect setDetailView:self];
    [self.navigationController pushViewController:realmSelect animated:YES];
}

@end
