//
//  AHPItemAPIRequest.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/26/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHPItemAPIRequest : NSObject

+(NSDictionary*) itemAPIRequest: (NSInteger) itemID;

//This method is used in the AHPAPIRequest to handle the case that there is no item data in the persistent store for that item ID. This method creates and stores the item object in the database, and then returns a reference to that object so the ItemRelationship can be set for the auction object.
//Intended Usage: [auctionObject setValue: [AHPItemAPIRequest storeItem:54443 inContext: [delegate managedObjectContext]] forKey:@"ItemRelationship"]
+(NSManagedObject*) storeItem:(NSInteger)itemID inContext:(NSManagedObjectContext*)context;
@end
