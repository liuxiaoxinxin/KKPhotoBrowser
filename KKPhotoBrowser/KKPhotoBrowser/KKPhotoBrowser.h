//
//  KKPhotoBrowser.h
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/6/27.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPhotoZoomingView.h"
#import "KKPhoto.h"

typedef NS_ENUM(NSInteger ,KKPhotoBrowserTransitionType) {
    KKPhotoBrowserTransitionTypeMagicMobile, ///< 神奇移动
    KKPhotoBrowserTransitionTypePush,        ///< 系统push
    KKPhotoBrowserTransitionTypePresent      ///< 系统模态推出
};

@interface KKPhotoBrowser : UIViewController

/// 弹出图片浏览器
- (void)showInView:(UIViewController *)viewController photos:(NSArray<KKPhoto *> *)photos;
- (void)showInView:(UIViewController *)viewController showAnimatedType:(KKPhotoBrowserTransitionType)type photos:(NSArray<KKPhoto *> *)photos;

/// 是否隐藏导航栏，默认NO
@property (nonatomic, assign) BOOL navigationBarHidden;
/// scroll
@property (nonatomic, readonly) UIScrollView *scrollView;
/// 所有的图片对象
@property (nonatomic, readonly) NSArray<KKPhoto *> *photos;
/// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
/// 当前photo
@property (nonatomic, readonly) KKPhoto *currentPhoto;
/// 当前显示的photoView
@property (nonatomic, readonly) KKPhotoZoomingView *currentPhotoView;
@property (nonatomic, assign, readonly) KKPhotoBrowserTransitionType transitionType;
@end
