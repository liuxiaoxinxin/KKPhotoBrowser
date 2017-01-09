//
//  KKPhotoToolBar.m
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/8/1.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import "KKPhotoToolBar.h"
#import "UIView+Size.h"

@implementation KKPhotoToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self layoutLabels];
    }
    return self;
}

- (void)layoutLabels
{
    self.photoIndexLabel = [UILabel new];
    self.photoIndexLabel.size = self.size;
    self.photoIndexLabel.textAlignment = NSTextAlignmentCenter;
    self.photoIndexLabel.backgroundColor = [UIColor clearColor];
    self.photoIndexLabel.font = [UIFont boldSystemFontOfSize:17];
    self.photoIndexLabel.textColor = [UIColor whiteColor];
    self.photoIndexLabel.shadowColor = [UIColor blackColor];
    self.photoIndexLabel.shadowOffset = CGSizeMake(1, 0);
    [self addSubview:self.photoIndexLabel];
}
@end
