//
//  CRKUser.h
//  Scavenger
//
//  Created by MichaelSelsky on 04/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "_CRKUser.h"

@interface CRKUser : _CRKUser

+ (instancetype)currentUserInContext:(NSManagedObjectContext *)context;

+ (NSUUID *)currentUserID;

@end
