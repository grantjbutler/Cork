//
//  CRKMessage.h
//  Scavenger
//
//  Created by MichaelSelsky on 04/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "_CRKMessage.h"
#import "CRKMessageProtocol.h"

@interface CRKMessage : _CRKMessage <CRKMessage>

+ (NSString *)messageIdentifierForSenderUUID:(NSUUID *)senderUUID recipientUUID:(NSUUID *)recipientUUID sentDate:(NSDate *)sentDate text:(NSString *)text;

@end
