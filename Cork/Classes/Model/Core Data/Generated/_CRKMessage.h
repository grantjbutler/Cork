//
// _CRKMessage.h
// Scavenger
//
// Copyright (c) 2015 Grant Butler. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRKMessage.h instead.

#import <CoreData/CoreData.h>

@class CRKConversation;
@class CRKPeripheral;
@class CRKUser;
@class CRKUser;

@interface _CRKMessage : NSManagedObject

@property (nonatomic, copy) NSDate* dateReceived;
@property (nonatomic, copy) NSDate* dateSent;
@property (nonatomic, copy) NSString* id;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, assign) int16_t timeToLive;

@property (nonatomic, strong) CRKConversation *conversation;
@property (nonatomic, copy) NSSet *peripherals;
@property (nonatomic, strong) CRKUser *reciever;
@property (nonatomic, strong) CRKUser *sender;

@end

@interface _CRKMessage (_CRKMessageCoreDataGeneratedAccessors)

- (void)addPeripherals:(NSSet *)objects;
- (void)removePeripherals:(NSSet *)objects;
- (void)addPeripheralsObject:(CRKPeripheral *)object;
- (void)removePeripheralsObject:(CRKPeripheral *)object;

@end
