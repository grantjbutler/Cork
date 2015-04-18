//
//  CRKCoreDataHelper.h
//  Cork
//
//  Created by MichaelSelsky on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MDMCoreData/MDMCoreData.h>

@interface CRKCoreDataHelper : NSObject

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) MDMPersistenceController *persistenceController;

+ (instancetype)sharedHelper;

@end
