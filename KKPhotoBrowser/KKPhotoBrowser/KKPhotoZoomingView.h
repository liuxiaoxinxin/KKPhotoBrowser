//
//  KKPhotoZoomingView.h
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/6/30.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPhoto.h"
#import "YYAnimatedImageView.h"

@protocol KKPhotoZoomingViewDelegate;
@interface KKPhotoZoomingView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, readonly) YYAnimatedImageView *contentView;
@property (nonatomic, strong) KKPhoto *photo;
@property (nonatomic, weak) id<KKPhotoZoomingViewDelegate> zoomViewDelegate;
@end


@protocol KKPhotoZoomingViewDelegate <NSObject>

- (void)zoomingViewDidTouch:(KKPhotoZoomingView *)view;

@end