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

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"name"] description];
    }
}

//For now, all of the set-up is handled in this method. I.E. importing the auction data, checking if it is up to date
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [self configureView];
    delegate = (AHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = [delegate managedObjectContext];
    
    //Set the datasource for the UITableView. Initially you get all auctions by using filterAuctionTable with a nil predicate. The filterAuctionTable method is used primarily for setting filters from the masterView.
    [_auctionTable setDataSource:self];
    
    
    //Set the upper right buttons - refresh table and return to realm/faction select
    UIBarButtonItem *realmSelect = [[UIBarButtonItem alloc] initWithTitle:@"Realm" style:UIBarButtonItemStyleBordered target:self action:@selector(realmSelect:)];
    UIBarButtonItem *factionSelect = [[UIBarButtonItem alloc] initWithTitle:@"Faction" style:UIBarButtonItemStyleBordered target:self action:@selector(factionSelect:)];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButton:)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(forceRefreshAuctionDatabase)];
    NSArray *array = [[NSArray alloc] initWithObjects: realmSelect, factionSelect,searchButton,refreshButton, nil];
    
    [self.navigationItem setRightBarButtonItems:array animated:YES];
    
    [self.progressBar setHidden:YES];
    
    //Remove this code later
    [self refreshAuctionDatabase];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"item ==54443"];
    [self filterAuctionTable:pred];
}

//Will refresh the auction database if it is out of date.
-(void) refreshAuctionDatabase
{
    [self.progressBar setHidden:NO];
    
    //Grab the link to the JSON file and its lastModified date.
    AHPAPIRequest *auctionData = [[AHPAPIRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://battle.net/api/wow/auction/data/%@",[delegate realm]]]];
    
    //If the auction data dump is more recent than the one in coredata, delete all of the coredata Auction objects and repopulate the database.
    //TODO: Look into whether or not it would be faster to check if an auctionID is still there, and not delete that one.
    NSLog(@"\nAuction Data last Generated: %@\nAuction Data in persistent store last generated: %@", [AHPAPIRequest convertWOWTime:[[auctionData lastModified] doubleValue]],[AHPAPIRequest convertWOWTime:[auctionData getLastDumpInContext:[delegate managedObjectContext]]]);
    
    if([auctionData getLastDumpInContext:[delegate managedObjectContext]] != [[auctionData lastModified] doubleValue])
    {
        NSLog(@"Refreshing Auction Database");
        NSFetchRequest *fetchAllAuctions = [[NSFetchRequest alloc] init];
        [fetchAllAuctions setEntity:[NSEntityDescription entityForName:@"Auction" inManagedObjectContext:[delegate managedObjectContext]]];
        [fetchAllAuctions setIncludesPropertyValues:NO];
        
        NSError *error = nil;
        NSArray *allAuctions = [[delegate managedObjectContext] executeFetchRequest:fetchAllAuctions error:&error];
        int num = 0;
        for(NSManagedObject *auction in allAuctions)
        {
            [[delegate managedObjectContext] deleteObject:auction];
            num++;
        }
        if(![[delegate managedObjectContext] save:&error])
        {
            NSLog(@"Error clearing store: %@",error);
        }
        NSLog(@"Deleted %d Old Auctions",num);
        //Insert the new auctions into the persistent store
        [auctionData storeAuctions: [delegate managedObjectContext]];
    }
    
    NSLog(@"Stored Horde Auctions: %d",[[auctionData hordeAuctions] count]);
    
    [_auctionTable reloadData];
    
    [self.progressBar setHidden:YES];
}

//Will refresh the auction database, even if it is up to date
-(void) forceRefreshAuctionDatabase
{
    //Disable the button until the refresh is completed.
    UIBarButtonItem *refreshButton = [self.navigationItem.rightBarButtonItems objectAtIndex:3];
    [refreshButton setEnabled:NO];
    
    //Grab the link to the JSON file and its lastModified date.
    AHPAPIRequest *auctionData = [[AHPAPIRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://battle.net/api/wow/auction/data/%@",[delegate realm]]]];
    
    NSLog(@"Force Refreshing Auction Database");
    //Moving this functionality into the background thread below, so the user can browse old auctions while refreshing
    /*
    NSFetchRequest *fetchAllAuctions = [[NSFetchRequest alloc] init];
    [fetchAllAuctions setEntity:[NSEntityDescription entityForName:@"Auction" inManagedObjectContext:[delegate managedObjectContext]]];
    [fetchAllAuctions setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *allAuctions = [[delegate managedObjectContext] executeFetchRequest:fetchAllAuctions error:&error];
    int num = 0;
    for(NSManagedObject *auction in allAuctions)
    {
        [[delegate managedObjectContext] deleteObject:auction];
        num++;
    }
    if(![[delegate managedObjectContext] save:&error])
    {
        NSLog(@"Error clearing store: %@",error);
    }
    NSLog(@"Deleted %d Old Auctions",num);
    */
    
    //Insert the new auctions into the persistent store
    dispatch_queue_t backgroundQueue;
    backgroundQueue = dispatch_queue_create("com.ragbinder.AHParser.background", NULL);
    dispatch_async(backgroundQueue, ^(void){
        [auctionData storeAuctions: [delegate managedObjectContext] withProgress:[self progressBar] withTableView:[self auctionTable]];
        
        //Re-enable the refresh button after the data operation is complete.
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [refreshButton setEnabled:YES];
            [self filterAuctionTable:nil];
        });
    });
}

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
//Sample Predicate: "(item == 72095)" for trillium bar
- (void)filterAuctionTable: (NSPredicate *) predicate
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Auction" inManagedObjectContext:[delegate managedObjectContext]];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"auc" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"itemRelationship.itemClass" ascending:YES];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:predicate];
    [fetch setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil]];
    
    NSError *error;
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    [[self fetchedResultsController].fetchRequest setPredicate:predicate];
    [[self fetchedResultsController] performFetch:&error];
    NSLog(@"Performing Fetch with FetchRequest: %@",[_fetchedResultsController fetchRequest]);
    NSLog(@"Fetch Returned %d Results",[[_fetchedResultsController fetchedObjects] count]);
    if(error)
    {
        NSLog(@"Error filtering auction table: %@",error);
    }
    NSArray *entities = [_managedObjectContext executeFetchRequest:[_fetchedResultsController fetchRequest] error:&error];
    NSLog(@"Entities Count: %d",[entities count]);
    [_auctionTable reloadData];
}

