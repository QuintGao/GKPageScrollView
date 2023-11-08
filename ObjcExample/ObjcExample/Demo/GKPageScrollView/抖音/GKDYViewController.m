//
//  GKDYViewController.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYViewController.h"
#import "GKDYListViewController.h"
#import "GKDYHeaderView.h"
#import "JXCategoryView.h"

@interface GKDYViewController ()<GKPageScrollViewDelegate, JXCategoryViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) GKPageScrollView      *pageScrollView;

@property (nonatomic, strong) GKDYHeaderView        *headerView;

@property (nonatomic, strong) JXCategoryTitleView   *categoryView;

@property (nonatomic, strong) NSArray               *titles;

@property (nonatomic, strong) UILabel               *titleView;

@end

@implementation GKDYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBarAlpha = 0;
    self.gk_navBackgroundColor = GKColorRGB(34, 33, 37);
    self.gk_navTitleView = self.titleView;
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    self.gk_navLineHidden = YES;
    
    [self.view addSubview:self.pageScrollView];
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.pageScrollView reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect frame = self.headerView.frame;
    frame.size.width = self.view.frame.size.width;
    self.headerView.frame = frame;
    
    frame = self.categoryView.frame;
    if (frame.size.width != self.view.frame.size.width) {
        frame.size.width = self.view.frame.size.width;
        self.categoryView.frame = frame;
        [self.categoryView reloadData];
    }
}

#pragma mark - GKPageScrollViewDelegate
- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.headerView;
}

- (UIView *)segmentedViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.categoryView;
}

- (NSInteger)numberOfListsInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.titles.count;
}

- (id<GKPageListViewDelegate>)pageScrollView:(GKPageScrollView *)pageScrollView initListAtIndex:(NSInteger)index {
    GKDYListViewController *listVC = [[GKDYListViewController alloc] init];
    listVC.index = index;
    return listVC;
}

//- (UIView *)pageViewInPageScrollView:(GKPageScrollView *)pageScrollView {
//    return self.pageView;
//}
//
//- (NSArray<id<GKPageListViewDelegate>> *)listViewsInPageScrollView:(GKPageScrollView *)pageScrollView {
//    return self.childVCs;
//}

- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll {
    NSLog(@"%d", isMainCanScroll);
    // 导航栏显隐
    CGFloat offsetY = scrollView.contentOffset.y;
    // 0-200 0
    // 200 - KDYHeaderHeigh - kNavBarheight 渐变从0-1
    // > KDYHeaderHeigh - kNavBarheight 1
    CGFloat alpha = 0;
    if (offsetY < 200) {
        alpha = 0;
    }else if (offsetY > (kDYHeaderHeight - kNavBarHeight)) {
        alpha = 1;
    }else {
        alpha = (offsetY - 200) / (kDYHeaderHeight - kNavBarHeight - 200);
    }
    self.gk_navBarAlpha = alpha;
    self.titleView.alpha = alpha;

    [self.headerView scrollViewDidScroll:offsetY];
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    NSLog(@"刷新数据");
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewWillBeginScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewDidEndedScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.pageScrollView horizonScrollViewDidEndedScroll];
}

#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
//        _pageScrollView.listContainerType = GKPageListContainerType_ScrollView;
        _pageScrollView.lazyLoadList = YES;
    }
    return _pageScrollView;
}

- (GKDYHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[GKDYHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kDYHeaderHeight)];
    }
    return _headerView;
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40.0f)];
        _categoryView.backgroundColor = GKColorRGB(34, 33, 37);
        _categoryView.titles = self.titles;
        _categoryView.delegate = self;
        _categoryView.titleColor = [UIColor grayColor];
        _categoryView.titleSelectedColor = [UIColor whiteColor];
        _categoryView.titleFont = [UIFont systemFontOfSize:16.0f];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:16.0f];
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorColor = [UIColor yellowColor];
        lineView.indicatorWidth = 80.0f;
        lineView.indicatorCornerRadius = 0;
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
        _categoryView.indicators = @[lineView];
        _categoryView.defaultSelectedIndex = 1;
        
        _categoryView.listContainer = (id<JXCategoryViewListContainer>)self.pageScrollView.listContainerView;
        
        // 添加分割线
        UIView *btmLineView = [UIView new];
        btmLineView.backgroundColor = GKColorGray(200);
        [_categoryView addSubview:btmLineView];
        
        [btmLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self->_categoryView);
            make.height.mas_equalTo(0.5);
        }];
    }
    return _categoryView;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"作品 129", @"动态 129", @"喜欢 591"];
    }
    return _titles;
}

- (UILabel *)titleView {
    if (!_titleView) {
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
        _titleView.font = [UIFont systemFontOfSize:18.0f];
        _titleView.textColor = [UIColor whiteColor];
        _titleView.text = @"❤️会说话的刘二豆❤️";
        _titleView.alpha = 0;
    }
    return _titleView;
}

@end
