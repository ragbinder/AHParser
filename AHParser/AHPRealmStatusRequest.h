//
//  AHPRealmStatusRequest.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 10/14/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHPRealmStatusRequest : NSObject

//Will return an array of dictionaries that represent realm status.
//Example Data:
/*"realms": [
 {
 "type": "pvp",
 "population": "medium",
 "queue": false,
 "wintergrasp": {
    "area": 1,
    "controlling-faction": 1,
    "status": 0,
    "next": 1386375841415
 },
 "tol-barad": {
    "area": 21,
    "controlling-faction": 1,
    "status": 0,
    "next": 1386378303560
 },
 "status": true,
 "name": "Aegwynn",
 "slug": "aegwynn",
 "battlegroup": "Vengeance",
 "locale": "en_US",
 "timezone": "America/Los_Angeles"
 }, ...]
 */
+(NSArray*) realmStatus;

@end
