//
//  KKPhotoZoomingView.m
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/6/30.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import "KKPhotoZoomingView.h"
#import "KKPhotoProgressView.h"
#import "UIImageView+KKWebCache.h"
#import "UIView+Size.h"

@interface KKPhotoZoomingView()
{
    YYAnimatedImageView *_imageView;
    KKPhotoProgressView *_progressView;
}
@end

@implementation KKPhotoZoomingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self layotImageView];
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.delegate = self;
        self.bouncesZoom = YES;
        self.scrollsToTop = NO;
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
    }
    
    return self;
}

- (void)layotImageView {
    _imageView = [YYAnimatedImageView new];
    _imageView.size = self.size;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_imageView];
    
    _progressView = [[KKPhotoProgressView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    _progressView.center = CGPointMake(self.width/2, self.height/2);
    _progressView.hidden = YES;
    [self addSubview:_progressView];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect imgFrame = _imageView.frame;
    CGSize contentSize = scrollView.contentSize;
    
    CGPoint centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
    
    // 水平中心坐标
    if (imgFrame.size.width <= boundsSize.width) {
        centerPoint.x = boundsSize.width/2;
    }
    // 垂直中心坐标
    if (imgFrame.size.height <= boundsSize.height) {
        centerPoint.y = boundsSize.height/2;
    }
    
    _imageView.center = centerPoint;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    NSLog(@"%lu",(unsigned long)tapCount);
    if (tapCount != 1) {
        return;
    }
    [self performSelector:@selector(handleSingleTap:) withObject:touch afterDelay:0.2];
}

- (void)downloadImage {
    _progressView.hidden = NO;
    [_imageView kk_setImageViewURL:self.photo.url placeholder:nil progress:^(NSInteger receivedSize, NSInteger expectedSize) {

        _progressView.hidden = NO;
        _progressView.progress = (CGFloat)receivedSize/(CGFloat)expectedSize;
    } completion:^(UIImage *image, NSURL *url, NSError *error) {
        
        if (![url.absoluteString isEqualToString: self.photo.url.absoluteString]) return;
        [self setMaxMinZoomScalesForCurrentBounds];
        [self adjustPhotoViewFrame];
        _progressView.hidden = YES;
    }];
}

- (void)displayImage {
    if (self.photo == nil) return;
    //重置缩放相关
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeZero;
    
    UIImage *image = self.photo.image;
    if (image == nil) image = self.photo.fromViewImage;
    if (image) {
        _imageView.hidden = NO;
        _imageView.image = image;
        //1.先调整缩放尺寸
        [self setMaxMinZoomScalesForCurrentBounds];
        //2.然后调整图片尺寸
        [self adjustPhotoViewFrame];
    } else {
        _imageView.hidden = YES;
    }
}

//根据image调整imageView尺寸
- (void)adjustPhotoViewFrame {
    if (_imageView.image == nil) return;
    UIImage *image = _imageView.image;
    CGSize imageSize = image.size;
    CGFloat height = imageSize.height * self.width / imageSize.width;
    CGRect viewFrame = CGRectMake(0, 0, self.width, height);
    // y值
    if (viewFrame.size.height < self.height) {
        viewFrame.origin.y = floorf((self.height - viewFrame.size.height) / 2.0);
    } else {
        viewFrame.origin.y = 0;
    }
    _imageView.frame = viewFrame;
    
    self.contentSize = viewFrame.size;
}

//设置最小缩放
- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // 重置
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;

    if (_imageView.image == nil) return;
    
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _imageView.image.size;
    
    // 设置伸缩比例
    CGFloat minScale = boundsSize.width / imageSize.width;
    if (minScale > 1) {
        minScale = 1.0;
    }
    CGFloat maxScale = 2.0;
//    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
//        maxScale = maxScale / [[UIScreen mainScreen] scale];
//    }
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
}

- (void)hideLoadingView {
    
}

- (void)setPhoto:(KKPhoto *)photo {
    _photo = photo;
    if (photo.image) {
        [self displayImage];
    } else if (photo.url) {
        [self downloadImage];
    }
}

//双击手势
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    // 取消用户操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    CGPoint touchPoint = [tap locationInView:_imageView];
    if (self.zoomScale > self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGFloat newZoomScale = self.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

//单击手势
- (void)handleSingleTap:(UITouch *)touch {
    if (touch.tapCount != 1) return;
    if ([self.zoomViewDelegate respondsToSelector:@selector(zoomingViewDidTouch:)]) {
        [self.zoomViewDelegate zoomingViewDidTouch:self];
    }
}

-(YYAnimatedImageView *)contentView {
    return _imageView;
}

@end
