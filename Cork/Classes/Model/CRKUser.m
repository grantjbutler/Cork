//
//  CRKUser.m
//  Cork
//
//  Created by MichaelSelsky on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKUser.h"

static NSString * const CRKUUIDKey = @"com.grantjbutler.Cork.CRKUserIDKey";

@implementation CRKUser

+ (NSString *)userID{
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:CRKUUIDKey];
    
    if (!userID){
        userID = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:CRKUUIDKey];
    }
    
    return userID;
}

@end
