//
//  GKAllRefreshViewController.m
//  ObjcExample
//
//  Created by lcg on 2022/11/30.
//

#import "GKAllRefreshViewController.h"
#import <MJRefresh/MJRefresh.h>


/// bug 复现操作：
/// 1. 首个 tab 列表上拉操作到吸顶状态后继续上拉一段距离
/// 2. 切换到其他 tab 上拉到吸顶状态显示出刷新按钮
/// 3. 点击刷新按钮，子列表刷新
/// 4. 切换回首个 tab 列表，此时下拉会造成列表自动跳转到 offsetY = 0
///
/// 原因：
/// 第二步骤刷新时，会临时将 disableMainScrollInCeil = YES & allowListRefresh = YES 保证子列表可以展示 refreshHeader，
/// 此时 listScrollViewDidScroll 会执行判断条件为 (offsetY <= 0) => (self.isDisableMainScrollInCeil) => (self.isAllowListRefresh && offsetY < 0 && self.isCeilPoint) else 的逻辑，self.isMainCanScroll = YES; 将允许 main 滚动
/// 子列表刷新结束后，重置了 disableMainScrollInCeil = NO & allowListRefresh = NO，所以切换回首 tab 后, 下拉刷新会执行 mainScrollViewDidScroll() 的第 378 行代码，判断上步的 self.isMainCanScroll = YES 从而导致重置子列表的 offset = zero
///
/// 解决办法：
/// 按照 disableMainScrollInCeil 属性的定义，实际上当 disableMainScrollInCeil = YES & 子列表的 offsetY == 0 时，此时是临界状态，是不想主列表滚动的，所以应该将offset判断条件由 < 0 改为 <= 0。
@interface GKAllRefreshViewController ()
@property (nonatomic, strong) UIButton *listRefreshBtn;

@end

@implementation GKAllRefreshViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
    self.listRefreshBtn.frame = CGRectMake(screenWidth - 44 - 15, screenHeight - 44 - 15, 44, 44);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitle = @"AllRefresh";
    self.gk_navLineHidden = YES;
    self.gk_navTitleColor = [UIColor whiteColor];
    
    // 列表添加下拉刷新
    [self.childVCs enumerateObjectsUsingBlock:^(GKBaseListViewController *listVC, NSUInteger idx, BOOL * _Nonnull stop) {
        [listVC addHeaderRefresh];
    }];
    
    __weak __typeof(self) weakSelf = self;
    self.pageScrollView.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) self = weakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefreshDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pageScrollView.mainTableView.mj_header endRefreshing];
            [self.pageScrollView reloadData];
            
            [self.childVCs enumerateObjectsUsingBlock:^(GKBaseListViewController *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj addHeaderRefresh];
            }];
            
            // 取出当前显示的listView
            GKBaseListViewController *currentListVC = self.childVCs[self.segmentView.selectedIndex];
            
            // 模拟下拉刷新
            currentListVC.count = 30;
            [currentListVC reloadData];
        });
    }];
    
    [self.pageScrollView.mainTableView.mj_header beginRefreshing];
}

- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll
{
    self.listRefreshBtn.hidden = isMainCanScroll;
}

- (UIButton *)listRefreshBtn
{
    if (!_listRefreshBtn)
    {
        _listRefreshBtn = [[UIButton alloc] init];
        if (@available(iOS 13.0, *)) {
            [_listRefreshBtn setImage:[UIImage systemImageNamed:@"arrow.clockwise.circle.fill"] forState:UIControlStateNormal];
        }
        [_listRefreshBtn addTarget:self action:@selector(refreshList) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_listRefreshBtn];
        [self.view bringSubviewToFront:_listRefreshBtn];
    }
    
    return _listRefreshBtn;
}

#pragma mark - Action

- (void)refreshList {
    self.pageScrollView.allowListRefresh = YES;
    self.pageScrollView.disableMainScrollInCeil = YES;
    
    GKBaseListViewController *currentListVC = self.childVCs[self.segmentView.selectedIndex];
    [currentListVC refreshWithCompletion:^{
        self.pageScrollView.allowListRefresh = NO;
        self.pageScrollView.disableMainScrollInCeil = NO;
    }];
}

@end
