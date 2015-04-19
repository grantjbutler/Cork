//
//  AppDelegate.m
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKAppDelegate.h"

#import "CRKPeripheralController.h"
#import "CRKBluetoothCentralController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "CRKCoreDataHelper.h"

#import "CRKMessageProtocol.h"

#import "CRKBinaryMessageSerializer.h"
#import "CRKBinaryMessageDeserializer.h"

@interface CRKAppDelegate () <CRKBluetoothCentralControllerDelegate, CRKPeripheralControllerDelegate>

@property (nonatomic) CRKPeripheralController *controller;
@property (nonatomic) CRKBluetoothCentralController *central;

@end

@implementation CRKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CRKCoreDataHelper *helper = [CRKCoreDataHelper sharedHelper];
    NSManagedObjectContext * context = helper.managedObjectContext;
    
    CRKBinaryMessageDeserializer *deserializer = [[CRKBinaryMessageDeserializer alloc] initWithContext:[helper.persistenceController newPrivateChildManagedObjectContext]];
    self.controller = [[CRKPeripheralController alloc] initWithMessageDeserializer:deserializer];
    self.controller.delegate = self;
    
    CRKBinaryMessageSerializer *serializer = [[CRKBinaryMessageSerializer alloc] init];
    self.central = [[CRKBluetoothCentralController alloc] initWithMessageSerializer:serializer];
    self.central.delegate = self;
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    return YES;
}

- (void)controller:(CRKPeripheralController *)controller didReceiveMessage:(id<CRKMessage>)message {
    NSLog(@"Did receive: %@", message);
}

- (id<CRKMessage>)controller:(CRKBluetoothCentralController *)controller messageToTransmitToPeripheral:(CBPeripheral *)peripheral {
    // TODO: Hook this up to Core Data.
    
    return nil;
}

@end
