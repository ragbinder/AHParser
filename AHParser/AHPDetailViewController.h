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

@class AHPAppDelegate;

@interface AHPDetailViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
{
    AHPAppDelegate *delegate;
}
@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITableView *auctionTable;
//@property NSArray *auctionsArray;

- (void)filterAuctionTable:(NSPredicate*)predicate;
- (void)filterAuctionTableByString:(NSString*)predicateString;
+ (NSString*)timeLeftFormat:(NSString*)timeLeft;

@end
