//
// _CRKConversation.h
// Scavenger
//
// Copyright (c) 2015 Grant Butler. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRKConversation.h instead.

#import <CoreData/CoreData.h>

@class CRKMessage;
@class CRKUser;

@interface _CRKConversation : NSManagedObject

@property (nonatomic, copy) NSDate* lastUpdatedDate;

@property (nonatomic, copy) NSSet *messages;
@property (nonatomic, strong) CRKUser *user;

@end

@interface _CRKConversation (_CRKConversationCoreDataGeneratedAccessors)

- (void)addMessages:(NSSet *)objects;
- (void)removeMessages:(NSSet *)objects;
- (void)addMessagesObject:(CRKMessage *)object;
- (void)removeMessagesObject:(CRKMessage *)object;

@end
