//
//  GKItemLoadViewController.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/3/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "GKItemLoadViewController.h"
#import "GKPageScrollView.h"
#import <JXCategoryView/JXCategoryView.h>
#import "GKBaseListViewController.h"
#import <MJRefresh/MJRefresh.h>

@interface GKItemLoadViewController ()<GKPageScrollViewDelegate>

@property (nonatomic, strong) GKPageScrollView      *pageScrollView;

@property (nonatomic, strong) UIImageView           *headerView;

@property (nonatomic, strong) UIView                *pageView;
@property (nonatomic, strong) JXCategoryTitleView   *categoryView;
@property (nonatomic, strong) UIScrollView          *scrollView;

@property (nonatomic, strong) NSArray               *titles;
@property (nonatomic, strong) NSMutableArray        *childVCs;

@end

@implementation GKItemLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitleColor = [UIColor whiteColor];
    self.gk_navTitleFont = [UIFont boldSystemFontOfSize:18.0f];
    self.gk_navBackgroundColor = [UIColor clearColor];
    self.gk_navLineHidden = YES;
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    self.gk_navTitle = @"item加载";
    
    [self.view addSubview:self.pageScrollView];
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    __weak __typeof(self) weakSelf = self;
    self.pageScrollView.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) self = weakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pageScrollView.mainTableView.mj_header endRefreshing];
            
            // 此时标题获取成功
            self.categoryView.titles = self.titles;
            [self.categoryView reloadData];
            
            // 根据标题创建控制器并添加到scrollView
            [self.titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GKBaseListViewController *vc = [[GKBaseListViewController alloc] initWithListType:idx];
                
                [self.childVCs addObject:vc];
                
                [self.scrollView addSubview:vc.view];
                vc.view.frame = CGRectMake(idx * kScreenW, 0, kScreenW, kScreenH - kBaseSegmentHeight - kNavBarHeight);
            }];
            self.scrollView.contentSize = CGSizeMake(self.titles.count * kScreenW, 0);
            
            // 刷新
            [self.pageScrollView reloadData];
        });
    }];
    
    [self.pageScrollView.mainTableView.mj_header beginRefreshing];
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

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"TableView", @"CollectionView", @"ScrollView", @"WebView"];
    }
    return _titles;
}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = [UIView new];
        
        [_pageView addSubview:self.categoryView];
        [_pageView addSubview:self.scrollView];
    }
    return _pageView;
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kBaseSegmentHeight)];
        _categoryView.titleFont = [UIFont systemFontOfSize:15.0f];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:15.0f];
        _categoryView.titleColor = [UIColor grayColor];
        _categoryView.titleSelectedColor = [UIColor redColor];
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
        lineView.indicatorHeight = ADAPTATIONRATIO * 4.0f;
        lineView.verticalMargin = ADAPTATIONRATIO * 2.0f;
        _categoryView.indicators = @[lineView];
        
        // 设置关联的scrollView
        _categoryView.contentScrollView = self.scrollView;
        
        UIView  *btmLineView = [UIView new];
        btmLineView.backgroundColor = GKColorRGB(110, 110, 110);
        [_categoryView addSubview:btmLineView];
        [btmLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self->_categoryView);
            make.height.mas_equalTo(ADAPTATIONRATIO * 2.0f);
        }];
    }
    return _categoryView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        CGFloat w = kScreenW;
        CGFloat h = kScreenH - kBaseSegmentHeight - kNavBarHeight;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kBaseSegmentHeight, w, h)];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.gk_openGestureHandle = YES;
    }
    return _scrollView;
}

- (NSMutableArray *)childVCs {
    if (!_childVCs) {
        _childVCs = [NSMutableArray new];
    }
    return _childVCs;
}

@end
