//
//  AHPItemAPIRequest.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/26/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHPItemAPIRequest : NSObject

@property NSManagedObject *itemData;

-(NSDictionary*) itemAPIRequest: (NSInteger) itemID;
+(NSManagedObject*) storeItem:(NSInteger)item inContext:(NSManagedObjectContext*)context;
@end
