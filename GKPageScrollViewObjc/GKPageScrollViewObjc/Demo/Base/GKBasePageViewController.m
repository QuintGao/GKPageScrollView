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
        _segmentView.titles = @[@"TableView", @"CollectionView", @"ScrollView", @"WebView"];
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
            make.left.right.bottom.equalTo(self->_segmentView);
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
        _contentScrollView.gk_openGestureHandle = YES;
        
        [self.childVCs enumerateObjectsUsingBlock:^(GKBaseListViewController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addChildViewController:vc];
            [self->_contentScrollView addSubview:vc.view];
            
            vc.view.frame = CGRectMake(idx * scrollW, 0, scrollW, scrollH);
            
            __weak __typeof(self) weakSelf = self;
            vc.scrollToTop = ^(GKBaseListViewController * _Nonnull listVC, NSIndexPath * _Nonnull indexPath) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self.pageScrollView scrollToCriticalPoint];
            };
        }];
        _contentScrollView.contentSize = CGSizeMake(scrollW * self.childVCs.count, 0);
    }
    return _contentScrollView;
}

- (NSArray *)childVCs {
    if (!_childVCs) {
        GKBaseListViewController *dynamicVC = [[GKBaseListViewController alloc] initWithListType:GKBaseListType_UITableView];
        
        GKBaseListViewController *articleVC = [[GKBaseListViewController alloc] initWithListType:GKBaseListType_UICollectionView];
        
        GKBaseListViewController *moreVC = [[GKBaseListViewController alloc] initWithListType:GKBaseListType_UIScrollView];
        
        GKBaseListViewController *webVC = [[GKBaseListViewController alloc] initWithListType:GKBaseListType_WKWebView];
        
        _childVCs = @[dynamicVC, articleVC, moreVC, webVC];
    }
    return _childVCs;
}

@end
