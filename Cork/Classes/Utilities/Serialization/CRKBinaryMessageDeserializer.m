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

#import "NSManagedObject+CRKAdditions.h"

#import <CCHBinaryData/CCHBinaryData.h>

#include "crc32.h"

static NSInteger CRKBinaryMessageDeserializerUUIDLength = 36;

@interface CRKBinaryMessageDeserializer ()

@property (nonatomic) NSManagedObjectContext *context;

@end

@implementation CRKBinaryMessageDeserializer

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        _context = context;
    }
    return self;
}

- (id<CRKMessage>)messageFromSerializedData:(NSData *)data {
	CCHBinaryDataReader *dataReader = [[CCHBinaryDataReader alloc] initWithData:data options:CCHBinaryDataReaderBigEndian];
    
    uint16_t ttl;
    uint32_t crcHash, messageLength;
    uint64_t sentTimestamp;
    NSString *senderID;
    NSString *recipientID;
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
    
    senderID = [dataReader readStringWithNumberOfBytes:CRKBinaryMessageDeserializerUUIDLength encoding:NSUTF8StringEncoding];
    
    if (![dataReader canReadNumberOfBytes:CRKBinaryMessageDeserializerUUIDLength]) {
        return nil;
    }
    
    recipientID = [dataReader readStringWithNumberOfBytes:CRKBinaryMessageDeserializerUUIDLength encoding:NSUTF8StringEncoding];
    
    if (![dataReader canReadNumberOfBytes:sizeof(uint64_t)]) {
        return nil;
    }
    
    sentTimestamp = [dataReader readUnsignedLongLong];
    
    if (![dataReader canReadNumberOfBytes:sizeof(uint32_t)]) {
        return nil;
    }
    
    messageLength = [dataReader readUnsignedInt];
    
    if (![dataReader canReadNumberOfBytes:messageLength]) {
        return nil;
    }
    
    messageText = [dataReader readStringWithNumberOfBytes:messageLength encoding:NSUTF8StringEncoding];
	
	CRKUser *sender = [CRKUser uniqueObjectWithIdentifier:[[NSUUID alloc] initWithUUIDString:senderID] inContext:self.context];
    CRKUser *recipient = [CRKUser uniqueObjectWithIdentifier:[[NSUUID alloc] initWithUUIDString:recipientID] inContext:self.context];
    
    CRKMessage *message = [[CRKMessage alloc] initWithEntity:[CRKMessage entityDescriptionInContext:self.context] insertIntoManagedObjectContext:self.context];
    message.text = messageText;
    message.dateSent = [NSDate dateWithTimeIntervalSince1970:sentTimestamp];
    message.sender = sender;
    message.reciever = recipient;
	
    return message;
}

@end
