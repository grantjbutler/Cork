//
//  CRKBluetoothCentral.m
//  Cork
//
//  Created by MichaelSelsky on 4/18/15.
//  Copyright (c) 2015 HackRU. All rights reserved.
//

#import "CRKBluetoothCentral.h"

static NSString * const CRKBluetoothCentralMessagesServiceUUIDString = @"E95B2A3C-7978-4BA4-A6EB-6C8A194AFAAD";

@interface CRKBluetoothCentral () <CBCentralManagerDelegate>

@property (nonatomic) dispatch_queue_t delegateQueue;
@property (nonatomic) CBCentralManager *centralManager;

@end

@implementation CRKBluetoothCentral

- (instancetype)init {
	self = [super init];
	if (self) {
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
	] options:@{}];
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
	NSLog(@"%@", peripheral);
}

@end
