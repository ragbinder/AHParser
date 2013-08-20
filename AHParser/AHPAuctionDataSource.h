//
//  AHPAuctionDataSource.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/20/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHPAuctionDataSource : NSObject <UITableViewDataSource>

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
