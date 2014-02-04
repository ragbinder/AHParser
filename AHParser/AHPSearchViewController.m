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
    [self.searchBar setShowsSearchResultsButton:NO];
    
    [self.sortByBar setSelectedSegmentIndex:-1];
    [self.ascDescBar setSelectedSegmentIndex:-1];
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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Cancel button clicked.");
    
    [delegate setSearchPredicate:nil];
    [detailView applyCurrentFilters];
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

- (IBAction)loadItems:(id)sender {
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    //NSEntityDescription *itemEntity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    NSEntityDescription *petEntity = [NSEntityDescription entityForName:@"Pet" inManagedObjectContext:context];
    
    //NSFetchRequest *itemFetch = [[NSFetchRequest alloc] init];
    //[itemFetch setEntity:itemEntity];
    NSFetchRequest *petFetch = [[NSFetchRequest alloc] init];
    [petFetch setEntity:petEntity];
    
    NSError *error;
    //NSArray *itemFetchResults = [NSArray alloc];
    NSArray *petFetchResults = [NSArray alloc];
    for (int i = 1000; i<2000; i++) {
        //NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"itemID = %d", i];
        NSPredicate *petPredicate = [NSPredicate predicateWithFormat:@"speciesID = %d",i];
        
        NSLog(@"petPredicate: %@",petPredicate);
        [petFetch setPredicate:petPredicate];
        
        petFetchResults = [context executeFetchRequest:petFetch error:&error];
        
        if(error)
        {
            NSLog(@"Error adding pet ID %d to internal database.\n%@",i,error);
        }
        
        if([petFetchResults count] == 0)
        {
            if([AHPPetAPIRequest storePet:i inContext:context])
            {
                NSLog(@"Stored pet %d",i);
            }
        }
        else
        {
            NSLog(@"Pet already exists for %d",i);
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
