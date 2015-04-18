//
//  CRKMessage.h
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

@import Foundation;

@protocol CRKMessage <NSObject>

@property (nonatomic) NSString *sender;
@property (nonatomic) NSString *recipient;
@property (nonatomic) NSString *message;
@property (nonatomic) NSDate *dateSent;

@end

@interface CRKMessage : NSObject <CRKMessage>

@end
