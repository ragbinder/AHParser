//
//  AHPAuctionTableCell.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/21/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPAuctionTableCell.h"

@implementation AHPAuctionTableCell
@synthesize icon;
@synthesize itemName, timeLeft, level, owner, bidG, bidS, bidC, buyoutG, buyoutS, buyoutC;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end