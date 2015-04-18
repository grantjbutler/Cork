//
//  CRKMessageSerializer.h
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

@import Foundation;

#import "CRKMessageProtocol.h"

@protocol CRKMessageSerializer <NSObject>

- (NSData *)serializedDataForMessage:(id <CRKMessage>)message;

@end
