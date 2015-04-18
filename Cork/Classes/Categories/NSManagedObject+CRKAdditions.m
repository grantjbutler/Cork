//
//  NSManagedObject+CRKAdditions.m
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "NSManagedObject+CRKAdditions.h"

static NSString * CRKNSManagedObjectIdentifierKeyPathKey = @"identifierKeyPath";

@implementation NSManagedObject (CRKAdditions)

+ (NSString *)entityName {
    return NSStringFromClass(self);
}

+ (NSString *)identifierKeyPathInContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    return entityDescription.userInfo[CRKNSManagedObjectIdentifierKeyPathKey];
}

+ (instancetype)uniqueObjectWithIdentifier:(id)identifier inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", [self identifierKeyPathInContext:context], identifier];
    fetchRequest.fetchLimit = 1;
    
    NSError *fetchError;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (!results) {
        NSLog(@"Error fetching object: %@", fetchError);
        
        return nil;
    }
    
    return results.firstObject;
}

@end
