//
//  CRKBluetoothPeripheral.m
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKBluetoothPeripheral.h"

#import "NSArray+CRKAdditions.h"

static NSString * const CRKBluetoothCentralMessagesServiceUUIDString = @"E95B2A3C-7978-4BA4-A6EB-6C8A194AFAAD";

static NSString * const CRKPeripheralControllerMessagesCharacteristicUUIDString = @"CF885323-2B65-45A9-AADA-409EF7EFCD73";

@interface CRKBluetoothPeripheral () <CBPeripheralDelegate>

@property (nonatomic) CBPeripheral *peripheral;
@property (nonatomic) CBCharacteristic *characteristic;

@end

@implementation CRKBluetoothPeripheral

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _peripheral.delegate = self;
    }
    return self;
}

- (void)sendData:(NSData *)data {
    if (self.peripheral.state != CBPeripheralStateConnected) {
        return;
    }
    
    if (!self.characteristic) {
        NSLog(@"No characteristic. Bailing.");
        
        return;
    }
    
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)disconnectFromCentralManager:(CBCentralManager *)manager {
    [manager cancelPeripheralConnection:self.peripheral];
}

- (NSUUID *)identifier {
    return self.peripheral.identifier;
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    CBService *service = [peripheral.services firstObjectPassingTest:^BOOL(CBService *service) {
        return [service.UUID isEqual:[CBUUID UUIDWithString:CRKBluetoothCentralMessagesServiceUUIDString]];
    }];
    
    if (!service) {
        [self.delegate peripheral:self didFailToConnectWithError:nil];
        
        return;
    }
    
    [peripheral discoverCharacteristics:@[
        [CBUUID UUIDWithString:CRKPeripheralControllerMessagesCharacteristicUUIDString]
    ] forService:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    self.characteristic = [service.characteristics firstObjectPassingTest:^BOOL(CBCharacteristic *characteristic) {
        return [characteristic.UUID isEqual:[CBUUID UUIDWithString:CRKPeripheralControllerMessagesCharacteristicUUIDString]];
    }];
    
    if (!self.characteristic) {
        [self.delegate peripheral:self didFailToConnectWithError:nil];
        
        return;
    }
    
    [self.delegate peripheralDidConnect:self];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self.delegate peripheral:self didSendDataWithError:error];
}

@end
