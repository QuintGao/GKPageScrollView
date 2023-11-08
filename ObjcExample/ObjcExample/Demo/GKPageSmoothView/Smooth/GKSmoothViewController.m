//
//  GKSmoothViewController.m
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2020/5/8.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKSmoothViewController.h"
#import "GKPageSmoothView.h"
#import "GKSmoothListView.h"
#import "GKDYHeaderView.h"
#import "GKBaseListViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "GKSmoothListViewController.h"
#import "GKBaseListViewController.h"

@interface GKSmoothViewController ()<GKPageSmoothViewDataSource, GKPageSmoothViewDelegate, GKSmoothListViewDelegate, GKSmoothListViewControllerDelegate>

@property (nonatomic, strong) GKPageSmoothView  *smoothView;

//@property (nonatomic, strong) UIImageView       *headerView;
@property (nonatomic, strong) GKDYHeaderView    *headerView;

@property (nonatomic, strong) JXCategoryTitleView *categoryView;

@end

@implementation GKSmoothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitle = @"滑动延续";
    self.gk_navTitleColor = UIColor.whiteColor;
    self.gk_navBarAlpha = 0.0f;
    self.gk_navBackgroundColor = GKColorRGB(34, 33, 37);
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    
    [self.view addSubview:self.smoothView];
    [self.smoothView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.categoryView.contentScrollView = self.smoothView.listCollectionView;
    
    // 模拟网络请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect frame = self.headerView.frame;
        frame.size.height = 800;
        self.headerView.frame = frame;
        
        self.categoryView.contentScrollView = self.smoothView.listCollectionView;
        [self.smoothView refreshHeaderView];
        [self.smoothView reloadData];
    });
}

- (void)dealloc {
    [self.smoothView.listDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, id<GKPageSmoothListViewDelegate>  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:GKSmoothListView.class]) {
            [(GKSmoothListView *)obj stopLoading];
        }
    }];
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

#pragma mark - GKPageSmoothViewDataSource
- (UIView *)headerViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.headerView;
}

- (UIView *)segmentedViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.categoryView;
}

- (NSInteger)numberOfListsInSmoothView:(GKPageSmoothView *)smoothView {
    return self.categoryView.titles.count;
}

- (id<GKPageSmoothListViewDelegate>)smoothView:(GKPageSmoothView *)smoothView initListAtIndex:(NSInteger)index {
//    GKSmoothListView *listView = [[GKSmoothListView alloc] initWithListType:GKSmoothListType_TableView deleagte:self index:index];
//    [listView requestData];
//    return listView;
//    GKSmoothListViewController *listVC = [GKSmoothListViewController new];
//    listVC.delegate = self;
//    listVC.index = index;
//    return listVC;
    GKBaseListViewController *listVC = [[GKBaseListViewController alloc] initWithListType:index];
    listVC.shouldLoadData = YES;
    listVC.index = index;
    return listVC;
}

#pragma mark - GKPageSmoothViewDelegate
- (void)smoothView:(GKPageSmoothView *)smoothView listScrollViewDidScroll:(UIScrollView *)scrollView contentOffset:(CGPoint)contentOffset {
    CGFloat offsetY = contentOffset.y;
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
//    
//    [self.headerView scrollViewDidScroll:offsetY];
}

#pragma mark - GKSmoothListViewDelegate
- (CGFloat)smoothViewHeaderContainerHeight {
    return self.smoothView.headerContainerHeight;
}

#pragma mark - 懒加载
- (GKPageSmoothView *)smoothView {
    if (!_smoothView) {
        _smoothView = [[GKPageSmoothView alloc] initWithDataSource:self];
        _smoothView.ceilPointHeight = GK_STATUSBAR_NAVBAR_HEIGHT;
        _smoothView.delegate = self;
        _smoothView.listCollectionView.gk_openGestureHandle = YES;
//        _smoothView.mainScrollDisabled = YES;
//        _smoothView.holdUpScrollView = YES;
//        _smoothView.listCollectionView.bounces = YES;
        _smoothView.defaultSelectedIndex = 1;
    }
    return _smoothView;
}

- (GKDYHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[GKDYHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 500)];
    }
    return _headerView;
}

//- (UIImageView *)headerView {
//    if (!_headerView) {
//        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kBaseHeaderHeight)];
//        _headerView.contentMode = UIViewContentModeScaleAspectFill;
//        _headerView.clipsToBounds = YES;
//        _headerView.image = [UIImage imageNamed:@"test"];
//    }
//    return _headerView;
//}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kBaseSegmentHeight)];
        _categoryView.titles = @[@"UITableView", @"UICollectionView", @"UIScrollView"];
        _categoryView.backgroundColor = [UIColor whiteColor];
        _categoryView.titleFont = [UIFont systemFontOfSize:14.0f];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:16.0f];
        _categoryView.titleColor = [UIColor blackColor];
        _categoryView.titleSelectedColor = [UIColor blackColor];
        _categoryView.titleLabelZoomEnabled = YES;
        _categoryView.contentScrollViewClickTransitionAnimationEnabled = NO;
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
        _categoryView.indicators = @[lineView];
        _categoryView.defaultSelectedIndex = 1;
        
//        _categoryView.contentScrollView = self.smoothView.listCollectionView;
    }
    return _categoryView;
}

@end
