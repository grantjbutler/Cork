//
//  CRKUserSerialization.h
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

@import Foundation;

@class CRKUser;

@interface CRKContactSerialization : NSObject

+ (NSData *)contactDataForUser:(CRKUser *)user;
+ (CRKUser *)userForContactData:(NSData *)data;

@end
