//
//  GKTestHeaderView.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/10/25.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "GKTestHeaderView.h"

@interface GKTestHeaderView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView  *scrollView;

@property (nonatomic, copy) void(^scrollViewScrollCallback)(UIScrollView *scrollView);

@end

@implementation GKTestHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.scrollView];
        
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.scrollView.contentSize = CGSizeMake(0, 2 * kScreenH);
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.scrollViewScrollCallback ? : self.scrollViewScrollCallback(scrollView);
}

#pragma mark - 懒加载
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor grayColor];
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

@end
