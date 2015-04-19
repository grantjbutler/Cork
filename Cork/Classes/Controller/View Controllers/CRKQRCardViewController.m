//
//  CRKQRCardViewController.m
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKQRCardViewController.h"

#import <Masonry/Masonry.h>

@interface CRKQRCardViewController () <UIScrollViewDelegate>

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) UIView *cardView;
@property (nonatomic) UIImageView *QRCodeImageView;

@end

@implementation CRKQRCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self setUpOverlayView];
    [self setUpScrollView];
}

- (void)setUpOverlayView {
	self.overlayView = [[UIView alloc] init];
    self.overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self.view addSubview:self.overlayView];
	
	[self.overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
}

- (void)setUpScrollView {
	self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
	self.scrollView.pagingEnabled = YES;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.bounces = NO;
    [self.view addSubview:self.scrollView];
	
	[self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
}

- (void)setUpCardView {
	self.cardView = [[UIView alloc] init];
	self.cardView.backgroundColor = self.view.tintColor;
	self.cardView.layer.cornerRadius = 10.0;
	[self.scrollView addSubview:self.cardView];
}

- (void)setUpQRCodeImageView {
	self.QRCodeImageView = [[UIImageView alloc] init];
	[self.cardView addSubview:self.QRCodeImageView];
	
	[self.QRCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.center.equalTo(self.cardView);
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 2.0);
	self.scrollView.contentOffset = CGPointMake(0.0, CGRectGetHeight(self.view.frame));
	
	self.cardView.frame = CGRectMake(0.0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat position = MAX(MIN(scrollView.contentOffset.y, CGRectGetHeight(self.view.frame)), 0);
	CGFloat alpha = position / CGRectGetHeight(self.view.frame);
	self.overlayView.alpha = alpha;
}

@end
