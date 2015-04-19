//
//  CRKComposeViewController.m
//  Cork
//
//  Created by MichaelSelsky on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKComposeViewController.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>
#import <SVProgressHUD/SVProgressHUD.h>


#import "CRKCoreDataHelper.h"

#import "CRKUser.h"
#import "CRKMessage.h"

#import "NSManagedObject+CRKAdditions.h"
#import "CRKFloatLabeledTextField.h"



@interface CRKComposeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property MDMFetchedResultsTableDataSource *fetchedResultsTableDataSource;
@property CRKUser *selectedUser;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet CRKFloatLabeledTextField *messageTextField;

@end

@implementation CRKComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fetchedResultsTableDataSource = [[MDMFetchedResultsTableDataSource alloc] initWithTableView:self.contactsTableView fetchedResultsController:self.fetchedResultsController];
    self.fetchedResultsTableDataSource.reuseIdentifier = @"Cell";
    self.fetchedResultsTableDataSource.delegate = self;
    self.contactsTableView.dataSource = self.fetchedResultsTableDataSource;
    self.contactsTableView.delegate = self;

    
    UIBarButtonItem *sendBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    self.navigationItem.rightBarButtonItem = sendBarButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHeightChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardHeightChange:(NSNotification *)note {
    CGRect keyboardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = CGRectGetHeight(keyboardRect);
    
    self.bottomConstraint.constant = self.bottomConstraint.constant + keyboardHeight;
}

- (void)send{
    NSManagedObjectContext *context = [CRKCoreDataHelper sharedHelper].persistenceController.newPrivateChildManagedObjectContext;
    
    NSUUID *recipientUUID = self.selectedUser.id;
    if (!recipientUUID){
        NSLog(@"Didn't select recipient");
        [SVProgressHUD showErrorWithStatus:@"Please select a recipient"];
        return;
    }
    if (self.messageTextField.text.length < 1){
        NSLog(@"No text");
        [SVProgressHUD showErrorWithStatus:@"Please enter a message"];
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
        if (![context save:&saveError]){
            NSLog(@"Error: %@",saveError);
            
            return;
        }
        
        [[CRKCoreDataHelper sharedHelper].persistenceController saveContextAndWait:NO completion:^(NSError *error) {
            if (error){
                NSLog(@"%@",error);
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismiss:nil];
        });
        
    }];
}
//- (IBAction)send:(id)button {
//    NSManagedObjectContext *context = [CRKCoreDataHelper sharedHelper].persistenceController.newPrivateChildManagedObjectContext;
//    
//    NSUUID *recipientUUID = [[NSUUID alloc] initWithUUIDString:self.userIDTextField.text];
//    
//    if (!recipientUUID) {
//        // TODO: Log on invalid UUID.
//        
//        return;
//    }
//    
//    CRKUser *sender = [CRKUser currentUserInContext:context];
//    CRKUser *recipient = [CRKUser uniqueObjectWithIdentifier:recipientUUID inContext:context];
//    
//    CRKMessage *message = [[CRKMessage alloc] initWithEntity:[CRKMessage entityDescriptionInContext:context] insertIntoManagedObjectContext:context];
//    message.dateSent = [NSDate date];
//    message.text = self.messageTextField.text;
//    message.sender = sender;
//    message.reciever = recipient;
//    
//    [context performBlock:^{
//        NSError *saveError;
//        if (![context save:&saveError]) {
//            NSLog(@"Error saving: %@", saveError);
//            
//            return;
//        }
//        
//        [[CRKCoreDataHelper sharedHelper].persistenceController saveContextAndWait:NO completion:^(NSError *error) {
//            if (error) {
//                NSLog(@"Error saving: %@", error);
//            }
//        }];
//    }];
//}
- (IBAction)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSFetchedResultsController *)fetchedResultsController{
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CRKUser"];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isContact == YES"];
//        fetchRequest.predicate = predicate;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        NSManagedObjectContext *context = [CRKCoreDataHelper sharedHelper].persistenceController.managedObjectContext;
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    }
    return _fetchedResultsController;
}

#pragma mark - MDMFetchedResultsTableDataSourceDelegate
- (void)dataSource:(MDMFetchedResultsTableDataSource *)dataSource configureCell:(id)cell withObject:(id)object{
    UITableViewCell *newCell = (UITableViewCell *)cell;
    CRKUser *user = (CRKUser *)object;
    newCell.textLabel.text = user.displayName;
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedUser = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
