//
//  KKPhotoInteractiveTransition.m
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/6/28.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import "KKPhotoInteractiveTransition.h"
#import "KKPhotoBrowserTransition.h"
#import "KKPhotoBrowser.h"
#import "UIView+Size.h"

@interface KKPhotoInteractiveTransition()
{
    BOOL _interation;
    CGPoint _goGestureImageView;
    CGFloat _persent;
}

@property (nonatomic, weak) KKPhotoBrowser *viewController;
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation KKPhotoInteractiveTransition

- (instancetype)initWithPanGestureForViewController:(KKPhotoBrowser *)viewController
{
    self = [super init];
    if (self) {
        _viewController = viewController;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [viewController.view addGestureRecognizer:pan];
    }
    
    return self;
}

- (void)handleGesture:(UIPanGestureRecognizer *)panGesture
{
    KKPhoto *currentPhoto = self.viewController.currentPhoto;
    if (currentPhoto.fromView == nil || currentPhoto.fromViewImage == nil) {
        return;
    }

    static CGPoint startPoint;    // 记录开始滑动时的 触控位置坐标
    CGPoint endPoint;             // 记录结束滑动时的 触控位置坐标
    static CGPoint viewPoint;     // 记录开始滑动时的动画视图位置坐标
    
    UIView *containerView = [_transitionContext containerView];
    UIImageView *tempView = containerView.subviews.lastObject;
    
    if (viewPoint.x == 0 && viewPoint.y == 0 && tempView) {
        //开始滑动的时候会执行一次
        viewPoint  = tempView.origin; //记录开始的坐标
        containerView.layer.speed = 0; //动画停止在开始的时候
    }
    
    switch (panGesture.state) {
            //开始滑动
        case UIGestureRecognizerStateBegan:
        {
            _interation = YES;
            [_viewController.navigationController popViewControllerAnimated:YES];
            startPoint = [panGesture locationInView:panGesture.view];
            viewPoint = CGPointZero;
        }break;
            //滑动
        case UIGestureRecognizerStateChanged:
        {
            endPoint = [panGesture locationInView:panGesture.view];
            CGPoint changePoint = CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
            _goGestureImageView = CGPointMake(viewPoint.x + changePoint.x, viewPoint.y + changePoint.y);
            _persent = fabs(changePoint.y / 1000.0f);
            tempView.origin = _goGestureImageView; //直接移动imageView
            containerView.layer.timeOffset = KKPhotoBrowserTransitionAnimateDuration * _persent; //驱动动画进度
            NSLog(@"%f,timeOffset = %f",_persent,containerView.layer.timeOffset);
            
        }break;
            //结束
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            _interation = NO;
            if (_persent > 0.15) {
                //完成
                [self finishInteractiveTransition];
                [self transitionAnimateWithAnimations:^{
                    UIView *fromView = _viewController.currentPhoto.fromView;
                    tempView.frame = [fromView convertRect:fromView.bounds toView:nil];
                } completion:nil];

            } else {
                
                //取消了
                containerView.layer.timeOffset = 0;//动画进度设回0
                [self cancelInteractiveTransition];
                [self transitionAnimateWithAnimations:^{
                    tempView.origin = viewPoint;
                } completion:^(BOOL finished) {
                    tempView.hidden = YES;
                    _viewController.currentPhotoView.hidden = NO;
                    _viewController.currentPhoto.fromView.hidden = NO;
                }];
                
//                CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(cancelInteractiveAnimate:)];
//                [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            }
            
        } break;
        default: break;
    }
}

//- (void)cancelInteractiveAnimate:(CADisplayLink *)display {
//    NSLog(@"display.duration = %f",display.duration);
//    UIView *containerView = [_transitionContext containerView];
//    CGFloat timeOffset = containerView.layer.timeOffset - display.duration/10;
//    if (timeOffset > 0) {
//        containerView.layer.timeOffset = timeOffset;
//    } else {
//        [display invalidate];
//        containerView.layer.timeOffset = 0;
////        containerView.layer.speed = 1;
//    }
//}

- (void)transitionAnimateWithAnimations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion
{
    [UIView animateWithDuration:KKPhotoBrowserTransitionAnimateDuration * (1 - _persent)
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:1 / 0.55
                        options:0
                     animations:animations
                     completion:completion];
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    _transitionContext = transitionContext;
    [super startInteractiveTransition:transitionContext];
}

- (BOOL)interation {
    return _interation;
}
@end
