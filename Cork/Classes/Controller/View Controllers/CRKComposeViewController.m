//
//  CRKComposeViewController.m
//  Cork
//
//  Created by MichaelSelsky on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKComposeViewController.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

#import "CRKCoreDataHelper.h"

#import "CRKUser.h"
#import "CRKMessage.h"

#import "NSManagedObject+CRKAdditions.h"

@interface CRKComposeViewController ()
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *userIDTextField;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *messageTextField;

@end

@implementation CRKComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)send:(id)button {
    NSManagedObjectContext *context = [CRKCoreDataHelper sharedHelper].persistenceController.newPrivateChildManagedObjectContext;
    
    NSUUID *recipientUUID = [[NSUUID alloc] initWithUUIDString:self.userIDTextField.text];
    
    if (!recipientUUID) {
        // TODO: Log on invalid UUID.
        
        return;
    }
    
    CRKUser *sender = [CRKUser currentUserInContext:context];
    CRKUser *recipient = [CRKUser uniqueObjectWithIdentifier:recipientUUID inContext:context];
    
    CRKMessage *message = [[CRKMessage alloc] initWithEntity:[CRKMessage entityDescriptionInContext:context] insertIntoManagedObjectContext:context];
    message.dateSent = [NSDate date];
    message.text = self.messageTextField.text;
    message.sender = sender;
    message.reciever = recipient;
    
    [context performBlock:^{
        NSError *saveError;
        if (![context save:&saveError]) {
            NSLog(@"Error saving: %@", saveError);
            
            return;
        }
        
        [[CRKCoreDataHelper sharedHelper].persistenceController saveContextAndWait:NO completion:^(NSError *error) {
            if (error) {
                NSLog(@"Error saving: %@", error);
            }
        }];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
