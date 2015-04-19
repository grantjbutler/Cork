//
//  CRKUser.m
//  Scavenger
//
//  Created by MichaelSelsky on 04/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKUser.h"

static NSString * const CRKUserIDKey = @"CRKUserIDKey";

@implementation CRKUser

+ (NSUUID *)currentUserID{

    NSString *uuidString = [[NSUserDefaults standardUserDefaults] objectForKey:CRKUserIDKey];
    NSUUID *userID;
    if (!uuidString){
        userID = [NSUUID UUID];
        [[NSUserDefaults standardUserDefaults] setObject:[userID UUIDString] forKey:CRKUserIDKey];
    } else {
        userID = [[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] objectForKey:CRKUserIDKey]];
    }
    return userID;
}

@end
