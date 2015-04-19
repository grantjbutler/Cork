//
//  CRKBluetoothCentral.m
//  Cork
//
//  Created by MichaelSelsky on 4/18/15.
//  Copyright (c) 2015 HackRU. All rights reserved.
//

#import "CRKBluetoothCentralController.h"

#import "CRKBluetoothPeripheral.h"

#import "NSArray+CRKAdditions.h"

static NSString * const CRKBluetoothCentralMessagesServiceUUIDString = @"E95B2A3C-7978-4BA4-A6EB-6C8A194AFAAD";

static NSString * const CRKPeripheralControllerMessagesCharacteristicUUIDString = @"CF885323-2B65-45A9-AADA-409EF7EFCD73";

@interface CRKBluetoothCentralController () <CBCentralManagerDelegate, CRKBluetoothPeripheralDelegate>

@property (nonatomic) dispatch_queue_t delegateQueue;
@property (nonatomic) CBCentralManager *centralManager;

@property (nonatomic) NSMutableArray *connectedPeripherals;

@property (nonatomic) id <CRKMessageSerializer> messageSerializer;

@end

@implementation CRKBluetoothCentralController

- (instancetype)initWithMessageSerializer:(id <CRKMessageSerializer>)serializer {
    self = [super init];
    if (self) {
        _messageSerializer = serializer;
        _connectedPeripherals = [NSMutableArray array];
        
        [self setUpCentralManager];
    }
    return self;
}

- (void)setUpCentralManager {
    self.delegateQueue = dispatch_queue_create("com.grantjbutler.Cork.CRKBluetoothCentral.delegate-queue", NULL);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.delegateQueue];
}

- (void)startScanning {
    [self.centralManager scanForPeripheralsWithServices:@[
        [CBUUID UUIDWithString:CRKBluetoothCentralMessagesServiceUUIDString]
    ] options:nil];
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    for (CRKBluetoothPeripheral *bluetoothPeripheral in self.connectedPeripherals) {
        if ([bluetoothPeripheral.identifier isEqual:peripheral.identifier]) {
            [self disconnectBluetoothPeripheral:bluetoothPeripheral];
            
            return;
        }
    }
}

- (void)disconnectBluetoothPeripheral:(CRKBluetoothPeripheral *)peripheral {
    [peripheral disconnectFromCentralManager:self.centralManager];
    [self.connectedPeripherals removeObject:peripheral];
}

- (void)sendRandomMessageToPeripheral:(CRKBluetoothPeripheral *)peripheral {
    id <CRKMessage> message = [self.delegate controller:self messageToTransmitToPeripheral:peripheral];
    if (!message) {
        return;
    }
    
    [self sendMessage:message toPeripheral:peripheral];
}

- (void)sendMessage:(id <CRKMessage>)message toPeripheral:(CRKBluetoothPeripheral *)peripheral {
    NSData *serializedMessage = [self.messageSerializer serializedDataForMessage:message];
    
    [peripheral sendData:serializedMessage];
}

- (void)broadastMessage:(id <CRKMessage>)message {
    for (CRKBluetoothPeripheral *peripheral in self.connectedPeripherals) {
        [self sendMessage:message toPeripheral:peripheral];
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self startScanning];
            break;
            
        default:
            [self.centralManager stopScan];
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    [central connectPeripheral:peripheral options:nil];
    
    CRKBluetoothPeripheral *bluetoothPeripheral = [[CRKBluetoothPeripheral alloc] initWithPeripheral:peripheral];
    bluetoothPeripheral.delegate = self;
    [self.connectedPeripherals addObject:bluetoothPeripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral discoverServices:@[
        [CBUUID UUIDWithString:CRKBluetoothCentralMessagesServiceUUIDString]
    ]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"connection error: %@", error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"disconnect error: %@", error);
    
    [self disconnectPeripheral:peripheral];
    
    if (error) {
        [self centralManager:central didDiscoverPeripheral:peripheral advertisementData:nil RSSI:nil];
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheralDidConnect:(CRKBluetoothPeripheral *)peripheral {
    [self sendRandomMessageToPeripheral:peripheral];
}

- (void)peripheral:(CRKBluetoothPeripheral *)peripheral didFailToConnectWithError:(NSError *)error {
    [self disconnectBluetoothPeripheral:peripheral];
}

- (void)peripheral:(CRKBluetoothPeripheral *)peripheral didSendDataWithError:(NSError *)error {
    if (!error) {
        [self sendRandomMessageToPeripheral:peripheral];
    }
}

@end
