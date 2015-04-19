//
//  CRKQRCardViewController.m
//  Cork
//
//  Created by Grant Butler on 4/19/15.
//  Copyright (c) 2015 Grant Butler. All rights reserved.
//

#import "CRKQRCardViewController.h"

#import "CRKUser.h"

#import "CRKContactSerialization.h"

#import <Masonry/Masonry.h>

#import "QREncoder.h"

@interface CRKQRCardViewController () <UIScrollViewDelegate>

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) UIView *cardView;
@property (nonatomic) UIImageView *QRCodeImageView;

@property (nonatomic) CRKUser *user;

@end

@implementation CRKQRCardViewController

- (instancetype)initWithUser:(CRKUser *)user {
    self = [super init];
    if (self) {
        _user = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self setUpOverlayView];
    [self setUpScrollView];
    
    [self setUpCardView];
    [self setUpQRCodeImageView];
}

- (void)setUpOverlayView {
	self.overlayView = [[UIView alloc] init];
    self.overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
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
		make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0));
	}];
}

- (void)setUpCardView {
	self.cardView = [[UIView alloc] init];
	self.cardView.backgroundColor = [UIColor colorWithRed:24.0/255.0 green:159.0/255.0 blue:142.0/255.0 alpha:1.0];
	self.cardView.layer.cornerRadius = 20.0;
	[self.scrollView addSubview:self.cardView];
}

- (void)setUpQRCodeImageView {
    NSData *encodedContactCard = [CRKContactSerialization contactDataForUser:self.user];
    NSString *jsonString = [[NSString alloc] initWithData:encodedContactCard encoding:NSUTF8StringEncoding];
    
    DataMatrix *dataMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_H version:QR_VERSION_AUTO string:jsonString];
    UIImage *qrCode = [QREncoder renderDataMatrix:dataMatrix imageDimension:280];
    
	self.QRCodeImageView = [[UIImageView alloc] initWithImage:qrCode];
	[self.cardView addSubview:self.QRCodeImageView];
	
	[self.QRCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.center.equalTo(self.cardView);
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
    CGFloat yPosition = (CGRectGetHeight(self.view.frame) - 20.0);
    
	self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), yPosition * 2.0);
	self.scrollView.contentOffset = CGPointMake(0.0, yPosition);
	
	self.cardView.frame = CGRectMake(0.0, yPosition, CGRectGetWidth(self.view.frame), yPosition);
}

- (void)dismissIfNeeded {
    if (self.scrollView.contentOffset.y <= 0.0) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat position = MAX(MIN(scrollView.contentOffset.y, CGRectGetHeight(self.scrollView.frame)), 0);
	CGFloat alpha = position / CGRectGetHeight(self.scrollView.frame);
	self.overlayView.alpha = alpha;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self dismissIfNeeded];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self dismissIfNeeded];
    }
}

@end
