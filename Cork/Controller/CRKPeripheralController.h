//
//  CRKPeripheralController.h
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

#import "CRKMessageProtocol.h"

@protocol CRKPeripheralControllerDelegate;

@interface CRKPeripheralController : NSObject

@property (nonatomic, weak) id <CRKPeripheralControllerDelegate> delegate;

- (void)startAdvertising;
- (void)stopAdvertising;

@end

@protocol CRKPeripheralControllerDelegate <NSObject>

- (void)controller:(CRKPeripheralController *)controller didReceiveMessage:(id <CRKMessage>)message;

@end
