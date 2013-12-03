//
//  AHPRealmSelectCell.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 10/14/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AHPRealmSelectCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *realmName;
@property (weak, nonatomic) IBOutlet UILabel *realmStatus;
@property (weak, nonatomic) IBOutlet UILabel *population;
@property (weak, nonatomic) IBOutlet UILabel *type;


@end
