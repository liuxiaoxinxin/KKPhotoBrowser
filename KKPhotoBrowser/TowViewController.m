//
//  TowViewController.m
//  KKPhotoBrowser
//
//  Created by jessen.liu on 16/7/8.
//  Copyright © 2016年 kakao.inc. All rights reserved.
//

#import "TowViewController.h"
#import "KKPhotoBrowser.h"
#import "UIView+Size.h"
#import "YYWebImage.h"

@interface TowViewController ()

@end

@implementation TowViewController

- (NSArray *)photos
{
    return @[
             @"http://image.nationalgeographic.com.cn/2016/0706/20160706031714605.jpg",
             @"http://image.nationalgeographic.com.cn/2016/0626/20160626020956787.jpg",
             @"http://image.nationalgeographic.com.cn/2016/0623/20160623030527456.jpg",
             @"http://image.nationalgeographic.com.cn/2016/0622/20160622043924583.jpg",
             @"http://image.nationalgeographic.com.cn/2016/0621/20160621034703786.jpg",
             @"http://image.nationalgeographic.com.cn/2016/0620/20160620055051667.jpg",
             @"http://s1.dwstatic.com/group1/M00/64/D5/8f7ca8052a256987e43d137649fdec92.gif",
             @"http://s1.dwstatic.com/group1/M00/70/4D/cd51ff0d5fe4cb513373aee404992b35.gif"
             ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
    http://image.nationalgeographic.com.cn/2016/0706/20160706031714605.jpg
    http://image.nationalgeographic.com.cn/2016/0626/20160626020956787.jpg
    http://image.nationalgeographic.com.cn/2016/0623/20160623030527456.jpg
    http://image.nationalgeographic.com.cn/2016/0622/20160622043924583.jpg
    http://image.nationalgeographic.com.cn/2016/0621/20160621034703786.jpg
    http://image.nationalgeographic.com.cn/2016/0620/20160620055051667.jpg
    http://image.nationalgeographic.com.cn/2016/0619/20160619013050386.jpg
    
    http://s1.dwstatic.com/group1/M00/70/4D/cd51ff0d5fe4cb513373aee404992b35.gif
    http://s1.dwstatic.com/group1/M00/64/D5/8f7ca8052a256987e43d137649fdec92.gif
    http://s1.dwstatic.com/group1/M00/59/82/faaf832a76cad5b439b2d344835dc03a.gif
    */
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"清空缓存" style:UIBarButtonItemStyleDone target:self action:@selector(rightTouch)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *photo = [self photos];
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.frame = self.view.bounds;
    scrollView.contentSize = CGSizeMake(0, 160 * ceil(photo.count/2.0));
    [self.view addSubview:scrollView];
    
    int index = 0;
    for (NSString *imgPath in photo) {
        int num_x = index % 2;
        int num_y = index / 2;
        
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.frame = CGRectMake(10 + num_x * 160, 20 + num_y * 160, 150, 150);
        [imageView yy_setImageWithURL:[NSURL URLWithString:imgPath] placeholder:nil];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = index + 10;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchImageView:)];
        [imageView addGestureRecognizer:tap];
        [scrollView addSubview:imageView];
        
        index ++;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)click {
    NSArray *photos = [self photos];
    NSMutableArray *mtArray = [NSMutableArray new];
    for (NSString *url in photos) {
        
        KKPhoto *photo = [[KKPhoto alloc]initWithUrl:[NSURL URLWithString:url]];
        [mtArray addObject:photo];
    }
    
    KKPhotoBrowser *browser = [[KKPhotoBrowser alloc]init];
    [browser showInView:self photos:mtArray];
}

- (void)touchImageView:(UIGestureRecognizer *)tap {
    
    UIImageView *view = (UIImageView *)tap.view;
    KKPhotoBrowser *browser = [[KKPhotoBrowser alloc]init];
    NSMutableArray *mtArr = [[NSMutableArray alloc]init];
    NSArray *photo = [self photos];
    for (int n = 0; n < photo.count; n ++) {
        NSString *url = photo[n];
        KKPhoto *photo = [[KKPhoto alloc]initWithUrl:[NSURL URLWithString:url]];
        UIImageView *fromView = (UIImageView *)[self.view viewWithTag:n + 10];
        photo.fromView = fromView;
        photo.fromViewImage = fromView.image;
        [mtArr addObject:photo];
    }
    browser.currentPhotoIndex = view.tag - 10;
    [browser showInView:self showAnimatedType:KKPhotoBrowserTransitionTypeMagicMobile photos:mtArr];
}

- (void)rightTouch
{
    [[YYWebImageManager sharedManager].cache.diskCache removeAllObjects];
    [[YYWebImageManager sharedManager].cache.memoryCache removeAllObjects];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
