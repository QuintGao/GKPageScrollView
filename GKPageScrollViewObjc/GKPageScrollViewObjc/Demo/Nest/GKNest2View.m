//
//  GKNest2View.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/10/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "GKNest2View.h"
#import <JXCategoryView/JXCategoryView.h>
#import "GKNestListView.h"

@interface GKNest2View()<GKPageScrollViewDelegate>

@property (nonatomic, strong) UIImageView       *headerView;

@property (nonatomic, strong) JXCategoryTitleView   *categoryView;

@end

@implementation GKNest2View

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.pageScrollView];
        
        [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.pageScrollView reloadData];
    }
    return self;
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
    GKNestListView *listView = [GKNestListView new];
    return listView;
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self;
}

#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
        _pageScrollView.isLazyLoadList = YES;
        _pageScrollView.ceilPointHeight = 0;
        _pageScrollView.listContainerView.collectionView.isNestEnabled = YES;
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
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 40.0f)];
        _categoryView.titleFont = [UIFont systemFontOfSize:14.0f];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:15.0f];
        _categoryView.titleColor = [UIColor grayColor];
        _categoryView.titleSelectedColor = [UIColor grayColor];
        _categoryView.titles = @[@"综合", @"销量", @"价格"];
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
        _categoryView.indicators = @[lineView];
        
        _categoryView.contentScrollView = self.pageScrollView.listContainerView.collectionView;
    }
    return _categoryView;
}

@end
