//
//  KKPhotoZoomingView.h
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/6/30.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPhoto.h"

#if __has_include (<YYWebImage/YYAnimatedImageView.h>)
#import <YYWebImage/YYAnimatedImageView.h>
@compatibility_alias KKImageView YYAnimatedImageView;
#elif __has_include ("YYAnimatedImageView.h")
#import "YYAnimatedImageView.h"
@compatibility_alias KKImageView YYAnimatedImageView;
#else
@compatibility_alias KKImageView UIImageView;
#endif

@protocol KKPhotoZoomingViewDelegate;
@interface KKPhotoZoomingView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, readonly) KKImageView *contentView;
@property (nonatomic, strong) KKPhoto *photo;
@property (nonatomic, weak) id<KKPhotoZoomingViewDelegate> zoomViewDelegate;

@end


@protocol KKPhotoZoomingViewDelegate <NSObject>

- (void)zoomingViewDidTouch:(KKPhotoZoomingView *)view;

@end
