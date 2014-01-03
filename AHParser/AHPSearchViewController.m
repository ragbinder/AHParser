//
//  AHPSearchViewController.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 12/19/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPSearchViewController.h"

@interface AHPSearchViewController ()

@end

@implementation AHPSearchViewController
@synthesize detailView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    delegate = (AHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.searchBar setDelegate:self];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search Clicked");
    
    //Setup the sort descriptor to be applied to the detail view.
    BOOL ascDesc;
    if ([self.ascDescBar selectedSegmentIndex] == 0) {
        ascDesc = YES;
    }
    else
    {
        ascDesc = NO;
    }
    
    NSSortDescriptor *sort;
    
    switch ([self.sortByBar selectedSegmentIndex])
    {
        case 0:
            sort = [[NSSortDescriptor alloc] initWithKey:@"itemRelationship.name" ascending:ascDesc];
            break;
            
        case 1:
            sort = [[NSSortDescriptor alloc] initWithKey:@"timeLeft" ascending:ascDesc];
            break;
            
        case 2:
            sort = [[NSSortDescriptor alloc] initWithKey:@"itemRelationship.itemLevel" ascending:ascDesc];
            break;
            
        case 3:
            sort = [[NSSortDescriptor alloc] initWithKey:@"owner" ascending:ascDesc];
            break;
            
        case 4:
            sort = [[NSSortDescriptor alloc] initWithKey:@"buyout" ascending:ascDesc];
            break;
            
        default:
            sort = [[NSSortDescriptor alloc] initWithKey:@"auc" ascending:ascDesc];
            break;
    }
    
    //Set the search predicate.
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"itemRelationship.name CONTAINS %@",searchBar.text];
    
    
    //Set price per unit/stack boolean variable in detail view controller.
    if([self.stackUnitBar selectedSegmentIndex] == 0)
    {
        [detailView setPricePerUnit: NO];
    }
    else
    {
        [detailView setPricePerUnit: YES];
    }
    
    NSLog(@"Search Predicate:\n%@\n%@",searchPredicate,sort);
    
    //Combine the search and sort predicates and apply them to the detail view.
    [delegate setSearchPredicate:searchPredicate];
    [detailView filterWithSearchPredicate:searchPredicate andSort:sort];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sortByBar:(id)sender {
    NSLog(@"sortByBar event");
}

- (IBAction)ascDescBar:(id)sender {
    NSLog(@"ascDescBar event");
}

- (IBAction)stackUnitBar:(id)sender {
    NSLog(@"stackUnitBar event");
    //[delegate set]
}
@end
