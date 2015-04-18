//
//  CRKPeripheralController.m
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKPeripheralController.h"

static NSString * const CRKPeripheralControllerMessagesServiceUUIDString = @"E95B2A3C-7978-4BA4-A6EB-6C8A194AFAAD";

static NSString * const CRKPeripheralControllerMessagesCharacteristicUUIDString = @"CF885323-2B65-45A9-AADA-409EF7EFCD73";

@interface CRKPeripheralController () <CBPeripheralManagerDelegate>

@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) dispatch_queue_t delegateQueue;

@property (nonatomic) CBMutableService *messagesService;

@property (nonatomic) CBMutableCharacteristic *messagesCharacteristic;

@end

@implementation CRKPeripheralController

- (instancetype)init {
	self = [super init];
	if (self) {
		[self setUpPeripheralManager];
		[self setUpServices];
	}
	return self;
}

- (void)setUpPeripheralManager {
	self.delegateQueue = dispatch_queue_create("com.grantjbutler.Cork.CRKPeripheralController.delegate-queue", NULL);
	self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:self.delegateQueue options:nil];
}

- (void)setUpServices {
	[self setUpMessagesService];
}

- (void)setUpMessagesService {
	CBUUID *messagesServiceUUID = [CBUUID UUIDWithString:CRKPeripheralControllerMessagesServiceUUIDString];
	self.messagesService = [[CBMutableService alloc] initWithType:messagesServiceUUID primary:YES];
	self.messagesService.characteristics = @[
		self.messagesCharacteristic
	];
	[self.peripheralManager addService:self.messagesService];
}

- (void)setUpMessagesServiceCharacteristics {
	CBUUID *messagesCharacteristicUUID = [CBUUID UUIDWithString:CRKPeripheralControllerMessagesCharacteristicUUIDString];
	self.messagesCharacteristic = [[CBMutableCharacteristic alloc] initWithType:messagesCharacteristicUUID properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
}

- (void)startAdvertising {
	[self.peripheralManager startAdvertising:@{
		CBAdvertisementDataServiceUUIDsKey: @[
			self.messagesService.UUID
		]
	}];
}

- (void)stopAdvertising {
	[self.peripheralManager stopAdvertising];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
	NSLog(@"%@", peripheral);
	switch (peripheral.state) {
		case CBPeripheralManagerStatePoweredOn:
			[self startAdvertising];
			break;
			
		default:
			break;
	}
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
	NSLog(@"Started advertising: %@", error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
	for (CBATTRequest *request in requests) {
		if (![request.characteristic isEqual:self.messagesCharacteristic.UUID]) {
			[peripheral respondToRequest:requests.firstObject withResult:CBATTErrorRequestNotSupported];
			
			return;
		}
	}
	
	NSArray *sortedRequests = [requests sortedArrayUsingDescriptors:@[
		[NSSortDescriptor sortDescriptorWithKey:@"offset" ascending:YES]
	]];
	
	NSMutableData *message = [NSMutableData data];
	for (CBATTRequest *request in sortedRequests) {
		[message appendData:request.value];
	}
	
	// TODO: Deserialize the data.
	
	[self.delegate controller:self didReceiveMessage:nil];
}

@end
