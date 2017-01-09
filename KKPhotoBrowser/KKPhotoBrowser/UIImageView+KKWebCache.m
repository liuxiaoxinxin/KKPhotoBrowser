//
//  UIImageView+KKWebCache.m
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/7/8.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import "UIImageView+KKWebCache.h"
#import "UIImageView+YYWebImage.h"

@implementation UIImageView (KKWebCache)

- (void)kk_setImageViewURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                  progress:(KKWebImageProgressBlock)progress
                completion:(KKWebImageCompletionBlock)completion;
{
    [self yy_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:YYWebImageOptionAllowInvalidSSLCertificates|YYWebImageOptionSetImageWithFadeAnimation
                    progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
                        progress(receivedSize,expectedSize);
                    } transform:nil completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                    
                        if (stage != YYWebImageStageProgress) {
                            completion(image,imageURL,error);
                        }
                    }];
}
@end
