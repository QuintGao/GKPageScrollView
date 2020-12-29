//
//  GKTestListScrollView.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/6/16.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "GKTestListScrollView.h"

@interface GKTestListScrollView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView    *contentView;

@property (nonatomic, strong) void(^listScrollViewScrollCallback)(UIScrollView *scrollView);

@end

@implementation GKTestListScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.delegate = self;
        
        [self addSubview:self.contentView];
        
        self.contentView.frame = CGRectMake(0, 0, kScreenW, kScreenH * 2);
        
        self.contentSize = CGSizeMake(0, kScreenH * 2);
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.listScrollViewScrollCallback ? : self.listScrollViewScrollCallback(scrollView);
}

#pragma mark - GKPageListViewDelegate
- (UIScrollView *)listScrollView {
    return self;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.listScrollViewScrollCallback = callback;
}

#pragma mark - 懒加载
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor redColor];
    }
    return _contentView;
}

@end
