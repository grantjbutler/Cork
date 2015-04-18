//
//  AppDelegate.h
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MDMCoreData/MDMCoreData.h>
@import CoreData;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) MDMPersistenceController *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;


@end

