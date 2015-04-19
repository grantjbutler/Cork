//
//  CRKBinayMessageSerializer.m
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKBinaryMessageSerializer.h"

#include "crc32.h"

@implementation CRKBinaryMessageSerializer

// Format:
// [ crc32 ][ ttl ][  sender  ][ recipient ][ date-sent ][ message-length ][ message ]
//  4 bytes  2 byte  16 bytes     16 bytes     4 bytes        4 bytes        variable

- (NSData *)serializedDataForMessage:(id<CRKMessage>)message {
    NSMutableData *serializedData = [NSMutableData data];
    
    uint16_t ttl = CFSwapInt16HostToBig(message.timeToLive);
    NSString *senderString = message.senderUUID.UUIDString;
    NSString *recipientString = message.recipientUUID.UUIDString;
    uint32_t sentTimestamp = CFSwapInt32HostToBig(floor([message.dateSent timeIntervalSince1970]));
    NSString *messageText = message.text;
    
    [serializedData appendBytes:&ttl length:sizeof(ttl)];
    [serializedData appendData:[senderString dataUsingEncoding:NSUTF8StringEncoding]];
    [serializedData appendData:[recipientString dataUsingEncoding:NSUTF8StringEncoding]];
    [serializedData appendBytes:&sentTimestamp length:sizeof(sentTimestamp)];
    
    NSData *messageData = [messageText dataUsingEncoding:NSUTF8StringEncoding];
    uint32_t messageLength = CFSwapInt32HostToBig((uint32_t)messageData.length);
    [serializedData appendBytes:&messageLength length:sizeof(messageLength)];
    [serializedData appendData:messageData];
    
    uint32_t crcHash = CFSwapInt32HostToBig(crc32(0, messageData.bytes, messageData.length));
    [serializedData replaceBytesInRange:NSMakeRange(0, 0) withBytes:&crcHash length:sizeof(crcHash)];
    
    return serializedData;
}

@end
