//
//  ViewController.m
//  HQCycleScrollView
//
//  Created by HanQi on 2017/8/23.
//  Copyright © 2017年 HanQi. All rights reserved.
//

#import "ViewController.h"
#import "HQCycleScrollView.h"

@interface ViewController () {

    HQCycleScrollView *view;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    view = [[HQCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 200)];
    
    view.imageURLStringGroup = @[@"http://upload-images.jianshu.io/upload_images/5403259-98a777e7ccfc3e9b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                                 @"http://upload-images.jianshu.io/upload_images/1392844-31e811661ae01cbf.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                                 @"http://upload-images.jianshu.io/upload_images/5562021-4fb4e88d03608223.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                                 @"http://upload-images.jianshu.io/upload_images/5562021-f85a6e06d17d532a.jpg?imageMogr2/auto-orient/strip%7CimageView"];
    
    
    
    
    [self.view addSubview:view];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
