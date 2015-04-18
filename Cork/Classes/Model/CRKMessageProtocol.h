//
//  CRKMessageProtocol.h
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

@import Foundation;

@protocol CRKMessage <NSObject>

@property (nonatomic) NSUUID *sender;
@property (nonatomic) NSUUID *recipient;
@property (nonatomic) NSString *message;
@property (nonatomic) NSDate *dateSent;

@end
