//
//  UIImageView+KKWebCache.h
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/7/8.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KKWebImageCompletionBlock)(UIImage *image, NSURL *url ,NSError *error);
typedef void(^KKWebImageProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);


@interface UIImageView (KKWebCache)

/// 如果使用了其他图片框架，请在此方法内更换实现，demo里使用了YYWebImage
- (void)kk_setImageViewURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                  progress:(KKWebImageProgressBlock)progress
                completion:(KKWebImageCompletionBlock)completion;
@end
