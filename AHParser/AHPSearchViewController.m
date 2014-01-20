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
    [self.searchBar setShowsSearchResultsButton:YES];
}

- (NSSortDescriptor*)getSortDescriptor
{
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
            //Had to write a custom comparator to sort the Time Remaining field correctly
            sort = [NSSortDescriptor sortDescriptorWithKey:@"timeLeft" ascending:ascDesc comparator:^(id obj1, id obj2){
                int o1,o2;
                if([obj1 isEqualToString:@"Short"])
                    o1 = 0;
                if([obj2 isEqualToString:@"Short"])
                    o2 = 0;
                
                if([obj1 isEqualToString:@"Medium"])
                    o1 = 1;
                if([obj2 isEqualToString:@"Medium"])
                    o2 = 1;
                
                if([obj1 isEqualToString:@"Long"])
                    o1 = 2;
                if([obj2 isEqualToString:@"Long"])
                    o2 = 2;
                
                if([obj1 isEqualToString:@"Very Long"])
                    o1 = 3;
                if([obj2 isEqualToString:@"Very Long"])
                    o2 = 3;
                
                if(o1 > o2)
                    return (NSComparisonResult)NSOrderedDescending;
                if(o1 < o2)
                    return (NSComparisonResult)NSOrderedAscending;
                return (NSComparisonResult)NSOrderedSame;
            }
                    ];
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
    
    return sort;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search Clicked");
    
    //Set the search predicate and sort descriptor.
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"itemRelationship.name CONTAINS[cd] %@",searchBar.text];
    NSSortDescriptor *sort = [self getSortDescriptor];
    
    NSLog(@"Search Predicate:\n%@\n%@",searchPredicate,sort);
    
    //Apply search predicate and sort descriptor to the detail view.
    [delegate setSearchPredicate:searchPredicate];
    [delegate setSortDescriptors:[NSArray arrayWithObject:sort]];
    [detailView applyCurrentFilters];
    
    //Navigate back
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sortByBar:(id)sender
{
    NSSortDescriptor *defaultSort = [NSSortDescriptor sortDescriptorWithKey:@"auc" ascending:YES];
    [delegate setSortDescriptors:[NSArray arrayWithObjects:[self getSortDescriptor], defaultSort, nil]];
    NSLog(@"Delegate sort descriptor set as: %@",[delegate sortDescriptors]);
}

- (IBAction)ascDescBar:(id)sender
{
    NSSortDescriptor *defaultSort = [NSSortDescriptor sortDescriptorWithKey:@"auc" ascending:YES];
    [delegate setSortDescriptors:[NSArray arrayWithObjects:[self getSortDescriptor], defaultSort, nil]];
    NSLog(@"Delegate sort descriptor set as: %@",[delegate sortDescriptors]);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
