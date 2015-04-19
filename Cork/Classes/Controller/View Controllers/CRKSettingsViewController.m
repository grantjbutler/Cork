//
//  CRKSettingsViewController.m
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKSettingsViewController.h"

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
            // TODO: Show QR Code Scanner
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
