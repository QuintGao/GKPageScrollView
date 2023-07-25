//
//  GKSmoothMainDisabledViewController.m
//  ObjcExample
//
//  Created by QuintGao on 2021/7/1.
//

#import "GKSmoothMainDisabledViewController.h"
#import <GKPageSmoothView/GKPageSmoothView.h>
#import "GKBaseListViewController.h"
#import "GKSmoothListView.h"

@interface GKSmoothMainDisabledViewController ()<GKPageSmoothViewDataSource, GKSmoothListViewDelegate>

@property (nonatomic, strong) GKPageSmoothView *smoothView;

@property (nonatomic, strong) UIImageView *headerView;

@property (nonatomic, strong) JXCategoryTitleView *titleView;

@end

@implementation GKSmoothMainDisabledViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBarAlpha = 0;
    self.gk_navTitle = @"禁止主页滑动";
    self.gk_navTitleColor = UIColor.whiteColor;
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    
    [self.view addSubview:self.smoothView];
    [self.smoothView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.titleView.contentScrollView = self.smoothView.listCollectionView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.smoothView reloadData];
    });
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        CGRect frame = self.headerView.frame;
//        frame.size.height = ADAPTATIONRATIO * 400 + 100;
//        self.headerView.frame = frame;
//        [self.smoothView refreshHeaderView];
//    });
}

#pragma mark - GKPageSmoothViewDataSource
- (UIView *)headerViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.headerView;
}

- (UIView *)segmentedViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.titleView;
}

- (NSInteger)numberOfListsInSmoothView:(GKPageSmoothView *)smoothView {
    return self.titleView.titles.count;
}

- (id<GKPageSmoothListViewDelegate>)smoothView:(GKPageSmoothView *)smoothView initListAtIndex:(NSInteger)index {
    GKBaseListViewController *list = [[GKBaseListViewController alloc] initWithListType:0];
    list.shouldLoadData = YES;
    return list;
//    GKSmoothListView *list = [[GKSmoothListView alloc] initWithListType:index deleagte:self];
//    [list requestData];
//    return list;
}

#pragma mark - GKSmoothListViewDelegate
- (CGFloat)smoothViewHeaderContainerHeight {
    return self.smoothView.headerContainerHeight;
}

#pragma mark - 懒加载
- (GKPageSmoothView *)smoothView {
    if (!_smoothView) {
        _smoothView = [[GKPageSmoothView alloc] initWithDataSource:self];
        _smoothView.mainScrollDisabled = YES;   // 禁止主页滑动，只允许列表滑动
        _smoothView.listCollectionView.gk_openGestureHandle = YES;
    }
    return _smoothView;
}

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, ADAPTATIONRATIO * 400)];
        _headerView.image = [UIImage imageNamed:@"test"];
    }
    return _headerView;
}

- (JXCategoryTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kBaseSegmentHeight)];
        _titleView.titles = @[@"UITableView", @"UICollectionView", @"UIScrollView"];
    }
    return _titleView;
}

@end
