//
//  AHPMasterViewController.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/23/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AHPDetailViewController;

#import <CoreData/CoreData.h>
#import "AHPCategoryLoader.h"

@interface AHPMasterViewController : UITableViewController <UITableViewDataSource>

@property (strong, nonatomic) NSDictionary *dictionary;
@property (strong, nonatomic) NSMutableArray *rows;
@property (strong, nonatomic) AHPDetailViewController *detailViewController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

-(id)initWithTitle:(NSString*)title andDictionary:(NSDictionary*)dictionary;
-(IBAction)applyFilters:(id)sender;

@end