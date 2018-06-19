//
//  KKPhotoBrowser.m
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/6/27.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import "KKPhotoBrowser.h"
#import "KKPhotoBrowserTransition.h"
#import "KKPhotoInteractiveTransition.h"
#import "KKPhotoToolBar.h"
#import "UIView+Size.h"

@interface KKPhotoBrowser ()
<UIScrollViewDelegate,
KKPhotoZoomingViewDelegate,
UIViewControllerTransitioningDelegate>
{
    NSArray *_photoViews; // 所有图片view
    KKPhotoToolBar *_toolBar;
    KKPhotoBrowserTransition *_browserTransition;
    KKPhotoInteractiveTransition *_interactiveTransition;
}

@property (nonatomic, weak) UIViewController* viewController;

@property (nonatomic, assign) BOOL oldNavigationBarHidden;

@property (nonatomic, readwrite) UIScrollView *scrollView;

@property (nonatomic, readwrite) NSArray<KKPhoto *> *photos;

@end

@implementation KKPhotoBrowser

#pragma mark - vc life

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.oldNavigationBarHidden = self.navigationController.navigationBar.hidden;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * self.photos.count, 0);
    self.scrollView.contentOffset = CGPointMake(self.currentPhotoIndex * self.scrollView.width, 0);
    [self.view addSubview:self.scrollView];
    
    _toolBar = [[KKPhotoToolBar alloc]initWithFrame:CGRectMake(0, self.view.height - 40, self.view.width, 40)];
    _toolBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_toolBar];
    
    _interactiveTransition = [[KKPhotoInteractiveTransition alloc]initWithPanGestureForViewController:self];
    [self showPhoto];
    [self reloadIndexNumbers:self.currentPhotoIndex];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.navigationBarHidden animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:self.oldNavigationBarHidden animated:animated];
}

- (void)dealloc {
    self.viewController.navigationController.delegate = nil;
    self.scrollView.delegate = nil;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [KKPhotoBrowserTransition transitionWithType:kPhotoTransitionPush];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [KKPhotoBrowserTransition transitionWithType:kPhotoTransitionPop];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return [_interactiveTransition interation] ? _interactiveTransition : nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offSet = scrollView.contentOffset.x;
    int index = offSet/scrollView.width;
    if (index != self.currentPhotoIndex) {
        _currentPhotoIndex = index;
        [self showPhoto];
        [self reloadIndexNumbers:index];
//        NSLog(@"当前第%i张照片    view数：%lu",index,(unsigned long)_photoViews.count);
    }
}

#pragma mark - ZoomViewDelegate

