//
// _CRKPeripheral.h
// Scavenger
//
// Copyright (c) 2015 Grant Butler. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRKPeripheral.h instead.

#import <CoreData/CoreData.h>

@class CRKPeripheralMessage;

@interface _CRKPeripheral : NSManagedObject

@property (nonatomic, copy) NSString* id;

@property (nonatomic, copy) NSSet *peripheralMessages;

@end

@interface _CRKPeripheral (_CRKPeripheralCoreDataGeneratedAccessors)

- (void)addPeripheralMessages:(NSSet *)objects;
- (void)removePeripheralMessages:(NSSet *)objects;
- (void)addPeripheralMessagesObject:(CRKPeripheralMessage *)object;
- (void)removePeripheralMessagesObject:(CRKPeripheralMessage *)object;

@end
