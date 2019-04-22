//
//  GKTestViewController.m
//  GKPageScrollViewDemo
//
//  Created by gaokun on 2018/12/6.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKTestViewController.h"
#import "GKTestScrollView.h"
#import "GKTestListView.h"
#import "JXCategoryView.h"
#import <MJRefresh/MJRefresh.h>

//#define kTestHeaderHeight (kScreenH - ADAPTATIONRATIO * 400.0f)

#define kTestHeaderHeight (ADAPTATIONRATIO * 400.0f)

@interface GKTestViewController ()<GKPageScrollViewDelegate, UIScrollViewDelegate, GKTestListViewDelegate>

@property (nonatomic, strong) GKTestScrollView      *pageScrollView;

@property (nonatomic, strong) UIImageView           *headerView;

@property (nonatomic, strong) UIView                *pageView;

@property (nonatomic, strong) JXCategoryTitleView   *segmentView;
@property (nonatomic, strong) UIScrollView          *contentScrollView;
@property (nonatomic, strong) NSMutableArray        *listViews;

@property (nonatomic, strong) UIView                *bottomView;

@property (nonatomic, assign) CGFloat               beginOffset;

@property (nonatomic, assign) BOOL                  isAnimation;

@property (nonatomic, assign) BOOL                  isPullDown; // 是否是下拉

@property (nonatomic, strong) UISwipeGestureRecognizer    *upSwipeGesture;
@property (nonatomic, strong) UISwipeGestureRecognizer    *downSwipeGesture;

@end

@implementation GKTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.pageScrollView];
//    [self.view addSubview:self.bottomView];
    
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIBarButtonItem *topItem = [UIBarButtonItem itemWithTitle:@"吸顶" target:self action:@selector(scrollToCriticalPoint)];
    UIBarButtonItem *oriItem = [UIBarButtonItem itemWithTitle:@"还原" target:self action:@selector(scrollToOriginalPoint)];
    self.gk_navRightBarButtonItems = @[topItem, oriItem];
    
//    self.upSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
//    self.upSwipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
//    [self.pageScrollView.mainTableView addGestureRecognizer:self.upSwipeGesture];
//
//    self.downSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
//    self.downSwipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
//    [self.pageScrollView.mainTableView addGestureRecognizer:self.downSwipeGesture];
    
//    self.pageScrollView.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        GKTestListView *listView = self.listViews[self.segmentView.selectedIndex];
//        
//        [listView setCount:20];
//        
//        [self.pageScrollView.mainTableView.mj_header endRefreshing];
//    }];
    
    [self.pageScrollView reloadData];
}

- (void)swipeAction:(UISwipeGestureRecognizer *)gesture {
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        [self.pageScrollView scrollToCriticalPoint];
    }else if (gesture.direction == UISwipeGestureRecognizerDirectionDown) {
        [self.pageScrollView scrollToOriginalPoint];
    }
}

- (void)scrollToCriticalPoint {
    [self.pageScrollView scrollToCriticalPoint];
}

- (void)scrollToOriginalPoint {
    [self.pageScrollView scrollToOriginalPoint];
}

#pragma mark - GKPageScrollViewDelegate
- (BOOL)shouldLazyLoadListInPageScrollView:(GKPageScrollView *)pageScrollView {
    return NO;
}

- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.headerView;
}

- (UIView *)pageViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.pageView;
}

- (NSArray<id<GKPageListViewDelegate>> *)listViewsInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.listViews;
}

- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll {
//    NSLog(@"%@", isMainCanScroll ? @"main可滑动" : @"main不可滑动");
//    NSLog(@"%f", scrollView.contentOffset.y);
}

- (void)mainTableViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"main开始滑动");
    self.beginOffset = scrollView.contentOffset.y;
}

- (void)mainTableViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"main结束滑动");
//    if (scrollView.contentOffset.y >= self.beginOffset) {
//        if (scrollView.contentOffset.y == self.beginOffset && self.beginOffset == 0) return;
//        [self bottomHide];
//    }else {
//        [self bottomShow];
//    }
}

