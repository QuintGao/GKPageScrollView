//
//  GKHeaderScrollViewController.m
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2019/5/31.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKHeaderScrollViewController.h"
#import "GKHeaderScrollView.h"
#import "GKPageScrollView.h"
#import <MJRefresh/MJRefresh.h>
#import "GKBaseListViewController.h"

@interface GKHeaderScrollViewController()<GKPageScrollViewDelegate, GKPageTableViewGestureDelegate>

@property (nonatomic, strong) GKPageScrollView      *pageScrollView;

@property (nonatomic, strong) GKHeaderScrollView    *headerView;

@property (nonatomic, strong) UIView                *pageView;
@property (nonatomic, strong) JXCategoryTitleView   *categoryView;
@property (nonatomic, strong) UIScrollView          *scrollView;

@property (nonatomic, strong) NSArray               *titles;
@property (nonatomic, strong) NSMutableArray        *childVCs;

@end

@implementation GKHeaderScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitleColor = [UIColor blackColor];
    self.gk_navTitleFont = [UIFont boldSystemFontOfSize:18.0f];
    self.gk_navBackgroundColor = [UIColor whiteColor];
    self.gk_statusBarStyle = UIStatusBarStyleDefault;
    self.gk_backStyle = GKNavigationBarBackStyleBlack;
    self.gk_navTitle = @"headerScroll";
    
    [self.view addSubview:self.pageScrollView];
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(GK_STATUSBAR_NAVBAR_HEIGHT, 0, 0, 0));
    }];
    
    self.categoryView.titles = self.titles;
    [self.categoryView reloadData];
    
    // 根据标题创建控制器并添加到scrollView
    [self.titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKBaseListViewController *vc = [GKBaseListViewController new];
        
        [self.childVCs addObject:vc];
        
        [self.scrollView addSubview:vc.view];
        vc.view.frame = CGRectMake(idx * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height - kBaseSegmentHeight - kNavBarHeight);
    }];
    self.scrollView.contentSize = CGSizeMake(self.titles.count * self.view.frame.size.width, 0);
    
    // 刷新
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
    
    [self.childVCs enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.view.frame = CGRectMake(idx * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    self.scrollView.contentSize = CGSizeMake(self.childVCs.count * self.view.frame.size.width, 0);
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

#pragma mark - GKPageTableViewGestureDelegate
- (BOOL)pageTableView:(GKPageTableView *)tableView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 禁止UIScrollView左右滑动时，上下左右都可以滑动
    UIScrollView *scrollView = [self.headerView valueForKey:@"collectionView"];
    
    if (otherGestureRecognizer == scrollView.panGestureRecognizer) {
        return NO;
    }
    
    if (otherGestureRecognizer == self.scrollView.panGestureRecognizer) {
        return NO;
    }
    
    return [gestureRecognizer.view isKindOfClass:[UIScrollView class]] && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]];
}

#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
        _pageScrollView.ceilPointHeight = 0;
        _pageScrollView.mainTableView.gestureDelegate = self;
    }
    return _pageScrollView;
}

- (GKHeaderScrollView *)headerView {
    if (!_headerView) {
        CGFloat headerH = (self.view.frame.size.width - 40) / 4 + 20;
        
        _headerView = [[GKHeaderScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerH)];
    }
    return _headerView;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"动态", @"文章", @"更多"];
    }
    return _titles;
}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = [UIView new];
        
        [_pageView addSubview:self.categoryView];
        [_pageView addSubview:self.scrollView];
        
        [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self->_pageView);
            make.height.mas_equalTo(kBaseSegmentHeight);
        }];
        
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self->_pageView);
            make.top.equalTo(self.categoryView.mas_bottom);
        }];
    }
    return _pageView;
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] init];
        _categoryView.titleFont = [UIFont systemFontOfSize:15.0f];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:15.0f];
        _categoryView.titleColor = [UIColor grayColor];
        _categoryView.titleSelectedColor = [UIColor redColor];
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
        lineView.indicatorHeight = ADAPTATIONRATIO * 4.0f;
        lineView.verticalMargin = ADAPTATIONRATIO * 2.0f;
        _categoryView.indicators = @[lineView];
        
        // 设置关联的scrollView
        _categoryView.contentScrollView = self.scrollView;
        
        UIView  *btmLineView = [UIView new];
        btmLineView.backgroundColor = GKColorRGB(110, 110, 110);
        [_categoryView addSubview:btmLineView];
        [btmLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self->_categoryView);
            make.height.mas_equalTo(ADAPTATIONRATIO * 2.0f);
        }];
    }
    return _categoryView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.gk_openGestureHandle = YES;
    }
    return _scrollView;
}

- (NSMutableArray *)childVCs {
    if (!_childVCs) {
        _childVCs = [NSMutableArray new];
    }
    return _childVCs;
}

@end

