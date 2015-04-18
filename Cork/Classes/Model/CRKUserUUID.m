//
//  CRKUser.m
//  Cork
//
//  Created by MichaelSelsky on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKUserUUID.h"

static NSString * const CRKUserIDKey = @"CRKUserIDKey";

@implementation CRKUserUUID

+ (NSUUID *)userID{
    NSUUID *userID = [[NSUserDefaults standardUserDefaults] objectForKey:CRKUserIDKey];
    if (!userID){
        userID = [NSUUID UUID];
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:CRKUserIDKey];
    }
    
    return userID;
}

@end
