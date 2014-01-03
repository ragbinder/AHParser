//
//  AHPRealmSelectViewController.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 10/14/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPRealmSelectViewController.h"

@interface AHPRealmSelectViewController ()

@end

@implementation AHPRealmSelectViewController

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
 
    _realms = [AHPRealmStatusRequest realmStatus];
    
    [_realmTable setDataSource:self];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    //Set up the faction select buttons
    NSArray *factions = [NSArray arrayWithObjects:@"Alliance",@"Neutral",@"Horde", nil];
    UISegmentedControl *factionSelect = [[UISegmentedControl alloc] initWithItems:factions];
    UIBarButtonItem *factionSelectButton = [[UIBarButtonItem alloc] initWithCustomView:factionSelect];
    [self.navigationItem setRightBarButtonItem:factionSelectButton animated:animated];
    
    //Link the segmented control to the setFactionForDelegate: method
    [factionSelect addTarget:self
                         action:@selector(setFactionForDelegate:)
               forControlEvents:UIControlEventValueChanged];
    
    //Set the segmented control selection to be what is currently in the delegate.
    if([[delegate faction] isEqualToString:@"Alliance"])
    {
        [factionSelect setSelectedSegmentIndex:0];
    }
    if ([delegate.faction isEqualToString:@"Neutral"])
    {
        [factionSelect setSelectedSegmentIndex:1];
    }
    if ([delegate.faction isEqualToString:@"Horde"])
    {
        [factionSelect setSelectedSegmentIndex:2];
    }
}

-(void) setFactionForDelegate:(UISegmentedControl*)faction
{
    NSString *factionString = [faction titleForSegmentAtIndex:[faction selectedSegmentIndex]];
    [delegate setFaction:factionString];
    [delegate setFactionPredicate:[NSPredicate predicateWithFormat:@"dumpRelationship.faction == %@",factionString]];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_realms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RealmCell";
    AHPRealmSelectCell *cell = [tableView
                                dequeueReusableCellWithIdentifier:CellIdentifier
                                forIndexPath:indexPath];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    delegate.realm = [[_realms objectAtIndex:indexPath.row] objectForKey:@"slug"];
    delegate.realmProper = [[_realms objectAtIndex:indexPath.row] objectForKey:@"name"];
    delegate.realmURL = [[[[AHPAPIRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://us.battle.net/api/wow/auction/data/%@",[[_realms objectAtIndex:indexPath.row] objectForKey:@"slug"]]]] auctionDataURL] description];
    //NSLog(@"JANK:%@",delegate.realmURL);
    NSPredicate *realmPredicate = [NSPredicate predicateWithFormat:@"dumpRelationship.dumpURL == %@",delegate.realmURL];
    [delegate setRealmPredicate:realmPredicate];
    //NSLog(@"Selected: %@", [[_realms objectAtIndex:indexPath.row] objectForKey:@"slug"]);
}

@end
