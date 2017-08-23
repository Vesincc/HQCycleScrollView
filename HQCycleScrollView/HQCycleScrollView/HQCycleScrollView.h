//
//  HQCycleScrollView.h
//  HQCycleScrollView
//
//  Created by HanQi on 2017/8/23.
//  Copyright © 2017年 HanQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HQCycleScrollView;

@protocol HQCycleScrollViewDelegate <NSObject>


/**
 图片点击时回调

 @param cycleScrollView HQCycleScrollView
 @param index 图片标号
 */
- (void)cycleScrollView:(HQCycleScrollView *)cycleScrollView didSelectedItemAtIndex:(NSInteger)index;


/**
 图片滚动时回调

 @param cycleScrollView HQCycleScrollView
 @param index 图片标号
 */
- (void)cycleScrollView:(HQCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index;

@end

@interface HQCycleScrollView : UIView


/**
 网络图片 url 字符串数组
 */
@property (nonatomic, strong) NSArray *imageURLStringGroup;


/**
 本地图片名数组
 */
@property (nonatomic, strong) NSArray *imageNameGroup;


@property (nonatomic, weak) id <HQCycleScrollViewDelegate> delegate;


/**
 轮播图片ContentMode, 默认为UIViewContentModeScaleToFill
 */
@property (nonatomic, assign) UIViewContentMode bannerImageViewContentMode;


/**
 默认图片占位图
 */
@property (nonatomic, strong) UIImage *placeholderImage;


/**
 是否显示分页控制, 默认为YES
 */
@property (nonatomic, assign) BOOL showPageControl;


/**
 分页控制距离轮播图底部距离
 */
@property (nonatomic, assign) CGFloat pageControlBottomOffset;


/**
 分页控制大小
 */
@property (nonatomic, assign) CGSize pageControlSize;


/**
 当前分页显示颜色
 */
@property (nonatomic, strong) UIColor *currentPageControlColor;


/**
 分页控制未选中颜色
 */
@property (nonatomic, strong) UIColor *defaultPageControlColor;


/**
 自动滚动时间, 默认3s
 */
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;


/**
 是否无限循环, 默认YES
 */
@property (nonatomic, assign) BOOL infiniteLoop;


/**
 是否自动滚动, 默认YES
 */
@property (nonatomic, assign) BOOL autoScroll;


/**
 图片滚动方向, 默认水平滚动
 */
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;



@end