//Shouldn't be using this method in the future
- (void)filterAuctionTableByString: (NSString*) predicateString
{
    NSArray *predicateParts = [predicateString componentsSeparatedByString:@" "];
    NSPredicate *predicate;
    if([predicateParts count] == 0)
    {
        predicate = nil;
    }
    else if([predicateParts count] == 3)
    {
        predicate = [NSPredicate predicateWithFormat:@"(%K == %d)",predicateParts[0],[predicateParts[2] intValue]];
    }
    else if([predicateParts count] == 7)
    {
        predicate = [NSPredicate predicateWithFormat:@"(%K == %d) && (%K == %d)",predicateParts[0],[predicateParts[2] intValue],predicateParts[4],[predicateParts[6] intValue]];
    }
    else if([predicateParts count] == 11)
    {
        predicate = [NSPredicate predicateWithFormat:@"(%K == %d) && (%K == %d) && (%K == %d)",predicateParts[0],[predicateParts[2] intValue],predicateParts[4],[predicateParts[6] intValue],predicateParts[8],[predicateParts[10] intValue]];
    }
    else
    {
        NSLog(@"Invalid Predicate Used: %@",predicateString);
        return;
    }
    NSLog(@"Filtering Table By Predicate (String): %@",predicate);
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Auction" inManagedObjectContext:[delegate managedObjectContext]];
    NSSortDescriptor *sortDescriptor0 = [[NSSortDescriptor alloc] initWithKey:@"auc" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"itemRelationship.itemClass" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"itemRelationship.itemSubClass" ascending:YES];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:predicate];
    [fetch setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor0, nil]];
    
    NSError *error;
    //[NSFetchedResultsController deleteCacheWithName:@"Root"];
    [_fetchedResultsController.fetchRequest setPredicate:predicate];
    [_fetchedResultsController.fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor0,nil]];
    [_fetchedResultsController performFetch:&error];
    NSLog(@"Performing Fetch with FetchRequest: %@",[_fetchedResultsController fetchRequest]);
    NSLog(@"Fetch Returned %d Results",[[_fetchedResultsController fetchedObjects] count]);
    if(error)
    {
        NSLog(@"Error filtering auction table: %@",error);
    }
    NSArray *entities = [_managedObjectContext executeFetchRequest:[_fetchedResultsController fetchRequest] error:&error];
    NSLog(@"Entities Count: %d",[entities count]);
    [_auctionTable reloadData];
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
    barButtonItem.title = NSLocalizedString(@"Category Filters", @"Category Filters");
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
    //NSLog(@"Displaying Cell at index path: %@",indexPath);
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
    //NSLog(@"Configuring Cell at index path: %@",indexPath);
    //#######################################
    //
    //Set all of the information that is contained in the auction lines JSON
    //
    //#######################################
    @try {
    NSString *owner = [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"owner"];
    NSString *timeLeft = [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"timeLeft"];
    NSString *bidG = [NSString stringWithFormat:@"%d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"bid"] integerValue]/10000];
    NSString *bidS = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"bid"] integerValue]/100 %100];
    NSString *bidC = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"bid"] integerValue]%100];
    NSString *buyoutG = [NSString stringWithFormat:@"%d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"buyout"] integerValue]/10000];
    NSString *buyoutS = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"buyout"] integerValue]/100 %100];
    NSString *buyoutC = [NSString stringWithFormat:@"%02d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"buyout"] integerValue]%100];
    NSString *quantity = [NSString stringWithFormat:@"%d",[[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"quantity"] integerValue]];
    if([quantity isEqualToString:@"1"])
    {    quantity = @"";}
    
    [cell.owner setText:owner];
    [cell.bidG setText:bidG];
    [cell.bidS setText:bidS];
    [cell.bidC setText:bidC];
    [cell.buyoutG setText:buyoutG];
    [cell.buyoutS setText:buyoutS];
    [cell.buyoutC setText:buyoutC];
    [cell.timeLeft setText:[AHPDetailViewController timeLeftFormat:timeLeft]];
    [cell.quantity setText:quantity];
    
    if([[[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"buyout"] integerValue] == 0)
    {
        [cell.buyoutC setHidden:YES];
        [cell.buyoutS setHidden:YES];
        [cell.buyoutG setHidden:YES];
        [cell.buyoutCImage setHidden:YES];
        [cell.buyoutGImage setHidden:YES];
        [cell.buyoutSImage setHidden:YES];
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
    
    
    //Blizz handles pets differently from normal items in the auction API, so this code deals with correctly displaying them. Otherwise, they'd all display as Pet Cages (Item ID 82800).
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
    else{
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
    //NSLog(@"Predicate: %@", predicate);
    NSArray *result = [[delegate managedObjectContext] executeFetchRequest:internalItemReq error:nil];
    
    //NSDictionary *itemDictionary;
    if([result count] != 0)
    {
        //If there is an existing item with the itemID we want, use that as the itemDictionary.
        itemDictionary = result[0];
    }
    else
    {
        //If an existing item with the desired itemID can't be found, fetch the data from the web and make a new coredata object for it.
        //This code should be obsolete by launch, as we will be using a pre-populated item database. Keeping this in so that the app will still function without an update to the database when new items are added.
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
    @finally {
        
    }
}

- (void)printItemsOfSameClass:(NSInteger) class
{
    NSFetchRequest *fetchRequest = [NSFetchRequest alloc];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Auction" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [self.fetchedResultsController fetchRequest];
}

//Fixed- needed to set the delegate for the UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *auction = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //Code to fetch item dictionary from internal item database
    /*
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:[delegate managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID == %@",[auction valueForKey:@"item"]];
    [fetch setEntity:entity];
    [fetch setPredicate:predicate];
    [fetch setReturnsObjectsAsFaults:NO];
    NSArray *result = [[delegate managedObjectContext] executeFetchRequest:fetch error:nil];
    */
    //Code to fetch item dictionary from web API
    //AHPItemAPIRequest *item = [[AHPItemAPIRequest alloc] init];
    //NSDictionary *result = [item itemAPIRequest:[[auction valueForKey:@"item"] intValue]];
    
    //NSLog(@"Selected Cell: %@",result);
    if([[auction valueForKey:@"itemFetch"] count] != 0)
    NSLog(@"[%@ - %@] %@: %@",[[[auction valueForKey:@"itemFetch"] objectAtIndex:0] valueForKey:@"itemClass"],[[[auction valueForKey:@"itemFetch"] objectAtIndex:0] valueForKey:@"itemSubClass"],[[[auction valueForKey:@"itemFetch"] objectAtIndex:0] valueForKey:@"itemID"],[[[auction valueForKey:@"itemFetch"] objectAtIndex:0] valueForKey:@"name"]);
}

//This is a function for formatting the timeLeft value returned from the JSON so that it is more readable.
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

- (IBAction)searchButton:(id)sender {
    [self filterAuctionTableByString:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
