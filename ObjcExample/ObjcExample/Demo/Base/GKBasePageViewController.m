//
//  GKBasePageViewController.m
//  GKPageScrollViewDemo
//
//  Created by QuintGao on 2018/12/11.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKBasePageViewController.h"

@interface GKBasePageViewController()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView           *headerView;

@property (nonatomic, strong) UIView                *pageView;

@property (nonatomic, strong) JXCategoryTitleView   *segmentedView;

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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect frame = self.headerView.frame;
    frame.size.width = self.view.frame.size.width;
    self.headerView.frame = frame;
    
    frame = self.segmentView.frame;
    if (frame.size.width != self.view.frame.size.width) {
        frame.size.width = self.view.frame.size.width;
        [self.segmentView reloadData];
    }
    
    [self.childVCs enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.view.frame = CGRectMake(self.view.frame.size.width * idx, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    self.scrollView.contentSize = CGSizeMake(self.childVCs.count * self.view.frame.size.width, 0);
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
        _pageScrollView.showInFooter = YES;
    }
    return _pageScrollView;
}

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kBaseHeaderHeight)];
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
        [_pageView addSubview:self.scrollView];
        
        [self.segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self->_pageView);
            make.height.mas_equalTo(kBaseSegmentHeight);
        }];
        
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self->_pageView);
            make.top.equalTo(self.segmentView.mas_bottom);
        }];
    }
    return _pageView;
}

- (JXCategoryTitleView *)segmentView {
    if (!_segmentView) {
        _segmentView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kBaseSegmentHeight)];
        _segmentView.titles = @[@"TableView", @"CollectionView", @"ScrollView", @"WebView"];
        _segmentView.titleFont = [UIFont systemFontOfSize:15.0f];
        _segmentView.titleSelectedFont = [UIFont systemFontOfSize:15.0f];
        _segmentView.titleColor = [UIColor grayColor];
        _segmentView.titleSelectedColor = [UIColor redColor];
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
        lineView.indicatorHeight = 4.0f;
        lineView.verticalMargin = 2;
        _segmentView.indicators = @[lineView];
        
        _segmentView.contentScrollView = self.scrollView;
        
        UIView  *btmLineView = [UIView new];
        btmLineView.backgroundColor = GKColorRGB(110, 110, 110);
        [_segmentView addSubview:btmLineView];
        [btmLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self->_segmentView);
            make.height.mas_equalTo(1);
        }];
    }
    return _segmentView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        CGFloat scrollW = self.view.frame.size.width;
        CGFloat scrollH = self.view.frame.size.height - kNavBarHeight - kBaseSegmentHeight;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kBaseSegmentHeight, scrollW, scrollH)];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.gk_openGestureHandle = YES;
        
        [self.childVCs enumerateObjectsUsingBlock:^(GKBaseListViewController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addChildViewController:vc];
            [self->_scrollView addSubview:vc.view];
            
            vc.view.frame = CGRectMake(idx * scrollW, 0, scrollW, scrollH);
            
            __weak __typeof(self) weakSelf = self;
            vc.listItemClick = ^(GKBaseListViewController * _Nonnull listVC, NSIndexPath * _Nonnull indexPath) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self.pageScrollView scrollToCriticalPoint];
            };
        }];
        _scrollView.contentSize = CGSizeMake(scrollW * self.childVCs.count, 0);
    }
    return _scrollView;
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
