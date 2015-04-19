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

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.dateReceived = [NSDate date];
    self.timeToLive = CRKMessageDefaultTimeToLive;
}

@end
