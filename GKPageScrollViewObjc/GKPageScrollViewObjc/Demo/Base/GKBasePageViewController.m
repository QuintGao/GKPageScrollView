//
//  GKBasePageViewController.m
//  GKPageScrollViewDemo
//
//  Created by gaokun on 2018/12/11.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKBasePageViewController.h"

@interface GKBasePageViewController()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView           *headerView;

@property (nonatomic, strong) UIView                *pageView;

@end

@implementation GKBasePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitleColor = [UIColor whiteColor];
    self.gk_navTitleFont = [UIFont boldSystemFontOfSize:18.0f];
    self.gk_navBackgroundColor = [UIColor clearColor];
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    
    [self.view addSubview:self.pageScrollView];
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - GKPageScrollViewDelegate
- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.headerView;
}

- (UIView *)pageViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.pageView;
}

- (NSArray<id<GKPageListViewDelegate>> *)listViewsInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.childVCs;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewWillBeginScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.pageScrollView horizonScrollViewDidEndedScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewDidEndedScroll];
}

#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
    }
    return _pageScrollView;
}

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kBaseHeaderHeight)];
        _headerView.contentMode = UIViewContentModeScaleAspectFill;
        _headerView.clipsToBounds = YES;
        _headerView.image = [UIImage imageNamed:@"test"];
    }
    return _headerView;
}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = [UIView new];
        
        [_pageView addSubview:self.segmentView];
        [_pageView addSubview:self.contentScrollView];
    }
    return _pageView;
}

- (JXCategoryTitleView *)segmentView {
    if (!_segmentView) {
        _segmentView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kBaseSegmentHeight)];
        _segmentView.titles = @[@"动态", @"文章", @"更多"];
        _segmentView.titleFont = [UIFont systemFontOfSize:15.0f];
        _segmentView.titleSelectedFont = [UIFont systemFontOfSize:15.0f];
        _segmentView.titleColor = [UIColor grayColor];
        _segmentView.titleSelectedColor = [UIColor redColor];
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
        lineView.indicatorHeight = ADAPTATIONRATIO * 4.0f;
        lineView.verticalMargin = ADAPTATIONRATIO * 2.0f;
        _segmentView.indicators = @[lineView];
        
        _segmentView.contentScrollView = self.contentScrollView;
        
        UIView  *btmLineView = [UIView new];
        btmLineView.backgroundColor = GKColorRGB(110, 110, 110);
        [_segmentView addSubview:btmLineView];
        [btmLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.segmentView);
            make.height.mas_equalTo(ADAPTATIONRATIO * 2.0f);
        }];
    }
    return _segmentView;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        CGFloat scrollW = kScreenW;
        CGFloat scrollH = kScreenH - kNavBarHeight - kBaseSegmentHeight;
        
        _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kBaseSegmentHeight, scrollW, scrollH)];
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.bounces = NO;
        _contentScrollView.delegate = self;
        
        [self.childVCs enumerateObjectsUsingBlock:^(GKBaseListViewController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addChildViewController:vc];
            [self->_contentScrollView addSubview:vc.view];
            
            vc.view.frame = CGRectMake(idx * scrollW, 0, scrollW, scrollH);
            
            vc.scrollToTop = ^(GKBaseListViewController * _Nonnull listVC, NSIndexPath * _Nonnull indexPath) {
                [self.pageScrollView scrollToCriticalPoint];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [listVC.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
                });
            };
        }];
        _contentScrollView.contentSize = CGSizeMake(scrollW * self.childVCs.count, 0);
    }
    return _contentScrollView;
}

- (NSArray *)childVCs {
    if (!_childVCs) {
        GKBaseListViewController *dynamicVC = [GKBaseListViewController new];
        
        GKBaseListViewController *articleVC = [GKBaseListViewController new];
        
        GKBaseListViewController *moreVC = [GKBaseListViewController new];
        
        _childVCs = @[dynamicVC, articleVC, moreVC];
    }
    return _childVCs;
}

@end
