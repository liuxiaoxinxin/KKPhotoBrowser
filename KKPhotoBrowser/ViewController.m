//
//  ViewController.m
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/3/8.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import "ViewController.h"
#import "KKPhotoBrowser.h"
#import "TowViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *photo = [self photos];

    UIScrollView *scrollView = [UIScrollView new];
    scrollView.frame = self.view.bounds;
    scrollView.contentSize = CGSizeMake(0, 160 * ceil(photo.count/2.0));
    scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [self.view addSubview:scrollView];
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    int index = 0;
    for (NSString *imgPath in photo) {
        int num_x = index % 2;
        int num_y = index / 2;

        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.frame = CGRectMake(10 + num_x * 160, 20 + num_y * 160, 150, 150);
        imageView.image = [UIImage imageNamed:imgPath];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = index + 10;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchImageView:)];
        [imageView addGestureRecognizer:tap];
        [scrollView addSubview:imageView];
        
        index ++;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"网络图片" style:UIBarButtonItemStyleDone target:self action:@selector(rightTouch)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)photos
{
    return @[@"20160622043924583.jpg",@"20160620055051667mini.jpg",@"20160620055051667.jpg",@"20160520162626-6934-0.jpeg",@"20160520170016-86097-0.jpeg",@"117422.png",@"IMG_3386.JPG",@"20160520162626-6934-0w.jpg",@"20160520162626-6934-0h.jpg"];
}

- (void)touchImageView:(UIGestureRecognizer *)tap {
    
    UIView *view = tap.view;
    
    KKPhotoBrowser *browser = [[KKPhotoBrowser alloc]init];
    browser.navigationBarHidden = YES;
    NSMutableArray *mtArr = [[NSMutableArray alloc]init];
    NSArray *photo = [self photos];
    for (int n = 0; n < photo.count; n ++) {
        NSString *photoName = photo[n];
        KKPhoto *photo = [[KKPhoto alloc]initWithImage:[UIImage imageNamed:photoName]];
        photo.fromView = [self.view viewWithTag:n + 10];
        photo.fromViewImage = [UIImage imageNamed:photoName];
        [mtArr addObject:photo];
    }
    
    browser.currentPhotoIndex = view.tag - 10;
    [browser showInView:self photos:mtArr];
}

- (void)rightTouch
{
    TowViewController *vc = [[TowViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
