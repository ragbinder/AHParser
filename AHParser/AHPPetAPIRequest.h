//
//  AHPPetAPIRequest.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 11/21/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHPPetAPIRequest : NSObject

+(NSDictionary *) petAPIRequest: (NSInteger) petID;

@end
