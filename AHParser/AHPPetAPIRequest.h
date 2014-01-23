//
//  AHPPetAPIRequest.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 11/21/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHPPetAPIRequest : NSObject

//This function takes a petID nubmer (petSpeciesID according to the wow API) and returns a dictionary with the pet's information. This is used primarily for fetching the pet's name and thumbnail for display in the detail view.
+(NSDictionary *) petAPIRequest: (NSInteger) petID;
+(NSManagedObject *)storePet:(NSInteger)petID
                   inContext:(NSManagedObjectContext *)context;

@end
