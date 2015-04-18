//
// _CRKMessage.h
// Scavenger
//
// Copyright (c) 2015 Grant Butler. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRKMessage.h instead.

#import <CoreData/CoreData.h>

@class CRKUser;
@class CRKUser;

@interface _CRKMessage : NSManagedObject

@property (nonatomic, copy) NSString* messageID;
@property (nonatomic, copy) NSString* messageText;
@property (nonatomic, copy) NSDate* sentDate;

@property (nonatomic, strong) CRKUser *reciever;
@property (nonatomic, strong) CRKUser *sender;

@end

@interface _CRKMessage (_CRKMessageCoreDataGeneratedAccessors)

@end