- (void)zoomingViewDidTouch:(KKPhotoZoomingView *)view {
    if (self.navigationBarHidden == NO) {
        BOOL hidden = self.navigationController.navigationBarHidden;
        [self.navigationController setNavigationBarHidden:!hidden animated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark 私有

- (void)showPhoto {
    if (self.photos == nil) return;
    //第一次
    if (self.scrollView.subviews.count == 0){
        KKPhotoZoomingView *photoView = [self getLeisurePhotoView];
        photoView.left = self.scrollView.width * self.currentPhotoIndex;
        photoView.photo = self.photos[self.currentPhotoIndex];
        [self.scrollView addSubview:photoView];
        //只有一张照片
        if (self.photos.count == 1) {
            return;
        }
    }
    
    //回收不用的view,当索引数离开当前索引时超过1时就回收
    for (KKPhotoZoomingView *photoView in self.scrollView.subviews) {
        if (abs((int)photoView.photo.index - (int)self.currentPhotoIndex) > 1) {
            [photoView removeFromSuperview];
        }
    }

    //准备显示与之相邻的图片
    if (self.currentPhotoIndex == 0) {
        [self layoutNextImageViewIsForward:YES];
    } else if (self.currentPhotoIndex == (self.photos.count - 1)) {
        [self layoutNextImageViewIsForward:NO];
    } else {
        [self layoutNextImageViewIsForward:NO];
        [self layoutNextImageViewIsForward:YES];
    }
}

- (void)reloadIndexNumbers:(NSInteger)index {
    _toolBar.photoIndexLabel.text = [NSString stringWithFormat:@"%li / %lu",index+1,self.photos.count];
}

//获取空闲的图片view,如果没有就会新建一个
- (KKPhotoZoomingView *)getLeisurePhotoView {
    for (KKPhotoZoomingView *view in _photoViews) {
        if (![self.scrollView.subviews containsObject:view]) {
            return view;
        }
    }
    NSMutableArray *photoViews = [[NSMutableArray alloc]initWithArray:_photoViews];
    KKPhotoZoomingView *view = [[KKPhotoZoomingView alloc]initWithFrame:self.scrollView.bounds];
    view.zoomViewDelegate = self;
    [photoViews addObject:view];
    _photoViews = photoViews;
//    NSLog(@"初始化第%lu个view",(unsigned long)_photoViews.count);
    return view;
}

//准备显示下一张图片，如果已有view直接赋值，如果没有则subView后再赋值
- (void)layoutNextImageViewIsForward:(BOOL)isForward {
    int forward = isForward ? 1 : -1;
    int index = (int)self.currentPhotoIndex + forward;
    if (index < 0 || index > self.photos.count) return;
    CGFloat viewLeft = self.scrollView.width * index;
    KKPhotoZoomingView *photoView = nil;
    for (KKPhotoZoomingView *view in _photoViews) {
        if (view.left == viewLeft && [self.scrollView.subviews containsObject:view]) {
            photoView = view;
            break;
        }
    }
    if (photoView == nil) {
        photoView = [self getLeisurePhotoView];
        photoView.left = viewLeft;
        [self.scrollView addSubview:photoView];
    }
    photoView.photo = self.photos[index];
//    NSLog(@"第%d张照片准备就绪 view数：%lu",index,(unsigned long)self.scrollView.subviews.count);
}

#pragma mark -
#pragma mark 公共方法

- (void)showInView:(UIViewController *)viewController photos:(NSArray<KKPhoto *> *)photos {
    [self showInView:viewController showAnimatedType:KKPhotoBrowserTransitionTypeMagicMobile photos:photos];
}

- (void)showInView:(UIViewController *)viewController showAnimatedType:(KKPhotoBrowserTransitionType)type photos:(NSArray<KKPhoto *> *)photos;
{
    if (photos == nil || photos.count == 0) return;
    self.photos = photos;
    self.viewController = viewController;
    _transitionType = type;
    if (type == KKPhotoBrowserTransitionTypePush) {
        [viewController.navigationController pushViewController:self animated:YES];
        return;
    } else if (type == KKPhotoBrowserTransitionTypePresent) {
        [viewController.navigationController presentViewController:self animated:YES completion:nil];
        return;
    }
    
    self.transitioningDelegate = self;
    self.navigationBarHidden = YES;
    [viewController presentViewController:self animated:YES completion:nil];
}

#pragma mark - set get

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    _navigationBarHidden = navigationBarHidden;
}

- (void)setPhotos:(NSArray<KKPhoto *> *)photos {
    for (int n = 0; n < photos.count; n ++) {
        photos[n].index = n;
    }
    _photos = photos;
}

- (KKPhoto *)currentPhoto {
    return self.photos[self.currentPhotoIndex];
}

- (KKPhotoZoomingView *)currentPhotoView {
    CGFloat viewLeft = self.scrollView.width * self.currentPhotoIndex;
    for (KKPhotoZoomingView *photoView in self.scrollView.subviews) {
        if (photoView.left == viewLeft) {
            return photoView;
        }
    }
    return nil;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.size = CGSizeMake(self.view.width, self.view.height);
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
    }
    return _scrollView;
}

@end
