//
//  GKPinLocationViewController.m
//  ObjcExample
//
//  Created by gaokun on 2021/2/5.
//

#import "GKPinLocationViewController.h"
#import "JXCategoryPinTitleView.h"
#import <GKPageSmoothView/GKPageSmoothView.h>
#import "GKPinLocationView.h"

@interface GKPinLocationViewController ()<GKPageSmoothViewDataSource, GKPageSmoothViewDelegate, JXCategoryViewDelegate>

@property (nonatomic, strong) GKPageSmoothView *smoothView;

@property (nonatomic, strong) UIImageView *headerView;

@property (nonatomic, strong) JXCategoryPinTitleView *titleView;

@end

@implementation GKPinLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitle = @"上下滑动切换tab";
    self.gk_navLineHidden = YES;
    self.gk_navTitleColor = [UIColor whiteColor];
    self.gk_navTitleFont = [UIFont boldSystemFontOfSize:18.0f];
    self.gk_navBackgroundColor = [UIColor clearColor];
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    UIBarButtonItem *oriItem = [UIBarButtonItem gk_itemWithTitle:@"原点" target:self action:@selector(oriAction)];
    UIBarButtonItem *criItem = [UIBarButtonItem gk_itemWithTitle:@"临界点" target:self action:@selector(criAction)];
    self.gk_navRightBarButtonItems = @[oriItem, criItem];
    
    [self.view addSubview:self.smoothView];
    [self.smoothView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.smoothView reloadData];
}

- (void)oriAction {
    [self.smoothView scrollToOriginalPoint];
}

- (void)criAction {
    [self.smoothView scrollToCriticalPoint];
}

#pragma mark - GKPageSmoothViewDataSource
- (UIView *)headerViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.headerView;
}

- (UIView *)segmentedViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.titleView;
}

- (NSInteger)numberOfListsInSmoothView:(GKPageSmoothView *)smoothView {
    return 1;
}

- (id<GKPageSmoothListViewDelegate>)smoothView:(GKPageSmoothView *)smoothView initListAtIndex:(NSInteger)index {
    GKPinLocationView *listView = [[GKPinLocationView alloc] init];
    
    NSMutableArray *data = [NSMutableArray new];
    NSArray *counts = @[@(6), @(8), @(9), @(5), @(7), @(10), @(13), @(6), @(8)];
    for (int i = 0; i < self.titleView.titles.count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        dic[@"title"] = self.titleView.titles[i];
        dic[@"count"] = counts[i];
        [data addObject:dic];
    }
    listView.data = data;
    return listView;
}

#pragma mark - GKPageSmoothViewDelegate
- (void)smoothView:(GKPageSmoothView *)smoothView listScrollViewDidScroll:(UIScrollView *)scrollView contentOffset:(CGPoint)contentOffset {
    if (!(scrollView.isTracking || scrollView.isDecelerating)) return;
    
    //用户滚动的才处理
    //获取categoryView下面一点的所有布局信息，用于知道，当前最上方是显示的哪个section
    CGFloat categoryH = self.titleView.frame.size.height;
    
    UITableView *tableView = (UITableView *)scrollView;
    NSArray <NSIndexPath *> *topIndexPaths = [tableView indexPathsForRowsInRect:CGRectMake(0, contentOffset.y + categoryH - self.headerView.frame.size.height + 40 + 10, tableView.frame.size.width, 200)];
    
    NSIndexPath *topIndexPath = topIndexPaths.firstObject;
    NSUInteger topSection = topIndexPath.section;
    if (topIndexPath != nil) {
        if (self.titleView.selectedIndex != topSection) {
            [self.titleView selectItemAtIndex:topSection];
        }
    }
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index {
    UITableView *tableView = (UITableView *)self.smoothView.currentListScrollView;
    CGRect frame = [tableView rectForHeaderInSection:index];
    [tableView setContentOffset:CGPointMake(0, frame.origin.y - kBaseHeaderHeight + kBaseSegmentHeight + 40) animated:YES];
}

#pragma mark - 懒加载
- (GKPageSmoothView *)smoothView {
    if (!_smoothView) {
        _smoothView = [[GKPageSmoothView alloc] initWithDataSource:self];
        _smoothView.ceilPointHeight = GK_STATUSBAR_NAVBAR_HEIGHT;
        _smoothView.delegate = self;
    }
    return _smoothView;
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

- (JXCategoryPinTitleView *)titleView {
    if (!_titleView) {
        _titleView = [JXCategoryPinTitleView new];
        _titleView.backgroundColor = UIColor.whiteColor;
        _titleView.frame = CGRectMake(0, 0, kScreenW, kBaseSegmentHeight);
        _titleView.titles = @[@"年货市集", @"新年换新", @"安心过年", @"爆品专区", @"尝鲜专区", @"贺岁大餐", @"超值外卖", @"玩乐特惠", @"商超年货"];
        _titleView.pinImage = [UIImage gk_changeImage:[UIImage imageNamed:@"location"] color:UIColor.redColor];
        _titleView.titleColor = UIColor.grayColor;
        _titleView.titleSelectedColor = UIColor.redColor;
        _titleView.titleFont = [UIFont systemFontOfSize:15];
        _titleView.delegate = self;
    }
    return _titleView;
}

@end
