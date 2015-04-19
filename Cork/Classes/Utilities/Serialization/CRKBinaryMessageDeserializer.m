//
//  CRKBinaryMessageDeserializer.m
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKBinaryMessageDeserializer.h"

#import "CRKUser.h"
#import "CRKMessage.h"

#import "CRKSigningKeyStore.h"

#import "NSManagedObject+CRKAdditions.h"

#import <CCHBinaryData/CCHBinaryData.h>

#include "crc32.h"

static NSInteger CRKBinaryMessageDeserializerUUIDLength = 36;

@interface CRKBinaryMessageDeserializer ()

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) CRKUser *currentUser;

@end

@implementation CRKBinaryMessageDeserializer

- (instancetype)initWithContext:(NSManagedObjectContext *)context currentUser:(CRKUser *)currentUser {
    self = [super init];
    if (self) {
        _context = context;
        _currentUser = currentUser;
    }
    return self;
}

- (id<CRKMessage>)messageFromSerializedData:(NSData *)data {
	CCHBinaryDataReader *dataReader = [[CCHBinaryDataReader alloc] initWithData:data options:CCHBinaryDataReaderBigEndian];
    
    uint16_t ttl;
    uint32_t crcHash, messageLength;
    NSDate *sentDate;
    NSUUID *senderUUID, *recipientUUID;
    NSString *messageText;
    
    if (![dataReader canReadNumberOfBytes:sizeof(uint32_t)]) {
        return nil;
    }
    
    crcHash = [dataReader readUnsignedInt];
    
    NSData *messageData = [dataReader.data subdataWithRange:NSMakeRange(sizeof(uint32_t), data.length - sizeof(uint32_t))];
    if (crc32(0, messageData.bytes, messageData.length) != crcHash) {
        return nil;
    }
    
    if (![dataReader canReadNumberOfBytes:sizeof(uint16_t)]) {
        return nil;
    }
    
    ttl = [dataReader readUnsignedShort];
    
    if (![dataReader canReadNumberOfBytes:CRKBinaryMessageDeserializerUUIDLength]) {
        return nil;
    }
    
    senderUUID = [[NSUUID alloc] initWithUUIDString:[dataReader readStringWithNumberOfBytes:CRKBinaryMessageDeserializerUUIDLength encoding:NSUTF8StringEncoding]];
    
    if (![dataReader canReadNumberOfBytes:CRKBinaryMessageDeserializerUUIDLength]) {
        return nil;
    }
    
    recipientUUID = [[NSUUID alloc] initWithUUIDString:[dataReader readStringWithNumberOfBytes:CRKBinaryMessageDeserializerUUIDLength encoding:NSUTF8StringEncoding]];
    
    if (![dataReader canReadNumberOfBytes:sizeof(uint64_t)]) {
        return nil;
    }
    
    sentDate = [NSDate dateWithTimeIntervalSince1970:[dataReader readUnsignedLongLong]];
    
    if (![dataReader canReadNumberOfBytes:sizeof(uint32_t)]) {
        return nil;
    }
    
    messageLength = [dataReader readUnsignedInt];
    
    if (![dataReader canReadNumberOfBytes:messageLength]) {
        return nil;
    }
    
    NSData *messageBody = [NSData dataWithBytes:dataReader.currentPosition length:messageLength];
    
    NSString *messageID = [CRKMessage messageIdentifierForSenderUUID:senderUUID recipientUUID:recipientUUID sentDate:sentDate body:messageBody];
    CRKMessage *message = [CRKMessage existingObjectWithIdentifier:messageID inContext:self.context];
    if (message) {
        return nil;
    }
	
	CRKUser *sender = [CRKUser uniqueObjectWithIdentifier:senderUUID inContext:self.context];
    CRKUser *recipient = [CRKUser uniqueObjectWithIdentifier:recipientUUID inContext:self.context];
    
    message = [[CRKMessage alloc] initWithEntity:[CRKMessage entityDescriptionInContext:self.context] insertIntoManagedObjectContext:self.context];
    message.id = messageID;
    
    if ([recipient isEqual:self.currentUser]) {
        message.text = [[CRKSigningKeyStore sharedStore] decryptWithPrivateKey:messageBody];
    }
    else {
        message.encryptedText = messageBody;
    }
    
    message.dateSent = sentDate;
    message.sender = sender;
    message.reciever = recipient;
	
    return message;
}

@end
