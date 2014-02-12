//
//  AHPDetailViewController.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/23/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AHPAPIRequest.h"
#import "AHPAuctionTableCell.h"
#import "AHPItemAPIRequest.h"
#import "AHPImageRequest.h"
#import "AHPPetAPIRequest.h"
#import <dispatch/dispatch.h>
#import "AHPRealmSelectViewController.h"
#import "AHPSearchViewController.h"

@class AHPAppDelegate;

@interface AHPDetailViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>
{
    AHPAppDelegate *delegate;
}
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITableView *auctionTable;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) UIBarButtonItem *realmSelect;

//Call this method to apply the current filters stored in the AppDelegate to the current auction table view. The data will be reloaded and the user will be presented with new data.
- (void)applyCurrentFilters;

@end
