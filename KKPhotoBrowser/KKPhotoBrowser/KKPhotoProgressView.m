//
//  KKPhotoProgressView.m
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/7/13.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import "KKPhotoProgressView.h"

#define kDegreeToRadian(x) (M_PI/180.0 * (x))
#define kPhotoProgressAnimationTime   2.0f

@interface KKPhotoProgressView()
{
    CAShapeLayer *_progressLayer;
    CAShapeLayer *_bgdLayer;
}
@end

@implementation KKPhotoProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _trackTintColor = [UIColor colorWithRed:48.0/225.0 green:48.0/225.0 blue:48.0/225.0 alpha:1];
        _progressTintColor = [UIColor colorWithRed:29.0/225.0 green:148.0/225.0 blue:201.0/225.0 alpha:1];
        
        CGPoint centerPoint = CGPointMake(self.frame.size.height / 2, self.frame.size.width / 2);
        CGFloat radius = self.frame.size.width/2;
        
        UIBezierPath* aPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                             radius:radius*0.9
                                                         startAngle:0
                                                           endAngle:kDegreeToRadian(360)
                                                          clockwise:YES];
        aPath.lineCapStyle = kCGLineCapRound; //线条拐角
        aPath.lineJoinStyle = kCGLineCapRound; //终点处理
        
        _bgdLayer = [[CAShapeLayer alloc]init];
        _bgdLayer.frame = self.bounds;
        _bgdLayer.path = aPath.CGPath;
        _bgdLayer.lineWidth = 4;
        _bgdLayer.strokeColor = _trackTintColor.CGColor;
        _bgdLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_bgdLayer];
        
        _progressLayer = [[CAShapeLayer alloc]init];
        _progressLayer.frame = self.bounds;
        _progressLayer.path = aPath.CGPath;
        _progressLayer.lineWidth = 4;
        _progressLayer.strokeColor = _progressTintColor.CGColor;
        _progressLayer.strokeStart = 0.0f;
        _progressLayer.strokeEnd = 0.0f;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_progressLayer];
    }
    return self;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    _progressLayer.strokeEnd = progress;
    if (progress < 1) {
        _progressLayer.hidden = NO;
    } else {
        [self performSelector:@selector(hide) withObject:self afterDelay:0.2];
    }
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    _trackTintColor = trackTintColor;
    _bgdLayer.strokeColor = trackTintColor.CGColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    _progressLayer.strokeColor = progressTintColor.CGColor;
}

- (void)show {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0f;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0f;
    }];
}

@end

