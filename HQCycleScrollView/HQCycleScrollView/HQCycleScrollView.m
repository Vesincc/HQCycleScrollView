//
//  HQCycleScrollView.m
//  HQCycleScrollView
//
//  Created by HanQi on 2017/8/23.
//  Copyright © 2017年 HanQi. All rights reserved.
//

#import "HQCycleScrollView.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "HQCycleScrollViewCell.h"

#define qCycleScrollViewInitialPageControlSize CGSizeMake(10, 10)

NSString * const ID = @"HQCycleScrollViewCell";

@interface HQCycleScrollView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSArray *imagePathGroup;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, assign) NSInteger totalItemsCount;

@property (nonatomic, weak) UIControl *pageControl;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation HQCycleScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initialization];
        [self configerView];
        
    }
    return self;
}


- (void)initialization {

    _autoScroll = YES;
    _autoScrollTimeInterval = 3.0;
    _infiniteLoop = YES;
    _showPageControl = YES;
    _pageControlSize = qCycleScrollViewInitialPageControlSize;
    _pageControlBottomOffset = 0;
    _currentPageControlColor = [UIColor whiteColor];
    _defaultPageControlColor = [UIColor lightGrayColor];
    _bannerImageViewContentMode = UIViewContentModeScaleToFill;
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.backgroundColor = [UIColor lightGrayColor];
    
}

- (void)configerView {

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = _scrollDirection;
    _flowLayout = flowLayout;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_flowLayout];
    collectionView.backgroundColor = [UIColor lightGrayColor];
    collectionView.pagingEnabled= YES;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    [collectionView registerClass:[HQCycleScrollViewCell class] forCellWithReuseIdentifier:ID];
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    [self addSubview:collectionView];
    _collectionView = collectionView;
    
}

- (void)configerPageControl {

    if (_pageControl) {
    
        [_pageControl removeFromSuperview];
        
    }
    
    if (self.imagePathGroup.count == 0 || self.imagePathGroup.count == 1) {
    
        return;
        
    }
    
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:[self currentIndex]];
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = self.imagePathGroup.count;
    pageControl.currentPageIndicatorTintColor = self.currentPageControlColor;
    pageControl.pageIndicatorTintColor = self.defaultPageControlColor;
    pageControl.userInteractionEnabled = NO;
    pageControl.currentPage = indexOnPageControl;
    [self addSubview:pageControl];
    _pageControl = pageControl;
    
}

- (int)pageControlIndexWithCurrentCellIndex:(int)index {

    return (int)(index % self.imagePathGroup.count);
    
}

- (int)currentIndex {

    if (_collectionView.bounds.size.width == 0 || _collectionView.bounds.size.height == 0) {
    
        return 0;
        
    }
    
    int index = 0;
    
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        
        index = (_collectionView.contentOffset.x + _flowLayout.itemSize.width * 0.5) / _flowLayout.itemSize.width;
    
    } else {
        
        index = (_collectionView.contentOffset.y + _flowLayout.itemSize.height * 0.5) / _flowLayout.itemSize.height;
        
    }
    
    return MAX(0, index);
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _totalItemsCount;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HQCycleScrollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    long itemIndex = [self pageControlIndexWithCurrentCellIndex:(int)indexPath.item];
    
    NSString *imagePath = self.imagePathGroup[itemIndex];
    
    if ([imagePath isKindOfClass:[NSString class]]) {
        
        if ([imagePath hasPrefix:@"http"]) {
            
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.placeholderImage];
        
        } else {
            
            UIImage *image = [UIImage imageNamed:imagePath];
            if (!image) {
             
                [UIImage imageWithContentsOfFile:imagePath];
            
            }
            
            cell.imageView.image = image;
        
        }
    } else if ([imagePath isKindOfClass:[UIImage class]]) {
        
        cell.imageView.image = (UIImage *)imagePath;
    
    }
    
    cell.imageView.contentMode = self.bannerImageViewContentMode;

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didSelectedItemAtIndex:)]) {
        
        [self.delegate cycleScrollView:self didSelectedItemAtIndex:indexOnPageControl];
    
    }
    
}

//解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    if (!newSuperview) {
        
        [self invalidateTimer];
    
    }
}

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!self.imagePathGroup.count) {
    
        return; // 解决清除timer时偶尔会出现的问题
        
    }
    
    int itemIndex = [self currentIndex];
    
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    UIPageControl *pageControl = (UIPageControl *)_pageControl;
    pageControl.currentPage = indexOnPageControl;

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.autoScroll) {
        
        [self invalidateTimer];
    
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.autoScroll) {
    
        [self setupTimer];
    
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self scrollViewDidEndScrollingAnimation:self.collectionView];

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if (!self.imagePathGroup.count) {
    
        return; // 解决清除timer时偶尔会出现的问题
        
    }
    
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    if (self.infiniteLoop) {
    
        if (indexOnPageControl + 1 == self.imagePathGroup.count) {
            
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_totalItemsCount * 0.5 - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            
        } else if (indexOnPageControl == 0) {
            
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_totalItemsCount * 0.5 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            
        }
        
    }
    
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didScrollToIndex:)]) {
        
        [self.delegate cycleScrollView:self didScrollToIndex:indexOnPageControl];
    
    }
}

- (void)setupTimer {

    [self invalidateTimer]; // 创建定时器前先停止定时器，不然会出现僵尸定时器，导致轮播频率错误
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

}

