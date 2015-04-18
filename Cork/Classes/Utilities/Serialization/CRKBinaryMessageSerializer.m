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
// [ crc32 ][  sender  ][ recipient ][ date-sent ][ message-length ][ message ]
//  4 bytes   16 bytes     16 bytes     4 bytes        4 bytes        variable

- (NSData *)serializedDataForMessage:(id<CRKMessage>)message {
    NSMutableData *serializedData = [NSMutableData data];
    
    NSString *senderString = message.sender.UUIDString;
    NSString *recipientString = message.recipient.UUIDString;
    NSInteger sentTimestamp = floor([message.dateSent timeIntervalSince1970]);
    NSString *messageText = message.message;
    
    [serializedData appendData:[senderString dataUsingEncoding:NSUTF8StringEncoding]];
    [serializedData appendData:[recipientString dataUsingEncoding:NSUTF8StringEncoding]];
    [serializedData appendBytes:&sentTimestamp length:sizeof(sentTimestamp)];
    
    NSData *messageData = [messageText dataUsingEncoding:NSUTF8StringEncoding];;
    NSUInteger messageLength = messageData.length;
    [serializedData appendBytes:&messageLength length:sizeof(messageLength)];
    [serializedData appendData:messageData];
    
    uint32_t crcHash = crc32(0, messageData.bytes, messageData.length);
    [serializedData replaceBytesInRange:NSMakeRange(0, 0) withBytes:&crcHash length:sizeof(crcHash)];
    
    return serializedData;
}

@end
