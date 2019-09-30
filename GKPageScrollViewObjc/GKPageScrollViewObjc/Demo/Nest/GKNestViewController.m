//
//  GKNestViewController.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/9/30.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "GKNestViewController.h"
#import "GKPageScrollView.h"
#import <JXCategoryView/JXCategoryView.h>
#import "GKNestView.h"

@interface GKNestViewController()<GKPageScrollViewDelegate, GKPageTableViewGestureDelegate, JXCategoryViewDelegate>

@property (nonatomic, strong) GKPageScrollView      *pageScrollView;

@property (nonatomic, strong) UIImageView           *headerView;

@property (nonatomic, strong) JXCategoryTitleView   *categoryView;

@end

@implementation GKNestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.pageScrollView];
    
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.pageScrollView reloadData];
}

#pragma mark - GKPageScrollViewDelegate
- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.headerView;
}

- (UIView *)segmentedViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.categoryView;
}

- (NSInteger)numberOfListsInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.categoryView.titles.count;
}

- (id<GKPageListViewDelegate>)pageScrollView:(GKPageScrollView *)pageScrollView initListAtIndex:(NSInteger)index {
    GKNestView *nestView = [GKNestView new];
    return nestView;
}

#pragma mark - GKPageTableViewGestureDelegate
- (BOOL)pageTableViewGestureRecoginzer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGesutreRecognizer {
    if ([self checkIsContentScrollView:(UIScrollView *)gestureRecognizer.view] || [self checkIsContentScrollView:(UIScrollView *)otherGesutreRecognizer.view]) {
        // 如果交互的是嵌套的contentScrollView，证明在左右滑动，就不允许同时相应
        return NO;
    }
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGesutreRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

- (BOOL)checkIsContentScrollView:(UIScrollView *)scrollView {
    for (GKNestView *listView in self.pageScrollView.validListDict.allValues) {
        if (listView.contentScrollView == scrollView) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
        _pageScrollView.isLazyLoadList = YES;
        _pageScrollView.mainTableView.gestureDelegate = self;
    }
    return _pageScrollView;
}

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, ADAPTATIONRATIO * 400.0f)];
        _headerView.image = [UIImage imageNamed:@"test"];
    }
    return _headerView;
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 50.0f)];
        _categoryView.titles = @[@"精选", @"时尚", @"电器", @"超市", @"生活", @"运动", @"饰品", @"数码", @"家装", @"手机"];
        _categoryView.titleFont = [UIFont systemFontOfSize:15.0f];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:16.0f];
        _categoryView.titleColor = [UIColor blackColor];
        _categoryView.titleSelectedColor = [UIColor blackColor];
        _categoryView.delegate = self;
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
        _categoryView.indicators = @[lineView];
        
        _categoryView.contentScrollView = self.pageScrollView.listContainerView.collectionView;
    }
    return _categoryView;
}

@end
