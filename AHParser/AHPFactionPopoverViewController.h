//
//  AHPFactionPopoverViewController.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 12/9/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol factionPickerDelegate <NSObject>
@required
-(void)selectedFaction:(NSString*) faction;
@end

@interface AHPFactionPopoverViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *factionNames;
@property (nonatomic, weak) id<factionPickerDelegate> delegate;
@end
