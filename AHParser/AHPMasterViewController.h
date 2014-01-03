//
//  AHPMasterViewController.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/23/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AHPDetailViewController;
@class AHPAppDelegate;

#import <CoreData/CoreData.h>
#import "AHPCategoryLoader.h"
#import "AHPAppDelegate.h"

@interface AHPMasterViewController : UITableViewController <UITableViewDataSource>
{
    AHPAppDelegate *delegate;
}

@property (strong, nonatomic) NSDictionary *dictionary;
@property (strong, nonatomic) NSMutableArray *rows;
@property (strong, nonatomic) AHPDetailViewController *detailViewController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

-(id)initWithTitle:(NSString*)title andDictionary:(NSDictionary*)dictionary;
-(IBAction)applyFilters:(id)sender;
- (IBAction)clearFilters:(id)sender;

@end