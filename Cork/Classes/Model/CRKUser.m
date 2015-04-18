//
//  CRKUser.m
//  Cork
//
//  Created by MichaelSelsky on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKUser.h"

static NSString * const SRKUserIDKey = @"SRKUserIDKey";

@implementation CRKUser

+ (NSUUID *)userID{
    NSUUID *userID = [[NSUserDefaults standardUserDefaults] objectForKey:SRKUserIDKey];
    if (!userID){
        userID = [NSUUID UUID];
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:SRKUserIDKey];
    }
    
    return userID;
}

@end
