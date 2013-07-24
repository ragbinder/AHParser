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

@interface AHPMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) AHPDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
