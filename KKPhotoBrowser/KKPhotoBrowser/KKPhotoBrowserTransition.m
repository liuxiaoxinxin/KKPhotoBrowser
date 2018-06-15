//
//  KKPhotoBrowserTransition.m
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/6/28.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import "KKPhotoBrowserTransition.h"
#import "KKPhotoBrowser.h"
#import "UIView+Size.h"

@implementation KKPhotoBrowserTransition

+ (instancetype)transitionWithType:(KKPhotoTransitionType)type {
    return [[self alloc]initWithTransitionType:type];
}

- (instancetype)initWithTransitionType:(KKPhotoTransitionType)type {
    self = [super init];
    if (self) {
        _traType = type;
    }
    return self;
}

#pragma mark - 实现UIViewControllerAnimatedTransitioning协议
 // 时长
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return KKPhotoBrowserTransitionAnimateDuration;
}

// 动画定义
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (_traType) {
        case kPhotoTransitionPush:
            [self browesPushAnimation:transitionContext];
            break;
            
        case kPhotoTransitionPop:
            [self browesPopAnimation:transitionContext];
            break;
    }
}

#pragma mark - 动画方法

- (void)browesPushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    KKPhotoBrowser *toVc = (KKPhotoBrowser *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVc = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (toVc == nil || ![toVc isKindOfClass:[KKPhotoBrowser class]]) {
        [transitionContext completeTransition:NO];
        return;
    }
    UIView *containerView = [transitionContext containerView];
    //临时做动画的view
    UIImageView *tempView = [[UIImageView alloc]initWithFrame:[toVc.currentPhoto.fromView convertRect:toVc.currentPhoto.fromView.bounds toView:nil]];
    tempView.image = toVc.currentPhoto.fromViewImage;
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    tempView.clipsToBounds = YES;
    toVc.currentPhoto.fromView.hidden = YES;

    toVc.scrollView.hidden = YES;
    toVc.view.alpha = 0;
    
    [containerView addSubview:toVc.view];
    [containerView addSubview:tempView];
    
    CGSize imageSize = CGSizeZero;
    if (toVc.currentPhoto.fromViewImage) {
        imageSize = toVc.currentPhoto.fromViewImage.size;
    } else if (toVc.currentPhoto.image) {
        imageSize = toVc.currentPhoto.image.size;
    } else {
        imageSize = toVc.scrollView.size;
    }
    
    CGFloat height = imageSize.height * toVc.scrollView.width / imageSize.width;
    CGRect viewFrame = CGRectMake(0, 0, toVc.scrollView.width, height);
    // y值
    if (viewFrame.size.height < toVc.scrollView.height) {
        viewFrame.origin.y = floorf((toVc.scrollView.height - viewFrame.size.height) / 2.0) + toVc.scrollView.top;
    } else {
        viewFrame.origin.y = toVc.scrollView.top;
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:1 initialSpringVelocity:0.1 options:0 animations:^{
        
        tempView.frame = viewFrame;
        toVc.view.alpha = 1;
        fromVc.view.transform = CGAffineTransformMakeScale(0.9, 0.9);

    } completion:^(BOOL finished) {
        
        tempView.hidden = YES;
        toVc.currentPhoto.fromView.hidden = NO;
        toVc.scrollView.hidden = NO;
        // 过渡完成
        [transitionContext completeTransition:YES];
    }];
}

- (void)browesPopAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    KKPhotoBrowser *fromVc = (KKPhotoBrowser *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVc = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    // 之前做动画的tempView
    UIImageView *tempView = containerView.subviews.lastObject;
    CGRect stateRect = tempView.frame;
    tempView.image = fromVc.currentPhoto.fromViewImage;
    tempView.frame = [fromVc.currentPhotoView.contentView convertRect:fromVc.currentPhotoView.contentView.bounds toView:nil];
    tempView.hidden = NO;
    fromVc.currentPhoto.fromView.hidden = YES;
    fromVc.currentPhotoView.hidden = YES;
    [containerView insertSubview:toVc.view atIndex:0];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1 / 0.55 options:0 animations:^{
        // 如果动画由手势驱动这里只驱动背景，因为tempView会跟随手指移动
        fromVc.view.alpha = 0;
        toVc.view.transform = CGAffineTransformMakeScale(1, 1);
        if (NO == [transitionContext isInteractive]) {
            tempView.frame = [fromVc.currentPhoto.fromView convertRect:fromVc.currentPhoto.fromView.bounds toView:nil];
        }
    } completion:^(BOOL finished) {
        if (NO == [transitionContext transitionWasCancelled]) {
            [tempView removeFromSuperview];
            toVc.view.alpha = 1.0;
            fromVc.currentPhoto.fromView.hidden = NO;
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                tempView.frame = stateRect;
            }];
        }
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
