//
//  CRKBluetoothCentral.h
//  Cork
//
//  Created by MichaelSelsky on 4/18/15.
//  Copyright (c) 2015 HackRU. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

#import "CRKMessage.h"

@protocol CRKBluetoothCentralControllerDelegate;

@interface CRKBluetoothCentralController : NSObject

@property (nonatomic, weak) id <CRKBluetoothCentralControllerDelegate> delegate;

@end

@protocol CRKBluetoothCentralControllerDelegate <NSObject>

- (id <CRKMessage>)controller:(CRKBluetoothCentralController *)controller messageToTransmitToPeripheral:(CBPeripheral *)peripheral;

@end
