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

@class AHPRealmSelectViewController;

@interface AHPAppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;

//Singletons
@property (strong, nonatomic) AHPRealmSelectViewController *realmSelectViewController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//The next five properties are used for determining which auctions from Core Data to display.
//This object holds the realm, slug, and URL that is associated with the dump object that the auctions are tied to.
@property (strong, nonatomic) NSManagedObject *realmURL;
//This object holds the dump object the auctions will be associated with.
@property (strong, nonatomic) NSManagedObject *dump;
//The current predicates and sort descriptors. These are contained in the app delegate so that more than one predicate may be applied at a time more easily.
@property (strong, nonatomic) NSPredicate *categoryPredicate;
@property (strong, nonatomic) NSPredicate *searchPredicate;
@property (strong, nonatomic) NSArray *sortDescriptors;

/*
@property (strong, nonatomic) NSString *faction;
//The realm slug that us currently being used.
@property (strong, nonatomic) NSString *realm;
//The realm name that us currently being used.
@property (strong, nonatomic) NSString *realmProper;
//The URL the current realm dump is pulled from
@property (strong, nonatomic) NSString *realmURL;
*/



- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
