//
//  AHPMasterViewController.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/23/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPMasterViewController.h"
#import "AHPDetailViewController.h"

@interface AHPMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation AHPMasterViewController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (id)initWithTitle:(NSString*)title andDictionary:(NSDictionary*)dictionary
{
    _dictionary = dictionary;
    self.navigationItem.title = title;
    self.view.backgroundColor = [UIColor blackColor];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Master View did Load with title: %@",self.title);
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.detailViewController = (AHPDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    NSLog(@"Master View did set detail controller");
    
    _rows = [[NSMutableArray alloc] initWithArray:[_dictionary objectForKey:@"subclasses"]];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(applyFilters:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

-(IBAction)applyFilters:(id)sender
{
    //[self indexPathForSelectedRow];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemRelationship.itemClass == %d)",[[_dictionary valueForKey:@"class"] integerValue]];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(item == %d)",54443];
    NSLog(@"%@",predicate);
    [self.detailViewController filterAuctionTable:predicate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self dictionary] objectForKey:@"subclasses"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedRow = [_rows objectAtIndex:indexPath.row];
    
    if([selectedRow valueForKey:@"subclasses"] != nil)
    {
        AHPMasterViewController *newView = [[[AHPMasterViewController alloc] initWithStyle:UITableViewStyleGrouped] initWithTitle:[selectedRow valueForKey:@"name"] andDictionary:[AHPCategoryLoader findDictionaryWithValue:[selectedRow valueForKey:@"name"] forKey:@"name" inArray:[_dictionary objectForKey:@"subclasses"]]];
        newView.detailViewController = self.detailViewController;
        [self.navigationController pushViewController:newView animated:YES];
    }
    else
    {
        //[self.detailViewController filterAuctionTableByString:[object valueForKey:@"predicate"]];
    }
    
    NSLog(@"Dictionary for selected Row: %@",selectedRow);
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [[_rows objectAtIndex:indexPath.row ] valueForKey:@"name"];
}

#pragma mark UITableViewDelegate
- (void)tableView: (UITableView*)tableView
  willDisplayCell: (UITableViewCell*)cell
forRowAtIndexPath: (NSIndexPath*)indexPath
{
    /*
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
     */
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
