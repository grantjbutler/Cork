//
//  CRKConversation.m
//  Scavenger
//
//  Created by Grant Butler on 04/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKConversation.h"

#import "NSManagedObject+CRKAdditions.h"

@implementation CRKConversation

+ (instancetype)conversationWithUser:(CRKUser *)user inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[self entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"user", user];
    fetchRequest.fetchLimit = 1;
    
    NSError *fetchError;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (!fetchedObjects) {
        NSLog(@"Error fetching conversation: %@", fetchError);
        
        return nil;
    }
    
    CRKConversation *conversation = fetchedObjects.firstObject;
    if (!conversation) {
        conversation = [[CRKConversation alloc] initWithEntity:[self entityDescriptionInContext:context] insertIntoManagedObjectContext:context];
        conversation.user = user;
    }
    
    return conversation;
}

@end
