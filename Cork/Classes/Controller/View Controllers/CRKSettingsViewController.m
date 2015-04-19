//
//  CRKSettingsViewController.m
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKSettingsViewController.h"
#import <CDZQRScanningViewController/CDZQRScanningViewController.h>

@implementation CRKSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) this = self;
    [self addSection:^(JMStaticContentTableViewSection *section, NSUInteger sectionIndex) {
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"Share Contact Info", nil);
        } whenSelected:^(NSIndexPath *indexPath) {
            // TODO: Show QR code
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
            };
            scanningVC.errorBlock = ^(NSError *error){
                NSLog(@"%@",error);
            };
            scanningVC.cancelBlock = ^(){
                [this dismissViewControllerAnimated:YES completion:nil];
            };
            
            [this presentViewController:navigationController animated:YES completion:nil];
            // TODO: Show QR Code Scanner
        }];
        
        [section addCell:^(JMStaticContentTableViewCell *staticContentCell, UITableViewCell *cell, NSIndexPath *indexPath) {
            cell.textLabel.text = NSLocalizedString(@"Edit Contacts", nil);
        } whenSelected:^(NSIndexPath *indexPath) {
            // TODO: Show edit contacts UI
        }];
    }];
}

@end
