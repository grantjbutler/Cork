//
// _CRKPeripheralMessage.h
// Scavenger
//
// Copyright (c) 2015 Grant Butler. All rights reserved.
//

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CRKPeripheralMessage.h instead.

#import <CoreData/CoreData.h>

@class CRKMessage;
@class CRKPeripheral;

@interface _CRKPeripheralMessage : NSManagedObject

@property (nonatomic, strong) CRKMessage *message;
@property (nonatomic, strong) CRKPeripheral *peripheral;

@end

@interface _CRKPeripheralMessage (_CRKPeripheralMessageCoreDataGeneratedAccessors)

@end
