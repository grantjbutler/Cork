//
//  CRKMessage.h
//  Scavenger
//
//  Created by MichaelSelsky on 04/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "_CRKMessage.h"
#import "CRKMessageProtocol.h"

#import <JSQMessagesViewController/JSQMessageData.h>

@interface CRKMessage : _CRKMessage <CRKMessage, JSQMessageData>

+ (NSString *)messageIdentifierForSenderUUID:(NSUUID *)senderUUID recipientUUID:(NSUUID *)recipientUUID sentDate:(NSDate *)sentDate body:(NSData *)body;

@end
