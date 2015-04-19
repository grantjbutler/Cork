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

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}

+ (NSString *)identifierKeyPathInContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entityDescription = [self entityDescriptionInContext:context];
    return entityDescription.userInfo[CRKNSManagedObjectIdentifierKeyPathKey];
}

+ (instancetype)existingObjectWithIdentifier:(id)identifier inContext:(NSManagedObjectContext *)context {
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

+ (instancetype)uniqueObjectWithIdentifier:(id)identifier inContext:(NSManagedObjectContext *)context {
    NSManagedObject *object = [self existingObjectWithIdentifier:identifier inContext:context];
    if (!object) {
        object = [[self alloc] initWithEntity:[self entityDescriptionInContext:context] insertIntoManagedObjectContext:context];
    }
    
    return object;
}

@end
