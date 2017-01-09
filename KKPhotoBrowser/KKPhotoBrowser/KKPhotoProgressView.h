//
//  KKPhotoProgressView.h
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/7/13.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKPhotoProgressView : UIView

@property (nonatomic, strong) UIColor *trackTintColor;
@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, assign) float progress;

@end
