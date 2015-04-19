//
//  MDMPersistenceController+CRKAdditions.m
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "MDMPersistenceController+CRKAdditions.h"

#import <EncryptedCoreData/EncryptedStore.h>
#import <JRSwizzle/JRSwizzle.h>

@interface MDMPersistenceController ()

@property (nonatomic, copy) NSString *storeType;
@property (nonatomic, strong) NSURL *storeURL;
@property (nonatomic, strong) NSManagedObjectModel *model;

- (BOOL)setupPersistenceStack;
- (NSPersistentStoreCoordinator *)setupNewPersistentStoreCoordinatorWithStoreType:(NSString *)storeType;
- (BOOL)removeSQLiteFilesAtStoreURL:(NSURL *)storeURL error:(NSError * __autoreleasing *)error;

@end

@implementation MDMPersistenceController (CRKAdditions)

+ (void)load {
    [self jr_swizzleMethod:@selector(setupNewPersistentStoreCoordinatorWithStoreType:) withMethod:@selector(crk_setupNewPersistentStoreCoordinatorWithStoreType:) error:nil];
}

- (instancetype)initWithEncryptedStoreURL:(NSURL *)storeURL model:(NSManagedObjectModel *)model {
    self = [super init];
    if (self) {
        self.storeType = EncryptedStoreType;
        self.storeURL = storeURL;
        self.model = model;
        if (![self setupPersistenceStack]) {
            return nil;
        }
    }
    return self;
}

- (NSPersistentStoreCoordinator *)crk_setupNewPersistentStoreCoordinatorWithStoreType:(NSString *)storeType {
    if ([storeType isEqualToString:EncryptedStoreType]) {
        if (self.model == nil) {
            return nil;
        }
        
        // Create persistent store coordinator
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
        
        // Add persistent store to store coordinator
        NSDictionary *persistentStoreOptions = @{ // Light migration
                                                 EncryptedStoreDatabaseLocation: self.storeURL,
                                                 EncryptedStorePassphraseKey: [NSString stringWithFormat:@"%@%@%@", @"84nf8", @"b*$b29", @"nqcyb&0c2"],
                                                 NSInferMappingModelAutomaticallyOption :@YES,
                                                 NSMigratePersistentStoresAutomaticallyOption: @YES
                                                 };
        NSError *persistentStoreError;
        NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:storeType
                                                                                      configuration:nil
                                                                                                URL:self.storeURL
                                                                                            options:persistentStoreOptions
                                                                                              error:&persistentStoreError];
        if (persistentStore == nil && [storeType isEqualToString:NSSQLiteStoreType]) {
            
            // Model has probably changed, lets delete the old one and try again
            NSError *removeSQLiteFilesError = nil;
            if ([self removeSQLiteFilesAtStoreURL:self.storeURL error:&removeSQLiteFilesError]) {
                
                persistentStoreError = nil;
                persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:storeType
                                                                           configuration:nil
                                                                                     URL:self.storeURL
                                                                                 options:persistentStoreOptions
                                                                                   error:&persistentStoreError];
            } else {
                return nil;
            }
        }
        
        return persistentStoreCoordinator;
    }
    
    return [self crk_setupNewPersistentStoreCoordinatorWithStoreType:storeType];
}

@end
