//
//  CRKCoreDataHelper.m
//  Cork
//
//  Created by MichaelSelsky on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKCoreDataHelper.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@implementation CRKCoreDataHelper

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistenceController = _persistenceController;


+ (instancetype)sharedHelper{
    static dispatch_once_t onceToken;
    static CRKCoreDataHelper *sharedHelper;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[self alloc] init];
    });
    return sharedHelper;
}

- (void)saveContext{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    _managedObjectContext = self.persistenceController.managedObjectContext;
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Cork" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (MDMPersistenceController *)persistenceController {
    if (_persistenceController){
        return _persistenceController;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Cork.sqlite"];
    _persistenceController = [[MDMPersistenceController alloc] initWithStoreURL:storeURL model:[self managedObjectModel]];
    if (!_persistenceController){
        DDLogError(@"MDMPersistenceController failed");
        abort();
    }
    
    return _persistenceController;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
