//
//  AHPRealmSelectViewController.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 10/14/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AHPRealmStatusRequest.h"
#import "AHPRealmSelectCell.h"
#import "AHPCustomCellBackground.h"
#import "AHPAppDelegate.h"
#import "AHPAPIRequest.h"
#import "AHPDetailViewController.h"

@interface AHPRealmSelectViewController : UITableViewController <UITableViewDataSource>
{
    AHPAppDelegate *delegate;
}
@property NSArray *realms;
@property (strong, nonatomic) IBOutlet UITableView *realmTable;
@property (strong, nonatomic) AHPDetailViewController *detailView;
@property (strong, nonatomic) NSString *faction;

@end
