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
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) AHPDetailViewController *detailView;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;
- (IBAction)sortByBar:(id)sender;
- (IBAction)ascDescBar:(id)sender;
- (IBAction)loadItems:(id)sender;

@end
