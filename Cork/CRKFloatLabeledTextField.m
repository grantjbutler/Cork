//
//  CRK.m
//  Cork
//
//  Created by MichaelSelsky on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKFloatLabeledTextField.h"

@implementation CRKFloatLabeledTextField

- (instancetype)init{
    if (self = [super init]) {
        [self addBorder];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]){
        [self addBorder];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self addBorder];
    }
    
    return self;
}

- (void)addBorder{
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor groupTableViewBackgroundColor] CGColor];
    upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1.0f);
    [self.layer addSublayer:upperBorder];
}


@end
