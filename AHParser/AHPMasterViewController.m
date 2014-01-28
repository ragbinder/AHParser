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
    self.clearsSelectionOnViewWillAppear = NO;
    delegate = (AHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.detailViewController = (AHPDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    //NSLog(@"Master View did set detail controller");
    
    _rows = [[NSMutableArray alloc] initWithArray:[_dictionary objectForKey:@"subclasses"]];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Apply"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(applyFilters:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [self.tableView setSeparatorColor:[UIColor lightGrayColor]];
}

//This method is linked to the done button in the master view. It is called when the user is done selecting a category filter
-(IBAction)applyFilters:(id)sender
{
    NSIndexPath *index = [[self tableView] indexPathForSelectedRow];
    NSPredicate *predicate;
    
    if(index != nil)
    {
        NSDictionary *selectedRow = [_rows objectAtIndex:index.row];
        //NSLog(@"%@",index);
        //NSLog(@"Selected Cell: %@",[[self tableView] cellForRowAtIndexPath:index]);
        
        if([selectedRow objectForKey:@"subclass"] != nil)
        {
            if([selectedRow objectForKey:@"inventoryType"] != nil)
            {
                predicate = [NSPredicate predicateWithFormat:@"(itemRelationship.itemClass == %d) AND (itemRelationship.itemSubClass == %d) AND (itemRelationship.inventoryType == %d)",[[selectedRow valueForKey:@"class"] integerValue],[[selectedRow valueForKey:@"subclass"] integerValue],[[selectedRow valueForKey:@"inventoryType"] integerValue]];
            }
            else
            {
                //If we are in the battlePet Menu
                if([[_dictionary valueForKey:@"class"] integerValue] == 17)
                {
                    predicate = [NSPredicate predicateWithFormat:@"(petRelationship.petTypeID == %d)",[[selectedRow valueForKey:@"subclass"] integerValue]];
                }
                else
                {
                    predicate = [NSPredicate predicateWithFormat:@"(itemRelationship.itemClass == %d) AND (itemRelationship.itemSubClass == %d)",[[selectedRow valueForKey:@"class"] integerValue],[[selectedRow valueForKey:@"subclass"] integerValue]];
                }
            }
        }
        
        else
        {
            predicate = [NSPredicate predicateWithFormat:@"(itemRelationship.itemClass == %d)",[[selectedRow valueForKey:@"class"] integerValue]];
        }
    }
    else
    {
        if([_dictionary valueForKey:@"class"] != nil)
        {
            if([_dictionary valueForKey:@"subclass"] != nil)
            {
                predicate = [NSPredicate predicateWithFormat:@"(itemRelationship.itemClass == %d) AND (itemRelationship.itemSubClass == %d)",[[_dictionary valueForKey:@"class"] integerValue], [[_dictionary valueForKey:@"subclass"] integerValue]];
            }
            else
            {
                predicate = [NSPredicate predicateWithFormat:@"(itemRelationship.itemClass == %d)",[[_dictionary valueForKey:@"class"] integerValue]];
            }
        }
        else
        {
            predicate = nil;
        }
    }
    NSLog(@"%@",predicate);
    
    //NSPredicate *dumpPredicate = [NSPredicate predicateWithFormat:@"dumpRelationship.dumpURL == %@",[delegate realmURL]];
    //NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate,dumpPredicate,nil]];
    [delegate setCategoryPredicate:predicate];
    [self.detailViewController applyCurrentFilters];
}

- (IBAction)clearFilters:(id)sender {
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
    [delegate setSearchPredicate:nil];
    [delegate setSortDescriptors:nil];
    [delegate setCategoryPredicate:nil];
    [delegate.searchViewController.sortByBar setSelectedSegmentIndex:-1];
    [delegate.searchViewController.ascDescBar setSelectedSegmentIndex:-1];
    [delegate.searchViewController.searchBar setText:@""];
    [_detailViewController applyCurrentFilters];
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
    
    //Set the cell selection background
    if(![cell.selectedBackgroundView isKindOfClass:[AHPCustomCategoryCellBackground class]])
    {
        cell.selectedBackgroundView = [[AHPCustomCategoryCellBackground alloc] init];
    }
    
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
        //Changing filtering to be done on exlpicit command only (when user presses 'Done')
        //[self.detailViewController filterAuctionTableByString:[object valueForKey:@"predicate"]];
    }
    
    //NSLog(@"Dictionary for selected Row: %@",selectedRow);
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
    cell.backgroundColor = [UIColor colorWithRed:35.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:1.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:252.0/255.0 green:221.0/255.0 blue:13.0/255.0 alpha:1];
    //cell.textLabel.textColor = [UIColor colorWithRed:0/255.0 green:128/255.0 blue:255/255.0 alpha:1];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
