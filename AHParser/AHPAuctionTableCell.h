//
//  AHPAuctionTableCell.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/21/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AHPAuctionTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UILabel *timeLeft;
@property (weak, nonatomic) IBOutlet UILabel *level;
@property (weak, nonatomic) IBOutlet UILabel *owner;
@property (weak, nonatomic) IBOutlet UILabel *bidG;
@property (weak, nonatomic) IBOutlet UILabel *bidS;
@property (weak, nonatomic) IBOutlet UILabel *bidC;
@property (weak, nonatomic) IBOutlet UILabel *buyoutG;
@property (weak, nonatomic) IBOutlet UILabel *buyoutS;
@property (weak, nonatomic) IBOutlet UILabel *buyoutC;

@end
