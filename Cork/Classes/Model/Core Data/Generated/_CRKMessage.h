//
// _CRKMessage.h
// Scavenger
//
// Copyright (c) 2015 Grant Butler. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRKMessage.h instead.

#import <CoreData/CoreData.h>

@class CRKPeripheralMessage;
@class CRKUser;
@class CRKUser;

@interface _CRKMessage : NSManagedObject

@property (nonatomic, copy) NSDate* dateReceived;
@property (nonatomic, copy) NSDate* dateSent;
@property (nonatomic, copy) NSString* id;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, assign) int16_t timeToLive;

@property (nonatomic, copy) NSSet *peripheralMessages;
@property (nonatomic, strong) CRKUser *reciever;
@property (nonatomic, strong) CRKUser *sender;

@end

@interface _CRKMessage (_CRKMessageCoreDataGeneratedAccessors)

- (void)addPeripheralMessages:(NSSet *)objects;
- (void)removePeripheralMessages:(NSSet *)objects;
- (void)addPeripheralMessagesObject:(CRKPeripheralMessage *)object;
- (void)removePeripheralMessagesObject:(CRKPeripheralMessage *)object;

@end
