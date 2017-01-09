//
//  KKPhotoInteractiveTransition.h
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/6/28.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKPhotoBrowser,KKPhotoBrowserTransition;
@interface KKPhotoInteractiveTransition : UIPercentDrivenInteractiveTransition

- (instancetype)initWithPanGestureForViewController:(KKPhotoBrowser *)viewController;

///是否在交互
- (BOOL)interation;

@property (nonatomic, copy) void(^GestureRecognizerStateBegan)();
@end
