//
//  CRKMessage.m
//  Scavenger
//
//  Created by MichaelSelsky on 04/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKMessage.h"

#import "CRKUser.h"

#import "NSManagedObject+CRKAdditions.h"

#import <NSHash/NSString+NSHash.h>

static const uint16_t CRKMessageDefaultTimeToLive = 5;

@implementation CRKMessage

+ (NSString *)messageIdentifierForSenderUUID:(NSUUID *)senderUUID recipientUUID:(NSUUID *)recipientUUID sentDate:(NSDate *)sentDate text:(NSString *)text {
    NSMutableString *stringToHash = [[NSMutableString alloc] init];
    [stringToHash appendString:senderUUID.UUIDString];
    [stringToHash appendString:recipientUUID.UUIDString];
    [stringToHash appendFormat:@"%f", [sentDate timeIntervalSince1970]];
    [stringToHash appendString:text];
    
    return [stringToHash SHA1];
}

#pragma mark - CRKMessage

- (void)setSenderUUID:(NSUUID *)senderUUID {
    self.sender = [CRKUser uniqueObjectWithIdentifier:senderUUID inContext:self.managedObjectContext];
}

- (NSUUID *)senderUUID {
    return self.sender.id;
}

- (void)setRecipientUUID:(NSUUID *)recipientUUID {
    self.reciever = [CRKUser uniqueObjectWithIdentifier:recipientUUID inContext:self.managedObjectContext];
}

- (NSUUID *)recipientUUID {
    return self.reciever.id;
}

#pragma mark - JSQMessageData

- (NSString *)senderId {
    return self.sender.id.UUIDString;
}

- (NSString *)senderDisplayName {
    return self.sender.displayName;
}

- (BOOL)isMediaMessage {
    return NO;
}

- (NSDate *)date {
    return self.dateSent;
}

- (NSUInteger)messageHash {
    return self.text.hash;
}

#pragma mark - NSManagedObject

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.dateReceived = [NSDate date];
    self.timeToLive = CRKMessageDefaultTimeToLive;
}

@end
