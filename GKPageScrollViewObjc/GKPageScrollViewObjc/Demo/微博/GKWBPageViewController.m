//
//  GKWBPageViewController.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/27.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKWBPageViewController.h"

@interface GKWBPageViewController ()

@end

@implementation GKWBPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.menuView) {
        [self.menuView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.menuView);
            make.height.mas_equalTo(0.5f);
        }];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    
    if ([self.scrollDelegate respondsToSelector:@selector(pageScrollViewWillBeginScroll)]) {
        [self.scrollDelegate pageScrollViewWillBeginScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [super scrollViewDidEndDecelerating:scrollView];
    
    if ([self.scrollDelegate respondsToSelector:@selector(pageScrollViewDidEndedScroll)]) {
        [self.scrollDelegate pageScrollViewDidEndedScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    if ([self.scrollDelegate respondsToSelector:@selector(pageScrollViewDidEndedScroll)]) {
        [self.scrollDelegate pageScrollViewDidEndedScroll];
    }
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor grayColor];
    }
    return _lineView;
}

@end
