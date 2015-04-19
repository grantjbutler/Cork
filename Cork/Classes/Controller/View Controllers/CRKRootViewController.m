//
//  ViewController.m
//  Cork
//
//  Created by Grant Butler on 4/18/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKRootViewController.h"
#import "CRKUser.h"

@interface CRKRootViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@end

@implementation CRKRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userIDLabel.text = [[CRKUser currentUserID] UUIDString];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