- (void)invalidateTimer {

    [_timer invalidate];
    _timer = nil;
    
}

- (void)automaticScroll {

    if (0 == _totalItemsCount) {
    
        return;
        
    }
    
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex];
    
}

- (void)scrollToIndex:(NSInteger)index {

    if (index >= _totalItemsCount) {
        
        if (self.infiniteLoop) {
        
            index = _totalItemsCount * 0.5;
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
        }
        
        return;
    }
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
}

- (void)layoutSubviews {
    
    self.delegate = self.delegate;
    
    [super layoutSubviews];
    
    _flowLayout.itemSize = self.frame.size;
    
    _collectionView.frame = self.bounds;
    
    if (_collectionView.contentOffset.x == 0 &&  _totalItemsCount) {
        
        int targetIndex = 0;
        if (self.infiniteLoop) {
            
            targetIndex = _totalItemsCount * 0.5;
            
        } else {
            
            targetIndex = 0;
        
        }
        
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    CGSize size = CGSizeZero;
    
    size = CGSizeMake(self.imagePathGroup.count * self.pageControlSize.width * 1.5, self.pageControlSize.height);
    
    CGFloat x = (self.bounds.size.width - size.width) * 0.5;

    CGFloat y = self.collectionView.bounds.size.height - size.height - 10;
    
    CGRect pageControlFrame = CGRectMake(x, y, size.width, size.height);
    pageControlFrame.origin.y -= self.pageControlBottomOffset;
    
    self.pageControl.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.pageControlSize.width/10, self.pageControlSize.height/10);
    
    self.pageControl.frame = pageControlFrame;
    self.pageControl.hidden = !_showPageControl;
    
    if (self.backgroundImageView) {
        
        self.backgroundImageView.frame = self.bounds;
    
    }
    
}

#pragma mark - setter

- (void)setImageURLStringGroup:(NSArray *)imageURLStringGroup {
    
    _imageURLStringGroup = imageURLStringGroup;
    
    NSMutableArray *temp = [NSMutableArray new];
    [_imageURLStringGroup enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        NSString *urlString;
        if ([obj isKindOfClass:[NSString class]]) {
            
            urlString = obj;
            
        } else if ([obj isKindOfClass:[NSURL class]]) {
            
            NSURL *url = (NSURL *)obj;
            urlString = [url absoluteString];
        }
        
        if (urlString) {
            
            [temp addObject:urlString];
            
        }
    }];
    
    self.imagePathGroup = [temp copy];
    
}

- (void)setImagePathGroup:(NSArray *)imagePathGroup {
    
    [self invalidateTimer];
    
    _imagePathGroup = imagePathGroup;
    
    _totalItemsCount = self.infiniteLoop ? self.imagePathGroup.count * 100 : self.imagePathGroup.count;
    
    if (imagePathGroup.count > 1) { // 由于 !=1 包含count == 0等情况
        
        self.collectionView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
        
    } else {
        
        self.collectionView.scrollEnabled = NO;
        [self setAutoScroll:NO];
        
    }
    
    [self configerPageControl];
    [self.collectionView reloadData];
    
}

- (void)setImageNameGroup:(NSArray *)imageNameGroup {

    _imageNameGroup = imageNameGroup;
    self.imagePathGroup = [imageNameGroup copy];
    
}

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval {

    _autoScrollTimeInterval = autoScrollTimeInterval;
    
    [self setAutoScroll:self.autoScroll];
    
}

- (void)setAutoScroll:(BOOL)autoScroll {
    
    _autoScroll = autoScroll;
    
    [self invalidateTimer];
    
    if (_autoScroll) {
    
        [self setupTimer];
    
    }

}

- (void)setInfiniteLoop:(BOOL)infiniteLoop {

    _infiniteLoop = infiniteLoop;
    
    if (self.imagePathGroup.count) {
    
        self.imagePathGroup = self.imagePathGroup;
        
    }
    
}

- (void)setDefaultPageControlColor:(UIColor *)defaultPageControlColor {

    _defaultPageControlColor = defaultPageControlColor;
    
    UIPageControl *pageControl = (UIPageControl *)_pageControl;
    pageControl.pageIndicatorTintColor = defaultPageControlColor;
    
}

- (void)setCurrentPageControlColor:(UIColor *)currentPageControlColor {

    _currentPageControlColor = currentPageControlColor;
    
    UIPageControl *pageControl = (UIPageControl *)_pageControl;
    pageControl.currentPageIndicatorTintColor = currentPageControlColor;
    
}

- (void)setShowPageControl:(BOOL)showPageControl {

    _showPageControl = showPageControl;
    
    _pageControl.hidden = !showPageControl;
    
}

- (void)setPageControlSize:(CGSize)pageControlSize {

    _pageControlSize = pageControlSize;
    [self configerPageControl];
    
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {

    _placeholderImage = placeholderImage;
    
    if (!self.backgroundImageView) {
        
        UIImageView *bgImageView = [UIImageView new];
        bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self insertSubview:bgImageView belowSubview:self.collectionView];
        self.backgroundImageView = bgImageView;
    
    }
    
    self.backgroundImageView.image = placeholderImage;
    
}

- (void)setDelegate:(id<HQCycleScrollViewDelegate>)delegate {

    _delegate = delegate;
    
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {

    _scrollDirection = scrollDirection;
    
    _flowLayout.scrollDirection = scrollDirection;
    
}

@end
