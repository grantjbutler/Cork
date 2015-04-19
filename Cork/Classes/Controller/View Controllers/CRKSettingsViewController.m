//
//  CRKSettingsViewController.m
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKSettingsViewController.h"
#import <CDZQRScanningViewController/CDZQRScanningViewController.h>

#import "CRKQRCardViewController.h"

#import "CRKUser.h"

#import "CRKCoreDataHelper.h"
#import "CRKContactSerialization.h"


@implementation CRKSettingsViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"Settings", nil);
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) this = self;
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            /**
             *  TODO: textfield
             */
        }];
    }];
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"Share Contact Info", nil);
        } whenSelected:^(NSIndexPath *indexPath) {
            NSManagedObjectContext *context = [CRKCoreDataHelper sharedHelper].managedObjectContext;
            CRKUser *user = [CRKUser currentUserInContext:context];
            
            CRKQRCardViewController *cardViewController = [[CRKQRCardViewController alloc] initWithUser:user];
            cardViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:cardViewController animated:YES completion:nil];
        }];
    }];
    
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"Add Contact", nil);
        } whenSelected:^(NSIndexPath *indexPath) {
            CDZQRScanningViewController *scanningVC = [[CDZQRScanningViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:scanningVC];
            
            scanningVC.resultBlock = ^(NSString *result){
                //TODO: handle getting a successful qr read
                NSData *contactData = [result dataUsingEncoding:NSUTF8StringEncoding];
                NSManagedObjectContext *context = [CRKCoreDataHelper sharedHelper].persistenceController.newPrivateChildManagedObjectContext;
                CRKUser *user = [CRKContactSerialization userForContactData:contactData inContext:context];
                [context performBlock:^{
                    [context save:nil];
                    [[CRKCoreDataHelper sharedHelper].persistenceController saveContextAndWait:NO completion:nil];
                }];
                [this dismissViewControllerAnimated:YES completion:nil];
            };
            scanningVC.errorBlock = ^(NSError *error){
                NSLog(@"%@",error);
                [this dismissViewControllerAnimated:YES completion:nil];
            };
            scanningVC.cancelBlock = ^(){
                [this dismissViewControllerAnimated:YES completion:nil];
            };
            
            [this presentViewController:navigationController animated:YES completion:nil];
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"Edit Contacts", nil);
        } whenSelected:^(NSIndexPath *indexPath) {
            // TODO: Show edit contacts UI
        }];
    }];
}

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
