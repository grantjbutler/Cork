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

#import "CRKMessage.h"

@interface CRKAppDelegate () <CRKBluetoothCentralControllerDelegate, CRKPeripheralControllerDelegate>

@property (nonatomic) CRKPeripheralController *controller;
@property (nonatomic) CRKBluetoothCentralController *central;

@property (nonatomic) BOOL flag;

@end

@implementation CRKAppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.controller = [[CRKPeripheralController alloc] init];
    self.controller.delegate = self;
    
    self.central = [[CRKBluetoothCentralController alloc] init];
    self.central.delegate = self;
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    CRKCoreDataHelper *helper = [CRKCoreDataHelper sharedHelper];
    NSManagedObjectContext * context = helper.managedObjectContext;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)controller:(CRKPeripheralController *)controller didReceiveMessage:(id<CRKMessage>)message {
    NSLog(@"Did receive: %@", message);
}

- (id<CRKMessage>)controller:(CRKBluetoothCentralController *)controller messageToTransmitToPeripheral:(CBPeripheral *)peripheral {
    if (self.flag) {
        return nil;
    }
    
    self.flag = !self.flag;
    
    return [[CRKMessage alloc] init];
}

@end