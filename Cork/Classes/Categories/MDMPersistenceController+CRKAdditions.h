//
//  MDMPersistenceController+CRKAdditions.h
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "MDMPersistenceController.h"

@interface MDMPersistenceController (CRKAdditions)

- (instancetype)initWithEncryptedStoreURL:(NSURL *)storeURL model:(NSManagedObjectModel *)model;

@end
