//
//  AHPCategoryLoader.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 9/17/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHPCategoryLoader : NSObject

+(NSDictionary*)importCategories;
+(NSDictionary*)findDictionaryWithValue:(NSString*)value forKey:(NSString*)key inArray:(NSArray*)array;

@end
