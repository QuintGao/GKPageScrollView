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
#import "GKTestListScrollView.h"
#import "GKTestListCollectionView.h"
#import "GKTestHeaderView.h"
#import "GKTestListViewController.h"

//#define kTestHeaderHeight (kScreenH - ADAPTATIONRATIO * 400.0f)

#define kTestHeaderHeight (ADAPTATIONRATIO * 400.0f)

@interface GKTestViewController ()<GKPageScrollViewDelegate, UIScrollViewDelegate, GKTestListViewDelegate, GKPageTableViewGestureDelegate, JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) GKTestScrollView      *pageScrollView;

//@property (nonatomic, strong) UIImageView           *headerView;
//@property (nonatomic, strong) UIScrollView          *headerView;
@property (nonatomic, strong) GKTestHeaderView      *headerView;

@property (nonatomic, strong) UIView                *pageView;

@property (nonatomic, strong) JXCategoryTitleView   *segmentView;
@property (nonatomic, strong) UIScrollView          *contentScrollView;
@property (nonatomic, strong) NSMutableArray        *listViews;

@property (nonatomic, strong) JXCategoryListContainerView *containerView;

@property (nonatomic, strong) UIView                *bottomView;

@property (nonatomic, assign) CGFloat               beginOffset;

@property (nonatomic, assign) BOOL                  isAnimation;

@property (nonatomic, assign) BOOL                  isPullDown; // 是否是下拉

@end

@implementation GKTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.pageScrollView];
    
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
//    UIBarButtonItem *topItem = [UIBarButtonItem itemWithTitle:@"吸顶" target:self action:@selector(scrollToCriticalPoint)];
//    UIBarButtonItem *oriItem = [UIBarButtonItem itemWithTitle:@"还原" target:self action:@selector(scrollToOriginalPoint)];
//    self.gk_navRightBarButtonItems = @[topItem, oriItem];
    
    [self.pageScrollView reloadData];
    [self.containerView reloadData];
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
- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.headerView;
}

- (UIView *)pageViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.pageView;
}

- (NSArray<id<GKPageListViewDelegate>> *)listViewsInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.listViews;
}
//- (NSInteger)numberOfListsInPageScrollView:(GKPageScrollView *)pageScrollView {
//    return 2;
//}



#pragma mark - JXCategoryListContainerViewDelegate
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
//    return self.listViews.count;
    return 2;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    GKTestListViewController *listVC = [GKTestListViewController new];
    [self addChildViewController:listVC];
    return listVC;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewWillBeginScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewDidEndedScroll];
}

#pragma mark - GKPageTableViewGestureDelegate
//- (BOOL)pageTableView:(GKPageTableView *)tableView gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    UIScrollView *scrollView = self.headerView;
//
//    if (scrollView.isTracking || scrollView.isDragging) {
//        CGFloat height = scrollView.frame.size.height;
//        CGFloat offsetY = scrollView.contentOffset.y;
//        CGFloat btmDistance = scrollView.contentSize.height - offsetY;
//
//        if (ceilf(offsetY + height) >= ceilf(scrollView.contentSize.height)) {
//            return YES;
//        }else {
//            return NO;
//        }
//    }
//
//    return YES;
//}
//- (BOOL)pageTableView:(GKPageTableView *)tableView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return NO;
//}

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
        _pageScrollView.mainTableView.gestureDelegate = self;
//        _pageScrollView.isLazyLoadList = YES;
    }
    return _pageScrollView;
}

- (GKTestHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[GKTestHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, ADAPTATIONRATIO * 500.0f)];
    }
    return _headerView;
}

- (JXCategoryListContainerView *)containerView {
    if (!_containerView) {
        _containerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_CollectionView delegate:self];
    }
    return _containerView;
}

//- (UIScrollView *)headerView {
//    if (!_headerView) {
//        _headerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH - ADAPTATIONRATIO * 100.0f)];
//        _headerView.backgroundColor = [UIColor redColor];
//        _headerView.contentSize = CGSizeMake(0, 2 * _headerView.frame.size.height);
//        _headerView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }
//    return _headerView;
//}

//- (UIImageView *)headerView {
//    if (!_headerView) {
//        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kTestHeaderHeight)];
//        _headerView.contentMode = UIViewContentModeScaleAspectFill;
//        _headerView.clipsToBounds = YES;
//        _headerView.image = [UIImage imageNamed:@"wb_bg"];
//    }
//    return _headerView;
//}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = [UIView new];
        
        [_pageView addSubview:self.segmentView];
        [_pageView addSubview:self.contentScrollView];
//        [_pageView addSubview:self.containerView];
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
        lineView.indicatorWidth = ADAPTATIONRATIO * 50.0f;
        lineView.indicatorHeight = ADAPTATIONRATIO * 4.0f;
        lineView.indicatorColor = [UIColor redColor];
        lineView.indicatorCornerRadius = 0;
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
        lineView.verticalMargin = ADAPTATIONRATIO * 1.0f;
        _segmentView.indicators = @[lineView];
        
        _segmentView.contentScrollView = self.contentScrollView;
//        _segmentView.listContainer = self.containerView;
        
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
        
        GKTestListView *listScrollView = [[GKTestListView alloc] initWithFrame:CGRectMake(0, 0, scrollW, scrollH)];
        [self.listViews addObject:listScrollView];
        [_contentScrollView addSubview:listScrollView];
        
        GKTestListCollectionView *listCollectionView = [GKTestListCollectionView new];
        listCollectionView.frame = CGRectMake(scrollW, 0, scrollW, scrollH);
        [self.listViews addObject:listCollectionView];
        [_contentScrollView addSubview:listCollectionView];
        
        
//        for (NSInteger i = 0; i < 2; i++) {
//            GKTestListScrollView *listView = [[GKTestListScrollView alloc] initWithFrame:CGRectMake(i * scrollW, 0, scrollW, scrollH)];
//            [self.listViews addObject:listView];
//            [_contentScrollView addSubview:listView];
//        }
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
        CGFloat btmH = GK_SAFEAREA_BTM + ADAPTATIONRATIO * 100.0f;
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH - btmH, kScreenW, btmH)];
        _bottomView.backgroundColor = [UIColor redColor];
    }
    return _bottomView;
}

@end
