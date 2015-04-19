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

@property (nonatomic) id <CRKMessageDeserializer> messageDeserializer;

@end

@implementation CRKPeripheralController

- (instancetype)initWithMessageDeserializer:(id <CRKMessageDeserializer>)deserializer {
    self = [super init];
    if (self) {
        _messageDeserializer = deserializer;
        
        [self setUpPeripheralManager];
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
    
    [self setUpMessagesServiceCharacteristics];
    
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
    [self.peripheralManager removeAllServices];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setUpServices];
            [self startAdvertising];
            break;
            
        default:
            [self stopAdvertising];
            break;
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"Started advertising: %@", error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    NSLog(@"Did add service '%@' with error '%@'", service, error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    for (CBATTRequest *request in requests) {
        if (![request.characteristic.UUID isEqual:self.messagesCharacteristic.UUID]) {
            [peripheral respondToRequest:requests.firstObject withResult:CBATTErrorRequestNotSupported];
            
            return;
        }
    }
    
    NSArray *sortedRequests = [requests sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"offset" ascending:YES]
    ]];
    
    NSMutableData *messageData = [NSMutableData data];
    for (CBATTRequest *request in sortedRequests) {
        [messageData appendData:request.value];
    }
    
    id <CRKMessage> message = [self.messageDeserializer messageFromSerializedData:messageData];
    if (!message) {
        return;
    }
    
    // Decrement Time To Live.
    message.timeToLive--;
    
    [self.delegate controller:self didReceiveMessage:message];
}

@end
