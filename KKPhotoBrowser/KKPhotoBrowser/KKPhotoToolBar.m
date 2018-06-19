//
//  KKPhotoToolBar.m
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/8/1.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import "KKPhotoToolBar.h"
#import "UIView+Size.h"

@interface KKPhotoToolBar()
@property (nonatomic, strong) UIVisualEffectView *effectView;
@end

@implementation KKPhotoToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutLabels];
    }
    return self;
}

- (void)layoutLabels {
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    self.effectView.size = CGSizeMake(50, 20);
    self.effectView.center = CGPointMake(self.width/2, self.height/2);
    self.effectView.clipsToBounds = YES;
    self.effectView.layer.cornerRadius = self.effectView.height/2;
    [self addSubview:self.effectView];
    
    self.photoIndexLabel = [UILabel new];
    self.photoIndexLabel.size = self.size;
    self.photoIndexLabel.textAlignment = NSTextAlignmentCenter;
    self.photoIndexLabel.backgroundColor = [UIColor clearColor];
    self.photoIndexLabel.font = [UIFont boldSystemFontOfSize:13];
    self.photoIndexLabel.textColor = [UIColor grayColor];
    [self addSubview:self.photoIndexLabel];
}

@end
