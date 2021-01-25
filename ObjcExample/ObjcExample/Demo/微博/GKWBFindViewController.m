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
#import <MJRefresh/MJRefresh.h>

#define kThemeColor GKColorRGB(243, 136, 68)

@interface GKWBFindViewController ()<GKPageScrollViewDelegate, JXCategoryViewDelegate, UIScrollViewDelegate, GKViewControllerPopDelegate, GKPageTableViewGestureDelegate>

@property (nonatomic, strong) UIView                        *topView;

@property (nonatomic, strong) GKPageScrollView              *pageScrollView;

@property (nonatomic, strong) UIView                        *headerView;

@property (nonatomic, strong) UIView                        *segmentedView;
@property (nonatomic, strong) UIButton                      *backBtn;
@property (nonatomic, strong) JXCategorySubTitleView        *categoryView;
@property (nonatomic, strong) JXCategoryIndicatorLineView   *lineView;

@property (nonatomic, strong) NSArray                       *titles;
@property (nonatomic, strong) NSArray                       *subtitles;

@property (nonatomic, strong) UIBarButtonItem               *backItem;

@property (nonatomic, assign) BOOL                          isMainCanScroll;

@property (nonatomic, assign) BOOL                          shouldPop;

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
- (BOOL)shouldLazyLoadListInPageScrollView:(GKPageScrollView *)pageScrollView {
    return YES;
}

- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.headerView;
}

- (UIView *)segmentedViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.segmentedView;
}

- (NSInteger)numberOfListsInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.categoryView.titles.count;
}

- (id<GKPageListViewDelegate>)pageScrollView:(GKPageScrollView *)pageScrollView initListAtIndex:(NSInteger)index {
    GKWBListViewController *listVC = [GKWBListViewController new];
    listVC.isCanScroll = YES;
    return listVC;
}

- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll {
    self.isMainCanScroll = isMainCanScroll;
    
    if (!isMainCanScroll) {
        self.shouldPop = NO;
        self.backBtn.hidden = NO;
        self.gk_systemGestureHandleDisabled = YES;
        
        // 到达顶部
        if (self.categoryView.subTitles == nil) return;
        
        self.categoryView.subTitles = nil;
        self.categoryView.titleLabelVerticalOffset = 0;
        self.categoryView.titleFont = [UIFont boldSystemFontOfSize:16];
        self.categoryView.titleSelectedFont = [UIFont boldSystemFontOfSize:18];
        self.lineView.indicatorHeight = 3;
        self.lineView.verticalMargin = 4;
        self.lineView.indicatorWidthIncrement = -8;
        self.categoryView.indicators = @[self.lineView];
        [self reloadCategoryWithHeight:44];
    }else {
        self.shouldPop = YES;
        self.backBtn.hidden = YES;
        self.gk_systemGestureHandleDisabled = NO;
        
        if (self.categoryView.subTitles != nil) return;
        self.categoryView.subTitles = self.subtitles;
        self.categoryView.titleLabelVerticalOffset = -10;
        self.categoryView.titleFont = [UIFont boldSystemFontOfSize:15];
        self.categoryView.titleSelectedFont = [UIFont boldSystemFontOfSize:15];
        self.lineView.indicatorHeight = 16;
        self.lineView.verticalMargin = 8.5;
        self.lineView.indicatorWidthIncrement = 0;
        self.categoryView.indicators = @[self.lineView];
        [self reloadCategoryWithHeight:54];
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

- (void)reloadCategoryWithHeight:(CGFloat)height {
    [UIView animateWithDuration:0.15 animations:^{
        CGRect frame = self.segmentedView.frame;
        frame.size.height = height;
        self.segmentedView.frame = frame;
        [self.pageScrollView refreshSegmentedView];
        
        frame = self.categoryView.frame;
        frame.size.height = height;
        self.categoryView.frame = frame;
        [self.categoryView reloadData];
        [self.categoryView layoutSubviews];
        [self.categoryView gk_refreshIndicatorState];
    }];
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

- (UIView *)segmentedView {
    if (!_segmentedView) {
        _segmentedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 54.0f)];
        
        [_segmentedView addSubview:self.categoryView];
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

- (JXCategorySubTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategorySubTitleView alloc] initWithFrame:CGRectMake(ADAPTATIONRATIO * 60.0f, 0, kScreenW - ADAPTATIONRATIO * 120.0f, 54.0f)];
        _categoryView.titles = self.titles;
        _categoryView.subTitles = self.subtitles;
        _categoryView.titleFont = [UIFont boldSystemFontOfSize:15];
        _categoryView.titleSelectedFont = [UIFont boldSystemFontOfSize:15];
        _categoryView.titleColor = UIColor.blackColor;
        _categoryView.titleSelectedColor = kThemeColor;
        _categoryView.titleLabelVerticalOffset = -10;
        _categoryView.subTitleFont = [UIFont systemFontOfSize:11];
        _categoryView.subTitleSelectedFont = [UIFont systemFontOfSize:11];
        _categoryView.subTitleColor = [UIColor grayColor];
        _categoryView.subTitleSelectedColor = [UIColor whiteColor];
        _categoryView.subTitleWithTitlePositionMargin = 5;
        _categoryView.cellSpacing = 0;
        _categoryView.cellWidthIncrement = 16;
        _categoryView.indicators = @[self.lineView];
        _categoryView.contentScrollView = self.pageScrollView.listContainerView.collectionView;
    }
    return _categoryView;
}

- (JXCategoryIndicatorLineView *)lineView {
    if (!_lineView) {
        _lineView = [[JXCategoryIndicatorLineView alloc] init];
        _lineView.indicatorHeight = 16;
        _lineView.verticalMargin = 8.5;
        _lineView.indicatorWidthIncrement = 0;
        _lineView.lineScrollOffsetX = 0;
        _lineView.indicatorColor = kThemeColor;
        _lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
    }
    return _lineView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton new];
        [_backBtn setImage:[UIImage gk_imageNamed:@"btn_back_black"] forState:UIControlStateNormal];
        _backBtn.frame = CGRectMake(0, 0, 44, 44);
        _backBtn.hidden = YES;
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"热点", @"潮流", @"话题", @"本地", @"直播"];
    }
    return _titles;
}

- (NSArray *)subtitles {
    if (!_subtitles) {
        _subtitles = @[@"热门资讯", @"潮人好物", @"深度讨论", @"同城关注", @"大V在线"];
    }
    return _subtitles;
}

@end
