//
//  NSManagedObject+CRKAdditions.h
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

@import CoreData;

@interface NSManagedObject (CRKAdditions)

+ (instancetype)uniqueObjectWithIdentifier:(id)identifier inContext:(NSManagedObjectContext *)context;

@end
