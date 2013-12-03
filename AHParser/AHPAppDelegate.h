//
//  AHPAppDelegate.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 7/23/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AHPAPIRequest.h"
#import "AHPMasterViewController.h"
#import "AHPCategoryLoader.h"

@interface AHPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property AHPAPIRequest *auctionData;
@property (strong, nonatomic) NSString *faction;
@property (strong, nonatomic) NSString *realm;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
