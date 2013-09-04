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
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    delegate = (AHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"Using URL: \n%@",@"http://battle.net/api/wow/auction/data/emerald-dream");
    
    NSDate *apiReqStart = [[NSDate alloc] init];
    AHPAPIRequest *auctionData = [[AHPAPIRequest alloc] initWithURL:[NSURL URLWithString:@"http://battle.net/api/wow/auction/data/emerald-dream"]];
    NSDate *apiReqEnd = [[NSDate alloc] init];
    //Store all of the auctions in the coreData database
    [auctionData storeAuctions: [delegate managedObjectContext]];
    
    NSTimeInterval diff = [apiReqEnd timeIntervalSinceDate:apiReqStart];
    NSLog(@"API Request took %f",diff);
    
    //Set the datasource for the UITableView
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Auction" inManagedObjectContext:[delegate managedObjectContext]];
    
    [fetchRequest setEntity:entityDescription];
    NSError *error;
    _auctionsArray = [[delegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    NSDate *coreDataEnd = [[NSDate alloc] init];
    diff = [coreDataEnd timeIntervalSinceDate:apiReqEnd];
    NSLog(@"Core Data took: %f",diff);
    //_auctionsArray = [auctionData hordeAuctions];
    
    [_auctionTable setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (IBAction)startButton:(id)sender
{
    
}

//Mandatory method for UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_auctionsArray count];
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
    NSString *owner = [[self.auctionsArray objectAtIndex:indexPath.row] valueForKey:@"owner"];
    NSString *timeLeft = [[self.auctionsArray objectAtIndex:indexPath.row] valueForKey:@"timeLeft"];
    NSString *bidG = [NSString stringWithFormat:@"%d",[[[self.auctionsArray objectAtIndex:indexPath.row] valueForKey:@"bid"] integerValue]/10000];
    NSString *bidS = [NSString stringWithFormat:@"%02d",[[[self.auctionsArray objectAtIndex:indexPath.row] valueForKey:@"bid"] integerValue]/100 %100];
    NSString *bidC = [NSString stringWithFormat:@"%02d",[[[self.auctionsArray objectAtIndex:indexPath.row] valueForKey:@"bid"] integerValue]%100];
    NSString *buyoutG = [NSString stringWithFormat:@"%d",[[[self.auctionsArray objectAtIndex:indexPath.row] valueForKey:@"buyout"] integerValue]/10000];
    NSString *buyoutS = [NSString stringWithFormat:@"%02d",[[[self.auctionsArray objectAtIndex:indexPath.row] valueForKey:@"buyout"] integerValue]/100 %100];
    NSString *buyoutC = [NSString stringWithFormat:@"%02d",[[[self.auctionsArray objectAtIndex:indexPath.row] valueForKey:@"buyout"] integerValue]%100];
    
    [cell.owner setText:owner];
    [cell.bidG setText:bidG];
    [cell.bidS setText:bidS];
    [cell.bidC setText:bidC];
    [cell.buyoutG setText:buyoutG];
    [cell.buyoutS setText:buyoutS];
    [cell.buyoutC setText:buyoutC];
    [cell.timeLeft setText:timeLeft];
    
    //WORKING HERE
    NSFetchRequest *internalItemReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *item = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:[delegate managedObjectContext]];
    [internalItemReq setEntity:item];
    //Need to set a predicate here, item ID of cell is in coredata
    
    NSArray *result = [[delegate managedObjectContext] executeFetchRequest:internalItemReq error:nil];
    NSDictionary *itemDictionary;
    if([result count] != 0)
    {
        NSLog(@"Found: %d",[result count]);
        //WRITE INTERFACE FOR TURNING FETCHED RESULT INTO NSDICTIONARY
        //itemDictionary = result;
    }
    else
    {
        AHPItemAPIRequest *itemReq = [AHPItemAPIRequest alloc];
        itemDictionary = [itemReq itemAPIRequest:[[[self.auctionsArray objectAtIndex:indexPath.row] valueForKey:@"item"] integerValue]];
    }
    
    [cell.level setText: [NSString stringWithFormat:@"%@",[itemDictionary valueForKey:@"itemLevel"]]];
    [cell.itemName setText: [itemDictionary valueForKey:@"name"]];
    
    //This changes the name color based on item quality
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
    [cell.itemName setTextColor:[qualityColors objectAtIndex: [[itemDictionary valueForKey:@"quality"] intValue]]];
    [cell.itemName setHighlightedTextColor:[qualityColors objectAtIndex: [[itemDictionary valueForKey:@"quality"] intValue]]];
    
    NSData *thumbnailData = [AHPImageRequest imageRequestWithPath:[itemDictionary valueForKey:@"icon"]];
    UIImage *thumbnailImage = [UIImage imageWithData:thumbnailData];
    [cell.icon setImage:thumbnailImage];
    
    
    return cell;
}


@end
