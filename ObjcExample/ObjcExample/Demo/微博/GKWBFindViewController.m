//
//  GKWBFindViewController.m
//  GKPageScrollViewDemo
//
//  Created by gaokun on 2019/2/22.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKWBFindViewController.h"
#import "GKPageScrollView.h"
#import "GKWBListViewController.h"
#import "JXCategoryView.h"
#import <MJRefresh/MJRefresh.h>

@interface GKWBFindViewController ()<GKPageScrollViewDelegate, JXCategoryViewDelegate, UIScrollViewDelegate, GKViewControllerPopDelegate, GKPageTableViewGestureDelegate>

@property (nonatomic, strong) UIView                    *topView;

@property (nonatomic, strong) GKPageScrollView          *pageScrollView;

@property (nonatomic, strong) UIView                    *headerView;

@property (nonatomic, strong) UIView                    *pageView;
@property (nonatomic, strong) UIButton                  *backBtn;
@property (nonatomic, strong) UIView                    *segmentedView;
@property (nonatomic, strong) UIScrollView              *contentScrollView;

@property (nonatomic, strong) NSArray                   *titles;
@property (nonatomic, strong) NSArray                   *childVCs;

@property (nonatomic, strong) UIBarButtonItem           *backItem;

@property (nonatomic, assign) BOOL                      isMainCanScroll;

@property (nonatomic, assign) BOOL                      shouldPop;

@end

@implementation GKWBFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_popDelegate = self;
    self.shouldPop = YES;
    
    [self.view addSubview:self.pageScrollView];
    [self.view addSubview:self.topView];
    
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(GK_STATUSBAR_HEIGHT);
    }];
    
    __weak __typeof(self) weakSelf = self;
    self.pageScrollView.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) self = weakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pageScrollView.mainTableView.mj_header endRefreshing];
        });
    }];
    
    [self.pageScrollView reloadData];
}

- (void)backAction {
    if (self.isMainCanScroll) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self.pageScrollView scrollToOriginalPoint];
        self.topView.alpha = 0;
    }
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

- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll {
    self.isMainCanScroll = isMainCanScroll;
    
    if (!isMainCanScroll) {
        self.shouldPop = NO;
        self.backBtn.hidden = NO;
        self.gk_systemGestureHandleDisabled = YES;
    }else {
        self.shouldPop = YES;
        self.backBtn.hidden = YES;
        self.gk_systemGestureHandleDisabled = NO;
    }
    
    // topView透明度渐变
    // contentOffsetY GK_STATUSBAR_HEIGHT-64  topView的alpha 0-1
    CGFloat offsetY = scrollView.contentOffset.y;
    
    CGFloat alpha = 0;
    
    if (offsetY <= GK_STATUSBAR_HEIGHT) { // alpha: 0
        alpha = 0;
    }else if (offsetY >= 64) { // alpha: 1
        alpha = 1;
    }else { // alpha: 0-1
        alpha = (offsetY - GK_STATUSBAR_HEIGHT) / (64 - GK_STATUSBAR_HEIGHT);
    }
    
    self.topView.alpha = alpha;
}

#pragma mark - GKPageTableViewGestureDelegate
- (BOOL)pageTableView:(GKPageTableView *)tableView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 禁止UIScrollView左右滑动时，上下左右都可以滑动
    if (otherGestureRecognizer == self.contentScrollView.panGestureRecognizer) {
        return NO;
    }
    return [gestureRecognizer.view isKindOfClass:[UIScrollView class]] && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]];
}

#pragma mark - GKViewControllerPopDelegate
- (void)viewControllerPopScrollEnded:(BOOL)finished {
    NSLog(@"滑动结束");
    
    if (!self.shouldPop) {
        [self backAction];
    }
}

#pragma mark - GKGesturePopHandlerProtocol
- (BOOL)navigationShouldPopOnGesture {
    return self.shouldPop;
}

#pragma mark - 懒加载
- (UIView *)topView {
    if (!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = [UIColor whiteColor];
        _topView.alpha = 0;
        _topView.userInteractionEnabled = NO;
    }
    return _topView;
}

- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
        _pageScrollView.ceilPointHeight = GK_STATUSBAR_HEIGHT;
        _pageScrollView.allowListRefresh = YES;
        _pageScrollView.disableMainScrollInCeil = YES;
        _pageScrollView.mainTableView.gestureDelegate = self;
    }
    return _pageScrollView;
}

- (UIView *)headerView {
    if (!_headerView) {
        UIImage *headerImg = [UIImage imageNamed:@"wb_find"];
    
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenW * headerImg.size.height / headerImg.size.width + GK_STATUSBAR_HEIGHT)];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, GK_STATUSBAR_HEIGHT, kScreenW, kScreenW * headerImg.size.height / headerImg.size.width)];
        imgView.image = headerImg;
        [_headerView addSubview:imgView];
    }
    return _headerView;
}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = [UIView new];
        _pageView.backgroundColor = [UIColor clearColor];
        
        [_pageView addSubview:self.segmentedView];
        [_pageView addSubview:self.contentScrollView];
    }
    return _pageView;
}

- (UIView *)segmentedView {
    if (!_segmentedView) {
        _segmentedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 44.0f)];
        
        JXCategoryTitleView *titleView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(ADAPTATIONRATIO * 100.0f, 0, kScreenW - ADAPTATIONRATIO * 200.0f, 44.0f)];
        titleView.titles = self.titles;
        titleView.titleColor = GKColorGray(157);
        titleView.titleSelectedColor = [UIColor blackColor];
        titleView.titleFont = [UIFont systemFontOfSize:17.0f];
        titleView.titleSelectedFont = [UIFont boldSystemFontOfSize:18.0f];
        [_segmentedView addSubview:titleView];
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.indicatorWidth = ADAPTATIONRATIO * 60.0f;
        lineView.indicatorHeight = ADAPTATIONRATIO * 6.0f;
        lineView.verticalMargin = ADAPTATIONRATIO * 4.0f;
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
        titleView.indicators = @[lineView];
        
        titleView.contentScrollView = self.contentScrollView;
        
        [_segmentedView addSubview:self.backBtn];
        
        UIView *btmLineView = [UIView new];
        btmLineView.backgroundColor = GKColorGray(226.0f);
        [_segmentedView addSubview:btmLineView];
        [btmLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self->_segmentedView);
            make.height.mas_equalTo(0.5f);
        }];
    }
    return _segmentedView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton new];
        [_backBtn setImage:[UIImage gk_imageNamed:@"btn_back_black"] forState:UIControlStateNormal];
        _backBtn.frame = CGRectMake(12, 0, 44, 44);
        _backBtn.hidden = YES;
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        CGFloat scrollW = kScreenW;
        CGFloat scrollH = kScreenH - kNavBarHeight;
        
        _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44.0f, scrollW, scrollH)];
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.bounces = NO;
        _contentScrollView.delegate = self;
        _contentScrollView.gk_openGestureHandle = YES;
        if (@available(iOS 11.0, *)) {
            _contentScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        
        [self.childVCs enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [self addChildViewController:obj];
            [self->_contentScrollView addSubview:obj.view];
            obj.view.frame = CGRectMake(idx * scrollW, 0, scrollW, scrollH);
        }];

        self.contentScrollView.contentSize = CGSizeMake(self.childVCs.count * scrollW, 0);
    }
    return _contentScrollView;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"话题", @"榜单", @"北京", @"超话"];
    }
    return _titles;
}

- (NSArray *)childVCs {
    if (!_childVCs) {
        GKWBListViewController *homeVC = [GKWBListViewController new];
        homeVC.isCanScroll = YES;
        
        GKWBListViewController *wbVC = [GKWBListViewController new];
        wbVC.isCanScroll = YES;
        
        GKWBListViewController *videoVC = [GKWBListViewController new];
        videoVC.isCanScroll = YES;
        
        GKWBListViewController *storyVC = [GKWBListViewController new];
        storyVC.isCanScroll = YES;
        
        _childVCs = @[homeVC, wbVC, videoVC, storyVC];
    }
    return _childVCs;
}

@end
