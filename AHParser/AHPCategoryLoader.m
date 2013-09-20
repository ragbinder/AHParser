//
//  AHPCategoryLoader.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 9/17/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

/*
 This class is for loading in the categories that appear in the master view for filtering the items that appear in the detail view. The categories are loaded from a text file containing JSON. The text file currently in use is partially generated from the api URL = Host + "/api/wow/data/item/classes" and then reorganized so that it matches the order presented in the in-game auction house client.
 */

#import "AHPCategoryLoader.h"

@implementation AHPCategoryLoader

+(NSDictionary*)importCategories
{
    NSError *error = nil;
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *JSONPath = [path stringByAppendingPathComponent:@"AuctionCategories.JSON"];
    //NSString *JSONString = [NSString stringWithContentsOfFile:JSONPath encoding:NSUTF8StringEncoding error:&error];
    //NSLog(@"String: \n%@",JSONString);
    
    if(error)
    {
        NSLog(@"Error finding JSON String: %@",error);
    }
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:JSONPath] options:NSJSONReadingMutableContainers error:&error];
    //NSLog(@"Dictionary: \n%@",dict);
    
    if(error)
    {
        NSLog(@"Error importing categories: %@",error);
    }
    
    return dict;
}

//This function iterates through the passed in array to find a dictionary that has a certain value for the given key. This will be used to get the dictionary to generate the subcategory table when a new category is selected.
+(NSDictionary*)findDictionaryWithValue:(NSString*)value forKey:(NSString*)key inArray:(NSArray*)array
{
    for(NSDictionary *dictionary in array)
    {
        if([[dictionary valueForKey:key] isEqualToString:value])
            return dictionary;
    }
    return nil;
}

@end
