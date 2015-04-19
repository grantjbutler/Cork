//
//  CRKConversationViewController.h
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>

@class CRKUser;
@class CRKConversation;

@interface CRKConversationViewController : JSQMessagesViewController

@property (nonatomic) CRKConversation *conversation;

@property (nonatomic) NSManagedObjectContext *readContext;
@property (nonatomic) CRKUser *sender;

@end
