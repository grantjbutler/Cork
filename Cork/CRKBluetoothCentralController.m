//
//  CRKBluetoothCentral.m
//  Cork
//
//  Created by MichaelSelsky on 4/18/15.
//  Copyright (c) 2015 HackRU. All rights reserved.
//

#import "CRKBluetoothCentralController.h"

#import "NSArray+CRKAdditions.h"

static NSString * const CRKBluetoothCentralMessagesServiceUUIDString = @"E95B2A3C-7978-4BA4-A6EB-6C8A194AFAAD";

static NSString * const CRKPeripheralControllerMessagesCharacteristicUUIDString = @"CF885323-2B65-45A9-AADA-409EF7EFCD73";

@interface CRKBluetoothCentralController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic) dispatch_queue_t delegateQueue;
@property (nonatomic) CBCentralManager *centralManager;

@property (nonatomic) NSMutableArray *connectedPeripherals;

@end

@implementation CRKBluetoothCentralController

- (instancetype)init {
	self = [super init];
	if (self) {
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

- (void)sendMessageToCharacteristic:(CBCharacteristic *)characteristic ofPeripheral:(CBPeripheral *)peripheral {
	if (peripheral.state != CBPeripheralStateConnected) {
		return;
	}
	
	id <CRKMessage> message = [self.delegate controller:self messageToTransmitToPeripheral:peripheral];
	if (!message) {
		[self disconectPeripheral:peripheral];
		
		return;
	}
	
	// TODO: Serialize the message.
	
	[peripheral writeValue:[NSData data] forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)disconectPeripheral:(CBPeripheral *)peripheral {
	[self.connectedPeripherals removeObject:peripheral];
	
	[self.centralManager cancelPeripheralConnection:peripheral];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
	switch (central.state) {
		case CBCentralManagerStatePoweredOn:
			[self startScanning];
			break;
			
		default:
			break;
	}
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	[central connectPeripheral:peripheral options:nil];
	
	[self.connectedPeripherals addObject:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	peripheral.delegate = self;
	
	[peripheral discoverServices:@[
		[CBUUID UUIDWithString:CRKBluetoothCentralMessagesServiceUUIDString]
	]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	NSLog(@"connection error: %@", error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	NSLog(@"disconnect error: %@", error);
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	CBService *service = [peripheral.services firstObjectPassingTest:^BOOL(CBService *service) {
		return [service.UUID isEqual:[CBUUID UUIDWithString:CRKBluetoothCentralMessagesServiceUUIDString]];
	}];
	
	if (!service) {
		[self disconectPeripheral:peripheral];
		
		return;
	}
	
	[peripheral discoverCharacteristics:@[
		[CBUUID UUIDWithString:CRKPeripheralControllerMessagesCharacteristicUUIDString]
	] forService:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
	CBCharacteristic *characteristic = [service.characteristics firstObjectPassingTest:^BOOL(CBCharacteristic *characteristic) {
		return [characteristic.UUID isEqual:[CBUUID UUIDWithString:CRKPeripheralControllerMessagesCharacteristicUUIDString]];
	}];
	
	if (!characteristic) {
		[self disconectPeripheral:peripheral];
		
		return;
	}
	
	[self sendMessageToCharacteristic:characteristic ofPeripheral:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	if (error) {
		NSLog(@"Error writing value to characteristic '%@': %@", characteristic, error);
		
		[self disconectPeripheral:peripheral];
		
		return;
	}
	
	[self sendMessageToCharacteristic:characteristic ofPeripheral:peripheral];
}

@end
