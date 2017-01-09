//
//  KKPhoto.m
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/7/1.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import "KKPhoto.h"

@implementation KKPhoto

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

- (instancetype)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}
@end
