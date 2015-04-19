//
// _CRKPeripheral.h
// Scavenger
//
// Copyright (c) 2015 Grant Butler. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRKPeripheral.h instead.

#import <CoreData/CoreData.h>

@class CRKMessage;

@interface _CRKPeripheral : NSManagedObject

@property (nonatomic, copy) NSString* id;

@property (nonatomic, copy) NSSet *messages;

@end

@interface _CRKPeripheral (_CRKPeripheralCoreDataGeneratedAccessors)

- (void)addMessages:(NSSet *)objects;
- (void)removeMessages:(NSSet *)objects;
- (void)addMessagesObject:(CRKMessage *)object;
- (void)removeMessagesObject:(CRKMessage *)object;

@end
