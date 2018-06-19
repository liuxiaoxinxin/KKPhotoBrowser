//
//  KKPhotoBrowserTransition.h
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/6/28.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//  自定义push/pop转场动画管理类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KKPhotoBrowserTransitionAnimateDuration  0.5f

typedef NS_ENUM(NSInteger,KKPhotoTransitionType) {
    kPhotoTransitionPush = 0,
    kPhotoTransitionPop
};

@interface KKPhotoBrowserTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) KKPhotoTransitionType traType;

+ (instancetype)transitionWithType:(KKPhotoTransitionType)type;
- (instancetype)initWithTransitionType:(KKPhotoTransitionType)type;

@end
