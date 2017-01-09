//
//  KKPhoto.h
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/7/1.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KKPhoto : NSObject

///初始化方法
- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithUrl:(NSURL *)url;

@property (nonatomic, readonly) UIImage *image;///<图片源Image对象
@property (nonatomic, readonly) NSURL *url;///<图片源url
@property (nonatomic, strong) UIView *fromView; ///<来源view，用于神奇移动动画
@property (nonatomic, strong) UIImage *fromViewImage; ///<来源view上的image,也是用于神奇移动
@property (nonatomic, copy) NSString *caption; ///<描述
@property (nonatomic, copy) NSAttributedString *attributedCaption; ///<富文本描述

///索引，这是由内部生成的
@property (nonatomic, assign) NSInteger index;
@end
