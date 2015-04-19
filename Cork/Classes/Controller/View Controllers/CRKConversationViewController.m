//
//  CRKConversationViewController.m
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKConversationViewController.h"

#import "CRKUser.h"
#import "CRKMessage.h"
#import "CRKConversation.h"

#import "CRKCoreDataHelper.h"
#import "CRKSigningKeyStore.h"

#import "NSManagedObject+CRKAdditions.h"

#import <JSQMessagesViewController/JSQSystemSoundPlayer+JSQMessages.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#import <JSQMessagesViewController/UIColor+JSQMessages.h>

@interface CRKConversationViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSFetchRequest *fetchRequest;

@property (nonatomic) NSMutableDictionary *objectChanges;
@property (nonatomic) NSMutableDictionary *sectionChanges;

@property (nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end

@implementation CRKConversationViewController

- (NSFetchRequest *)fetchRequest {
    if (!_fetchRequest) {
        _fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[CRKMessage entityName]];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"conversation", self.conversation];
        _fetchRequest.sortDescriptors = @[
            [NSSortDescriptor sortDescriptorWithKey:@"dateSent" ascending:YES]
        ];
    }
    
    return _fetchRequest;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:self.readContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *fetchError;
        if (![_fetchedResultsController performFetch:&fetchError]) {
            NSLog(@"Error fetching: %@", fetchError);
        }
    }
    
    return _fetchedResultsController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.senderId = self.sender.id.UUIDString;
    self.senderDisplayName = self.sender.displayName ?: self.senderId;
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    NSManagedObjectContext *writeContext = [[CRKCoreDataHelper sharedHelper].persistenceController newPrivateChildManagedObjectContext];
    CRKMessage *message = [[CRKMessage alloc] initWithEntity:[CRKMessage entityDescriptionInContext:writeContext] insertIntoManagedObjectContext:writeContext];
    
    CRKUser *sender = (CRKUser *)[writeContext objectWithID:self.sender.objectID];
    CRKUser *reciever = (CRKUser *)[writeContext objectWithID:self.conversation.user.objectID];
    CRKConversation *conversation = (CRKConversation *)[writeContext objectWithID:self.conversation.objectID];
    
    message.sender = sender;
    message.reciever = reciever;
    message.text = text;
    message.encryptedText = [[CRKSigningKeyStore sharedStore] encryptStringWithPublicKey:text];
    message.dateSent = date;
    message.id = [CRKMessage messageIdentifierForSenderUUID:self.sender.id recipientUUID:self.conversation.user.id sentDate:date body:message.encryptedText];
    message.conversation = conversation;
    
    [writeContext performBlockAndWait:^{
        NSError *saveError;
        if (![writeContext save:&saveError]) {
            NSLog(@"Error saving: %@", saveError);
            
            return;
        }
        
        [[CRKCoreDataHelper sharedHelper].persistenceController saveContextAndWait:YES completion:nil];
    }];
    
    [self.fetchedResultsController performFetch:nil];
    [self finishSendingMessageAnimated:YES];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.fetchedResultsController.fetchedObjects[indexPath.row];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    CRKMessage *message = self.fetchedResultsController.fetchedObjects[indexPath.row];
    
    if ([message.sender.id.UUIDString isEqualToString:self.senderId]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    else {
        cell.textView.textColor = [UIColor whiteColor];
    }
        
    return cell;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    CRKMessage *message = self.fetchedResultsController.fetchedObjects[indexPath.item];
    
    if ([message.sender.id.UUIDString isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}



#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.objectChanges = [NSMutableDictionary dictionary];
    self.sectionChanges = [NSMutableDictionary dictionary];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (type == NSFetchedResultsChangeInsert || type == NSFetchedResultsChangeDelete) {
        NSMutableIndexSet *changeSet = self.sectionChanges[@(type)];
        if (changeSet != nil) {
            [changeSet addIndex:sectionIndex];
        } else {
            self.sectionChanges[@(type)] = [[NSMutableIndexSet alloc] initWithIndex:sectionIndex];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableArray *changeSet = self.objectChanges[@(type)];
    if (changeSet == nil) {
        changeSet = [[NSMutableArray alloc] init];
        self.objectChanges[@(type)] = changeSet;
    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [changeSet addObject:newIndexPath];
            break;
        case NSFetchedResultsChangeDelete:
            [changeSet addObject:indexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            [changeSet addObject:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [changeSet addObject:@[indexPath, newIndexPath]];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSMutableArray *moves = self.objectChanges[@(NSFetchedResultsChangeMove)];
    if (moves.count > 0) {
        NSMutableArray *updatedMoves = [[NSMutableArray alloc] initWithCapacity:moves.count];
        
        NSMutableIndexSet *insertSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
        NSMutableIndexSet *deleteSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
        for (NSArray *move in moves) {
            NSIndexPath *fromIP = move[0];
            NSIndexPath *toIP = move[1];
            
            if ([deleteSections containsIndex:fromIP.section]) {
                if (![insertSections containsIndex:toIP.section]) {
                    NSMutableArray *changeSet = self.objectChanges[@(NSFetchedResultsChangeInsert)];
                    if (changeSet == nil) {
                        changeSet = [[NSMutableArray alloc] initWithObjects:toIP, nil];
                        self.objectChanges[@(NSFetchedResultsChangeInsert)] = changeSet;
                    } else {
                        [changeSet addObject:toIP];
                    }
                }
            } else if ([insertSections containsIndex:toIP.section]) {
                NSMutableArray *changeSet = self.objectChanges[@(NSFetchedResultsChangeDelete)];
                if (changeSet == nil) {
                    changeSet = [[NSMutableArray alloc] initWithObjects:fromIP, nil];
                    self.objectChanges[@(NSFetchedResultsChangeDelete)] = changeSet;
                } else {
                    [changeSet addObject:fromIP];
                }
            } else {
                [updatedMoves addObject:move];
            }
        }
        
        if (updatedMoves.count > 0) {
            self.objectChanges[@(NSFetchedResultsChangeMove)] = updatedMoves;
        } else {
            [self.objectChanges removeObjectForKey:@(NSFetchedResultsChangeMove)];
        }
    }
    
    NSMutableArray *deletes = self.objectChanges[@(NSFetchedResultsChangeDelete)];
    if (deletes.count > 0) {
        NSMutableIndexSet *deletedSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
        [deletes filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
            return ![deletedSections containsIndex:evaluatedObject.section];
        }]];
    }
    
    NSMutableArray *inserts = self.objectChanges[@(NSFetchedResultsChangeInsert)];
    if (inserts.count > 0) {
        NSMutableIndexSet *insertedSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
        [inserts filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
            return ![insertedSections containsIndex:evaluatedObject.section];
        }]];
    }
    
    UICollectionView *collectionView = self.collectionView;
    
    [collectionView performBatchUpdates:^{
        NSIndexSet *deletedSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
        if (deletedSections.count > 0) {
            [collectionView deleteSections:deletedSections];
        }
        
        NSIndexSet *insertedSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
        if (insertedSections.count > 0) {
            [collectionView insertSections:insertedSections];
        }
        
        NSArray *deletedItems = self.objectChanges[@(NSFetchedResultsChangeDelete)];
        if (deletedItems.count > 0) {
            [collectionView deleteItemsAtIndexPaths:deletedItems];
        }
        
        NSArray *insertedItems = self.objectChanges[@(NSFetchedResultsChangeInsert)];
        if (insertedItems.count > 0) {
            [collectionView insertItemsAtIndexPaths:insertedItems];
        }
        
        NSArray *reloadItems = self.objectChanges[@(NSFetchedResultsChangeUpdate)];
        if (reloadItems.count > 0) {
            [collectionView reloadItemsAtIndexPaths:reloadItems];
        }
        
        NSArray *moveItems = self.objectChanges[@(NSFetchedResultsChangeMove)];
        for (NSArray *paths in moveItems) {
            [collectionView moveItemAtIndexPath:paths[0] toIndexPath:paths[1]];
        }
    } completion:^(BOOL finished) {
        [self scrollToBottomAnimated:YES];
    }];
    
    self.objectChanges = nil;
    self.sectionChanges = nil;
}

@end
