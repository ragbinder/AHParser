//
//  AHPSearchViewController.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 12/19/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AHPDetailViewController.h"

@class AHPAppDelegate;

@interface AHPSearchViewController : UIViewController <UISearchBarDelegate>
{
    AHPAppDelegate *delegate;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortByBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ascDescBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *stackUnitBar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) AHPDetailViewController *detailView;

- (IBAction)sortByBar:(id)sender;
- (IBAction)ascDescBar:(id)sender;
- (IBAction)stackUnitBar:(id)sender;
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;

@end
