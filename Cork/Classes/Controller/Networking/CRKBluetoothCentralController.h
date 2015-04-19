//
//  CRKBluetoothCentral.h
//  Cork
//
//  Created by MichaelSelsky on 4/18/15.
//  Copyright (c) 2015 HackRU. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

#import "CRKMessageProtocol.h"
#import "CRKMessageSerializer.h"

@protocol CRKBluetoothCentralControllerDelegate;

@interface CRKBluetoothCentralController : NSObject

@property (nonatomic, weak) id <CRKBluetoothCentralControllerDelegate> delegate;

- (instancetype)initWithMessageSerializer:(id <CRKMessageSerializer>)serializer NS_DESIGNATED_INITIALIZER;

@end

@protocol CRKBluetoothCentralControllerDelegate <NSObject>

- (id <CRKMessage>)controller:(CRKBluetoothCentralController *)controller messageToTransmitToPeripheral:(CBPeripheral *)peripheral;

@end
