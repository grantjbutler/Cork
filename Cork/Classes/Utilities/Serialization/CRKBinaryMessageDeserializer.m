//
//  CRKBinaryMessageDeserializer.m
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKBinaryMessageDeserializer.h"

#import <CCHBinaryData/CCHBinaryData.h>

#include "crc32.h"

static NSInteger CRKBinaryMessageDeserializerUUIDLength = 16;

@implementation CRKBinaryMessageDeserializer

- (id<CRKMessage>)messageFromSerializedData:(NSData *)data {
	CCHBinaryDataReader *dataReader = [[CCHBinaryDataReader alloc] initWithData:data options:CCHBinaryDataReaderBigEndian];
    
    uint32_t crcHash, sentTimestamp, messageLength;
    NSString *sender, *recipient, *messageText;
    
    if (![dataReader canReadNumberOfBytes:sizeof(uint32_t)]) {
        return nil;
    }
    
    crcHash = [dataReader readUnsignedInt];
    
    NSData *messageData = [dataReader.data subdataWithRange:NSMakeRange(sizeof(uint32_t), data.length - sizeof(uint32_t))];
    if (crc32(0, messageData.bytes, messageData.length) != crcHash) {
        return nil;
    }
    
    if (![dataReader canReadNumberOfBytes:CRKBinaryMessageDeserializerUUIDLength]) {
        return nil;
    }
    
    sender = [dataReader readStringWithNumberOfBytes:CRKBinaryMessageDeserializerUUIDLength encoding:NSUTF8StringEncoding];
    
    if (![dataReader canReadNumberOfBytes:CRKBinaryMessageDeserializerUUIDLength]) {
        return nil;
    }
    
    recipient = [dataReader readStringWithNumberOfBytes:CRKBinaryMessageDeserializerUUIDLength encoding:NSUTF8StringEncoding];
    
    if (![dataReader canReadNumberOfBytes:sizeof(uint32_t)]) {
        return nil;
    }
    
    sentTimestamp = [dataReader readUnsignedInt];
    
    if (![dataReader canReadNumberOfBytes:sizeof(uint32_t)]) {
        return nil;
    }
    
    messageLength = [dataReader readUnsignedInt];
    
    if (![dataReader canReadNumberOfBytes:messageLength]) {
        return nil;
    }
    
    messageText = [dataReader readStringWithNumberOfBytes:messageLength encoding:NSUTF8StringEncoding];
    
    // TODO: Turn all these variables into a CRKMessage instance.
    
    return nil;
}

@end
