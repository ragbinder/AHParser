//
//  AHPDataClient.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/8/15.
//  Copyright (c) 2015 Steven Jordan Kozmary. All rights reserved.
//

//This is a singleton object intended to mediate interaction between the AHPRequestContext and persistent storage
//The file system on the device will be used for caching images retreived from the media server
//Core data will be used to cache all other data retreived from the battle.net api

#import <Foundation/Foundation.h>

@interface AHPDataClient : NSObject

@property NSManagedObjectContext *context;
@property NSFileManager *manager;

+ (instancetype) sharedClient;

//Most of the WoW realms have linked auction houses with several other realms. These groupings are called Connected Realms
//Since connected realms will have identical auction listings, we should cache auction lists for entire realm groups.
//Parameter: realms should be the output of [AHPRequestContext getRealmsCompletion:failure:]
//Returns an NSArray* containing NSSets of connected realms.
+ (NSArray*) createConnectedRealms:(NSArray*) realms;
@end

@interface AHPDataClient (Storage)
//These methods will all return true on successful storage, or false if there is an error.
//If false is returned, the error will be populated.
//Auctions, realm lists, items, and pets will all be stored in the managedObjectContext belonging to sharedClient.
//Images will all be stored in the filesystem under "Documents/Images/<size>/<name>".
//Valid image sizes are 56, 72, ???
#warning TODO: find all valid image sizes and create typedef per device.
- (BOOL) cacheAuction:(NSDictionary*) auction error:(NSError*)error;
- (BOOL) cacheRealmList:(NSArray*) realmList error:(NSError*)error;
- (BOOL) cacheItem:(NSDictionary*) item forId:(NSInteger) itemId error:(NSError*)error;
- (BOOL) cachePet:(NSDictionary*) pet forId:(NSInteger) petId error:(NSError*)error;
- (BOOL) cacheImage:(UIImage*) image forPath:(NSString*) path error:(NSError*)error;
@end

@interface AHPDataClient (Retreival)
//Caching logic will not be handled here?
- (NSArray*) getAuctionsForGroup:(NSSet*) connectedRealms;
- (NSArray*) getAuctionsForGroup:(NSSet*) connectedRealms
                   withPredicate:(NSPredicate*) searchPredicate;
- (NSArray*) getRealms;
- (NSDictionary*) getItemForId:(NSInteger) itemId;
- (NSDictionary*) getPetForId:(NSInteger) petId;
- (UIImage*) getImageForName:(NSString*) imageName;
#warning TODO: replace NSInteger with typedef
- (UIImage*) getImageForName:(NSString*) imageName
                        size:(NSInteger) size;
@end
