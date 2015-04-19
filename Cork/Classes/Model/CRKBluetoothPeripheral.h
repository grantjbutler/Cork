//
//  CRKBluetoothPeripheral.h
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

@protocol CRKBluetoothPeripheralDelegate;

@interface CRKBluetoothPeripheral : NSObject

@property (nonatomic, weak) id <CRKBluetoothPeripheralDelegate> delegate;

@property (nonatomic) NSUUID *identifier;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral NS_DESIGNATED_INITIALIZER;

- (void)sendData:(NSData *)data;

- (void)disconnectFromCentralManager:(CBCentralManager *)manager;

@end

@protocol CRKBluetoothPeripheralDelegate <NSObject>

- (void)peripheralDidConnect:(CRKBluetoothPeripheral *)peripheral;
- (void)peripheral:(CRKBluetoothPeripheral *)peripheral didFailToConnectWithError:(NSError *)error;
- (void)peripheral:(CRKBluetoothPeripheral *)peripheral didSendDataWithError:(NSError *)error;

@end
