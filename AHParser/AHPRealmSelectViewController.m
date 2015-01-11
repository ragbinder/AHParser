//
//  AHPRealmSelectViewController.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 10/14/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPRealmSelectViewController.h"

/*
@interface AHPRealmSelectViewController ()

@end
*/

@implementation AHPRealmSelectViewController
@synthesize faction = _faction;
@synthesize realms = _realms;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    delegate = (AHPAppDelegate *)[[UIApplication sharedApplication] delegate];
 
    //Moved to viewDidAppear to refresh whenever the view is reloaded.
    _realms = [[NSArray alloc] init];
    
    [_realmTable setDataSource:self];
    
    //Set up the faction select buttons
//    NSArray *factions = [NSArray arrayWithObjects:@"Alliance",@"Neutral",@"Horde", nil];
//    UISegmentedControl *factionSelect = [[UISegmentedControl alloc] initWithItems:factions];
//    UIBarButtonItem *factionSelectButton = [[UIBarButtonItem alloc] initWithCustomView:factionSelect];
    
    //Set up the Refresh Realms button
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButton)];
    
    //Add the bar buttons to the view
    NSArray *barButtonArray = [[NSArray alloc] initWithObjects:/*factionSelectButton,*/refreshButton, nil];
    [self.navigationItem setRightBarButtonItems:barButtonArray animated:NO];
    
    //Link the segmented control to the setFactionForDelegate: method
//    [factionSelect addTarget:self
//                      action:@selector(setFactionForDelegate:)
//            forControlEvents:UIControlEventValueChanged];
    //Lazy way to load the realms in
    [self refreshButton];
}

-(void) viewDidAppear:(BOOL)animated
{
    /*
    _realms = [AHPRealmStatusRequest realmStatus];
    [_realmTable reloadData];
    NSLog(@"Realms :%@",_realms);
    */
}

-(void) refreshButton
{
    //Disable the button until the refresh is completed.
    UIBarButtonItem *refreshButton = [self.navigationItem.rightBarButtonItems objectAtIndex:0];
    [refreshButton setEnabled:NO];
    
    dispatch_queue_t backgroundQueue;
    backgroundQueue = dispatch_queue_create("com.ragbinder.AHParser.background.realm", NULL);
    dispatch_async(backgroundQueue, ^(void){
        _realms = [AHPRealmStatusRequest realmStatus];
        //[_realmTable reloadData];
        //NSLog(@"Realms :%@",_realms);
        
        //Re-enable the refresh button and filter the auction table after the data operation is complete.
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if([_realms count] == 0)
            {
                UIAlertView *noServersAlert = [[UIAlertView alloc] initWithTitle:@"Realm Status Error" message:@"No Realms were found. Please make sure your device is connected to the internet and try again." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [noServersAlert show];
            }
            
            [refreshButton setEnabled:YES];
            [_realmTable reloadData];
        });
    });
}

-(void) setFactionForDelegate:(UISegmentedControl*)factionBar
{
    _faction = [factionBar titleForSegmentAtIndex:[factionBar selectedSegmentIndex]];
    //[delegate setFaction:factionString];
    //[delegate setFactionPredicate:[NSPredicate predicateWithFormat:@"dumpRelationship.faction == %@",factionString]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView*) tableView
 numberOfRowsInSection:(NSInteger) section
{
    // Return the number of rows in the section.
    return [_realms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RealmCell";
    AHPRealmSelectCell *cell = [tableView
                                dequeueReusableCellWithIdentifier:CellIdentifier
                                forIndexPath:indexPath];
    
    //Set the cell selection background
    if(![cell.selectedBackgroundView isKindOfClass:[AHPCustomCellBackground class]])
    {
        cell.selectedBackgroundView = [[AHPCustomCellBackground alloc] init];
    }
    
    /*
    UIView *bgView = [[UIView alloc] init];
    [bgView setBackgroundColor:[UIColor blueColor]];
    cell.selectedBackgroundView = bgView;
    */
    
    // Configure the cell...
    [cell.realmName setText: [[_realms objectAtIndex:indexPath.row] objectForKey:@"name"]];
    if([[[_realms objectAtIndex:indexPath.row] objectForKey:@"status"] intValue] == 1)
    {
        [cell.realmStatus setText: @"Online"];
        [cell.realmStatus setTextColor: [UIColor greenColor]];
        [cell.realmStatus setHighlightedTextColor: [UIColor greenColor]];
    }
    else if([[[_realms objectAtIndex:indexPath.row] objectForKey:@"status"] intValue] == 0)
    {
        [cell.realmStatus setText: @"Offline"];
        [cell.realmStatus setTextColor: [UIColor redColor]];
        [cell.realmStatus setHighlightedTextColor: [UIColor redColor]];
    }
    
    [cell.population setText:[[[_realms objectAtIndex:indexPath.row] objectForKey:@"population"] capitalizedString]];
    
    //Code to format the server type text to be capitalized correctly.
    if([[[_realms objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"pvp"])
    {
        [cell.type setText:@"PvP"];
    }
    else if([[[_realms objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"rp"])
    {
        [cell.type setText:@"RP"];
    }
    else if([[[_realms objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"rppvp"])
    {
        [cell.type setText:@"RPPvP"];
    }
    else if([[[_realms objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"pve"])
    {
        [cell.type setText:@"PvE"];
    }
    
    //Format Colors
    [cell setBackgroundColor:[UIColor blackColor]];
    [cell.realmName setTextColor:[UIColor whiteColor]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
//This method sets the RealmURL object in the delegate to correspond to the selected realm. It also changes the dump object in the delegate to be the latest (if any) dump for that realm.
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *realm = [[_realms objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSString *slug = [[_realms objectAtIndex:indexPath.row] objectForKey:@"slug"];
    
    //Check if there are any existing realmURL objects for the given slug.
    NSError *error;
    NSFetchRequest *fetchURLBySlug = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RealmURL" inManagedObjectContext:[delegate managedObjectContext]];
    NSPredicate *slugPredicate = [NSPredicate predicateWithFormat:@"slug == %@",slug];
    
    [fetchURLBySlug setEntity:entity];
    [fetchURLBySlug setPredicate:slugPredicate];
    
    NSArray *results = [delegate.managedObjectContext executeFetchRequest:fetchURLBySlug error:&error];
    
    //NSLog(@"%@",results);
    
    if([results count] == 1)
    {
        delegate.realmURL = [results objectAtIndex:0];
    }
    //If there isn't already a RealmURL object for that slug, create it and give it to the delegate.
    else if([results count] == 0)
    {
        NSManagedObject *realmURL = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:[delegate managedObjectContext]];
        
        [realmURL setValue:slug forKey:@"slug"];
        [realmURL setValue:realm forKey:@"realm"];
        
        delegate.realmURL = realmURL;
        
        if(![[delegate managedObjectContext] save:&error])
        {
            NSLog(@"Error saving managed object context: %@",error);
        }
    }
    else
    {
        NSLog(@"Error, %d realmURL objects found.",[results count]);
        //Still give it the first object
        delegate.realmURL = [results objectAtIndex:0];
    }
}

@end
