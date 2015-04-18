//
//  CRKUser.m
//  Scavenger
//
//  Created by MichaelSelsky on 04/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKUser.h"

@implementation CRKUser

+ (NSUUID *)devicesUserID{
    NSUUID *userID = [[NSUserDefaults standardUserDefaults] objectForKey:CRKUserIDKey];
    if (!userID){
        userID = [NSUUID UUID];
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:CRKUserIDKey];
    }
    
    return userID;
}

@end
