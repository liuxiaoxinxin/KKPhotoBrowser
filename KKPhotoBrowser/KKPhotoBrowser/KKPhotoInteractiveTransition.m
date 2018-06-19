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

@interface KKPhotoInteractiveTransition()<UIGestureRecognizerDelegate>
{
    BOOL _interation;
    CGFloat _persent; ///< 手指移动指数
}

@property (nonatomic, weak) KKPhotoBrowser *viewController;
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation KKPhotoInteractiveTransition

- (instancetype)initWithPanGestureForViewController:(KKPhotoBrowser *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        pan.delegate = self;
        [viewController.view addGestureRecognizer:pan];
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UISlider class]]) { // 如果在滑块上点击就不响应pan手势
        return NO;
    }
    return YES;
}

- (void)handleGesture:(UIPanGestureRecognizer *)panGesture {
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
        // 开始滑动的时候会执行一次
        viewPoint  = tempView.frame.origin; // 记录开始的坐标
    }
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _interation = YES;
            [_viewController dismissViewControllerAnimated:YES completion:nil];
            startPoint = [panGesture locationInView:panGesture.view];
            viewPoint = CGPointZero;
        } break;
        case UIGestureRecognizerStateChanged: {
            endPoint = [panGesture locationInView:panGesture.view];
            CGPoint changePoint = CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
            CGPoint newPoint = CGPointMake(viewPoint.x + changePoint.x, viewPoint.y + changePoint.y);
            [self gestureRecognizerMoveWithChangePoint:changePoint newPoint:newPoint];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self gestureRecognizerEndWithViewPoint:viewPoint];
        } break;
        default: break;
    }
}

- (void)gestureRecognizerMoveWithChangePoint:(CGPoint)changePoint newPoint:(CGPoint)newPoint {
    UIView *containerView = [_transitionContext containerView];
    UIImageView *tempView = containerView.subviews.lastObject;
    _persent = fabs(changePoint.y / 500.0f);
    tempView.origin = newPoint; // 直接移动imageView
    [self updateInteractiveTransition:_persent];
}

- (void)gestureRecognizerEndWithViewPoint:(CGPoint)point {
    UIView *containerView = [_transitionContext containerView];
    UIImageView *tempView = containerView.subviews.lastObject;
    _interation = NO;
    if (_persent > 0.15) {
        // 完成
        [self finishInteractiveTransition];
        [self transitionAnimateWithAnimations:^{
            UIView *fromView = _viewController.currentPhoto.fromView;
            tempView.frame = [fromView convertRect:fromView.bounds toView:nil];
        } completion:nil];
    } else {
        // 取消
        [self cancelInteractiveTransition];
        [self transitionAnimateWithAnimations:^{
            tempView.origin = point;
        } completion:^(BOOL finished) {
            tempView.hidden = YES;
            _viewController.currentPhotoView.hidden = NO;
            _viewController.currentPhoto.fromView.hidden = NO;
        }];
    }
}

- (void)transitionAnimateWithAnimations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion {
    [UIView animateWithDuration:KKPhotoBrowserTransitionAnimateDuration * (1 - _persent)
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:1 / 0.55
                        options:0
                     animations:animations
                     completion:completion];
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    _transitionContext = transitionContext;
    [super startInteractiveTransition:transitionContext];
}

- (BOOL)interation {
    return _interation;
}

@end

