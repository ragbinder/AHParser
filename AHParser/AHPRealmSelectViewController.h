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

@interface AHPRealmSelectViewController : UITableViewController <UITableViewDataSource>

@property NSArray *realms;
@property (strong, nonatomic) IBOutlet UITableView *realmTable;

@end
