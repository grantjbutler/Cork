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

@implementation CRKMessage

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
}

@end
