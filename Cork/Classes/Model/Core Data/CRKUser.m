//
//  CRKUser.m
//  Scavenger
//
//  Created by MichaelSelsky on 04/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKUser.h"

#import "NSManagedObject+CRKAdditions.h"

static NSString * const CRKUserIDKey = @"CRKUserIDKey";

@implementation CRKUser

+ (instancetype)currentUserInContext:(NSManagedObjectContext *)context {
    return [self existingObjectWithIdentifier:[self currentUserID] inContext:context];
}

+ (NSUUID *)currentUserID{
    NSString *userIDString = [[NSUserDefaults standardUserDefaults] objectForKey:CRKUserIDKey];
    NSUUID *userID;
    if (!userIDString){
        userID = [NSUUID UUID];
        [[NSUserDefaults standardUserDefaults] setObject:[userID UUIDString] forKey:CRKUserIDKey];
    } else {
        userID = [[NSUUID alloc] initWithUUIDString:userIDString];
    }
    
    return userID;
}

@end
