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
#import "CRKCoreDataHelper.h"

#import "CRKMessageProtocol.h"

#import "CRKBinaryMessageSerializer.h"
#import "CRKBinaryMessageDeserializer.h"

#import "CRKUser.h"
#import "CRKMessage.h"
#import "CRKPeripheral.h"
#import "CRKConversation.h"

#import "NSManagedObject+CRKAdditions.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
#import <NSHash/NSString+NSHash.h>

@interface CRKAppDelegate () <CRKBluetoothCentralControllerDelegate, CRKPeripheralControllerDelegate>

@property (nonatomic) CRKPeripheralController *controller;
@property (nonatomic) CRKBluetoothCentralController *central;

@end

@implementation CRKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CRKCoreDataHelper *helper = [CRKCoreDataHelper sharedHelper];
    NSManagedObjectContext * context = helper.managedObjectContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:context];
    
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
    CRKMessage *coreDataMessage = message;
    NSManagedObjectContext *context = coreDataMessage.managedObjectContext;
    
    if ([coreDataMessage.reciever isEqual:[CRKUser currentUserInContext:context]]) {
        CRKConversation *conversation = [CRKConversation conversationWithUser:coreDataMessage.sender inContext:context];
        [conversation addMessagesObject:coreDataMessage];
        conversation.lastUpdatedDate = coreDataMessage.dateSent;
    }
    
    [context performBlock:^{
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"Error saving: %@", saveError);
            
            return;
        }
        
        [[CRKCoreDataHelper sharedHelper].persistenceController saveContextAndWait:NO completion:nil];
    }];
}

- (id<CRKMessage>)controller:(CRKBluetoothCentralController *)controller messageToTransmitToPeripheral:(CBPeripheral *)peripheral {
    NSManagedObjectContext *context = [[CRKCoreDataHelper sharedHelper].persistenceController newPrivateChildManagedObjectContext];
    
    NSString *hashedDeviceIdentifier = peripheral.identifier.UUIDString.SHA1;
    CRKPeripheral *coreDataPeripheral = [CRKPeripheral uniqueObjectWithIdentifier:hashedDeviceIdentifier inContext:context];
    
    CRKUser *currentUser = [CRKUser currentUserInContext:context];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CRKMessage entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(%K != %@) AND (%K > 0) AND (SUBQUERY(%K, $p, $p == %@).@count == 0)", @"reciever", currentUser, @"timeToLive", @"peripherals.id", hashedDeviceIdentifier];
    fetchRequest.fetchLimit = 1;
    
    NSError *fetchError;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (!results) {
        NSLog(@"Error fetching: %@", fetchError);
        
        return nil;
    }
    
    CRKMessage *message = results.firstObject;
    [message addPeripheralsObject:coreDataPeripheral];
    
    [context performBlock:^{
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"Error saving: %@", saveError);
            
            return;
        }
        
        [[CRKCoreDataHelper sharedHelper].persistenceController saveContextAndWait:NO completion:nil];
    }];
    
    return message;
}

- (void)handleContextDidSaveNotification:(NSNotification *)notification {
    for (NSManagedObject *object in notification.userInfo[NSInsertedObjectsKey]) {
        if (![object isKindOfClass:[CRKMessage class]]) {
            continue;
        }
        
        CRKMessage *message = (CRKMessage *)object;
        [self.central broadastMessage:message];
    }
}

@end
