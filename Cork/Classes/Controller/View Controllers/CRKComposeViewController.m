//
//  CRKComposeViewController.m
//  Cork
//
//  Created by MichaelSelsky on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKComposeViewController.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

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
- (IBAction)send:(id)sender {
    //TODO: send
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
