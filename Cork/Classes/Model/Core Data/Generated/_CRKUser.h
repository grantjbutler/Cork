//
// _CRKUser.h
// Scavenger
//
// Copyright (c) 2015 Grant Butler. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRKUser.h instead.

#import <CoreData/CoreData.h>

@class CRKMessage;
@class CRKMessage;

@interface _CRKUser : NSManagedObject

@property (nonatomic, copy) NSUUID* id;

@property (nonatomic, copy) NSSet *recievedMessages;
@property (nonatomic, copy) NSSet *sentMessages;

@end

@interface _CRKUser (_CRKUserCoreDataGeneratedAccessors)

- (void)addRecievedMessages:(NSSet *)objects;
- (void)removeRecievedMessages:(NSSet *)objects;
- (void)addRecievedMessagesObject:(CRKMessage *)object;
- (void)removeRecievedMessagesObject:(CRKMessage *)object;

- (void)addSentMessages:(NSSet *)objects;
- (void)removeSentMessages:(NSSet *)objects;
- (void)addSentMessagesObject:(CRKMessage *)object;
- (void)removeSentMessagesObject:(CRKMessage *)object;

@end