- (void)mainTableViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    if (!decelerate) {
//        NSLog(@"main无减速滑动");
//        if (scrollView.contentOffset.y >= self.beginOffset) {
//            if (scrollView.contentOffset.y == self.beginOffset && self.beginOffset == 0) return;
//            [self bottomHide];
//        }else {
//            [self bottomShow];
//        }
//    }
//    CGFloat offsetY = scrollView.contentOffset.y;
//
//    if (decelerate) {
//        if (offsetY > self.beginOffset) {   // 上滑减速，滑动到临界点
////            [self.pageScrollView scrollToCriticalPoint];
//            CGFloat criticalPoint = [self.pageScrollView.mainTableView rectForSection:0].origin.y - self.pageScrollView.ceilPointHeight;
//            [UIView animateWithDuration:0.25 animations:^{
//                self.pageScrollView.mainTableView.contentOffset = CGPointMake(0, criticalPoint);
//            }];
//
//        }else { // 下滑减速，滑动到原点
////            [self.pageScrollView scrollToOriginalPoint];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                self.pageScrollView.mainTableView.bounces = NO;
//                [UIView animateWithDuration:0.25 animations:^{
//                    self.pageScrollView.mainTableView.contentOffset = CGPointZero;
//                } completion:^(BOOL finished) {
//                    self.pageScrollView.mainTableView.bounces = YES;
//                }];
//            });
//        }
//    }else {
//        if (offsetY >= kTestHeaderHeight * 0.5) {    // 结束滑动，大于140，滑动到临界点
//            [self.pageScrollView scrollToCriticalPoint];
//        }else { // 结束滑动，小于140，回到原点
//            [self.pageScrollView scrollToOriginalPoint];
//        }
//    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewWillBeginScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewDidEndedScroll];
}

#pragma mark - GKTestListViewDelegate
- (void)bottomHide {
    if (self.isAnimation) return;
    self.isAnimation = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.bottomView.frame;
        f.origin.y = kScreenH;
        self.bottomView.frame = f;
    }completion:^(BOOL finished) {
        self.bottomView.hidden = YES;
        self.isAnimation = NO;
    }];
}

- (void)bottomShow {
    self.bottomView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.bottomView.frame;
        f.origin.y = kScreenH - f.size.height;
        self.bottomView.frame = f;
    }];
}

- (void)listLoadData {
    [self.pageScrollView.mainTableView.mj_header beginRefreshing];
}

#pragma mark - 懒加载
- (GKTestScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKTestScrollView alloc] initWithDelegate:self];
        _pageScrollView.mainTableView.backgroundColor = [UIColor clearColor];
//        _pageScrollView.mainTableView.bounces = NO;
//        _pageScrollView.ceilPointHeight = -(GK_NAVBAR_HEIGHT + ADAPTATIONRATIO * 100.0f);
    }
    return _pageScrollView;
}

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kTestHeaderHeight)];
        _headerView.contentMode = UIViewContentModeScaleAspectFill;
        _headerView.clipsToBounds = YES;
        _headerView.image = [UIImage imageNamed:@"wb_bg"];
    }
    return _headerView;
}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = [UIView new];
        
        [_pageView addSubview:self.segmentView];
        [_pageView addSubview:self.contentScrollView];
    }
    return _pageView;
}

- (JXCategoryTitleView *)segmentView {
    if (!_segmentView) {
        _segmentView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, ADAPTATIONRATIO * 100.0f)];
        _segmentView.titles = @[@"详情", @"声音"];
        _segmentView.titleFont = [UIFont systemFontOfSize:15.0f];
        _segmentView.titleSelectedFont = [UIFont boldSystemFontOfSize:15.0f];
        _segmentView.titleColor = [UIColor blackColor];
        _segmentView.titleSelectedColor = [UIColor redColor];
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.indicatorLineWidth = ADAPTATIONRATIO * 50.0f;
        lineView.indicatorLineViewHeight = ADAPTATIONRATIO * 4.0f;
        lineView.indicatorLineViewColor = [UIColor redColor];
        lineView.indicatorLineViewCornerRadius = 0;
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
        lineView.verticalMargin = ADAPTATIONRATIO * 1.0f;
        _segmentView.indicators = @[lineView];
        
        _segmentView.contentScrollView = self.contentScrollView;
        
        UIView *btmLineView = [UIView new];
        btmLineView.backgroundColor = [UIColor grayColor];
        [_segmentView addSubview:btmLineView];
        [btmLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.segmentView);
            make.height.mas_equalTo(ADAPTATIONRATIO * 1.0f);
        }];
    }
    return _segmentView;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        CGFloat scrollW = kScreenW;
        CGFloat scrollH = kScreenH - kNavBarHeight - ADAPTATIONRATIO * 100.0f;
        
        _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, ADAPTATIONRATIO * 100.0f, scrollW, scrollH)];
        _contentScrollView.delegate = self;
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.bounces = NO;
        
        for (NSInteger i = 0; i < 2; i++) {
            GKTestListView *listView = [[GKTestListView alloc] initWithFrame:CGRectMake(i * scrollW, 0, scrollW, scrollH)];
            listView.delegate = self;
            [self.listViews addObject:listView];
            [_contentScrollView addSubview:listView];
        }
        _contentScrollView.contentSize = CGSizeMake(2 * scrollW, 0);
    }
    return _contentScrollView;
}

- (NSMutableArray *)listViews {
    if (!_listViews) {
        _listViews = [NSMutableArray new];
    }
    return _listViews;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        CGFloat btmH = GK_SAVEAREA_BTM + ADAPTATIONRATIO * 100.0f;
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH - btmH, kScreenW, btmH)];
        _bottomView.backgroundColor = [UIColor redColor];
    }
    return _bottomView;
}

@end
