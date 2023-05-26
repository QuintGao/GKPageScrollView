//
//  GKChangeHeaderViewController.m
//  ObjcExample
//
//  Created by QuintGao on 2022/9/1.
//

#import "GKChangeHeaderViewController.h"
#import <GKPageScrollView/GKPageScrollView.h>
#import <JXCategoryViewExt/JXCategoryView.h>
#import "GKBaseListViewController.h"

@interface GKChangeHeaderViewController ()<GKPageScrollViewDelegate>

@property (nonatomic, strong) GKPageScrollView *pageScrollView;

@property (nonatomic, strong) UIImageView *headerView;

@property (nonatomic, strong) JXCategoryTitleView *titleView;

@end

@implementation GKChangeHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBarAlpha = 0;
    self.gk_navTitle = @"修改header高度";
    self.gk_navTitleColor = UIColor.whiteColor;
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    UIBarButtonItem *oriItem = [UIBarButtonItem gk_itemWithTitle:@"原点" target:self action:@selector(oriAction)];
    UIBarButtonItem *criItem = [UIBarButtonItem gk_itemWithTitle:@"临界点" target:self action:@selector(criAction)];
    self.gk_navRightBarButtonItems = @[oriItem, criItem];
    
    [self.view addSubview:self.pageScrollView];
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.titleView.listContainer = (id<JXCategoryViewListContainer>)self.pageScrollView.listContainerView;
    [self.pageScrollView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.headerView.frame = CGRectMake(0, 0, kScreenW, ADAPTATIONRATIO * 600);
        [self.pageScrollView refreshHeaderView];
    });
}

- (void)oriAction {
    [self.pageScrollView scrollToOriginalPointAnimated:NO];
//    self.isAnimation = YES;
}

- (void)criAction {
    [self.pageScrollView scrollToCriticalPointAnimated:NO];
//    self.isAnimation = YES;
}

#pragma mark - GKPageScrollViewDelegate
- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.headerView;
}

- (UIView *)segmentedViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.titleView;
}

- (NSInteger)numberOfListsInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.titleView.titles.count;
}

- (id<GKPageListViewDelegate>)pageScrollView:(GKPageScrollView *)pageScrollView initListAtIndex:(NSInteger)index {
    GKBaseListViewController *listVC = [[GKBaseListViewController alloc] initWithListType:index];
    listVC.count = 5;
    listVC.disableLoadMore = YES;
//    listVC.shouldLoadData = YES;
    return listVC;
}

#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
        _pageScrollView.lazyLoadList = YES;
        _pageScrollView.keepCriticalWhenRefreshHeader = YES;
    }
    return _pageScrollView;
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
