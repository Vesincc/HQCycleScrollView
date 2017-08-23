//
//  HQCycleScrollViewCell.m
//  HQCycleScrollView
//
//  Created by HanQi on 2017/8/23.
//  Copyright © 2017年 HanQi. All rights reserved.
//

#import "HQCycleScrollViewCell.h"

@implementation HQCycleScrollViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configerView];
        
    }
    return self;
}

- (void)configerView {

    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self.contentView addSubview:imageView];
    
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
    
}

@end
