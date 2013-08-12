//
//  AHPAPIRequest.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/12/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AHPAPIRequest : UIResponder

@property (strong, nonatomic) NSURL *auctionDataURL;
//Last modified is in unix time, in milliseconds
@property (strong, nonatomic) NSNumber *lastModified;
@property (strong, nonatomic) NSArray *allianceAuctions, *hordeAuctions;

-(id) initWithURL: (NSURL*) url;

@end
