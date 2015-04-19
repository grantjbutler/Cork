//
//  CRK.m
//  Cork
//
//  Created by MichaelSelsky on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKFloatLabeledTextField.h"

@implementation CRKFloatLabeledTextField


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor groupTableViewBackgroundColor] CGColor];
    upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1.0f);
    [self.layer addSublayer:upperBorder];
}


@end
