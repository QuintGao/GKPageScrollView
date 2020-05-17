//
//  GKSmoothViewController.m
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2020/5/8.
//  Copyright © 2020 gaokun. All rights reserved.
//

#import "GKSmoothViewController.h"
#import "GKPageSmoothView.h"
#import <JXCategoryView/JXCategoryView.h>
#import "GKSmoothListView.h"

@interface GKSmoothViewController ()<GKPageSmoothViewDelegate>

@property (nonatomic, strong) GKPageSmoothView  *smoothView;

@property (nonatomic, strong) UIImageView       *headerView;

@property (nonatomic, strong) JXCategoryTitleView *categoryView;

@end

@implementation GKSmoothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBarAlpha = 0.0f;
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    
    [self.view addSubview:self.smoothView];
    [self.smoothView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.smoothView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect frame = self.headerView.frame;
        frame.size.height = 300.0f;
        self.headerView.frame = frame;
        
        [self.smoothView refreshHeaderView];
    });
}

#pragma mark - GKPageSmoothViewDelegate
- (UIView *)headerViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.headerView;
}

- (UIView *)segmentedViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.categoryView;
}

- (NSInteger)numberOfListsInSmoothView:(GKPageSmoothView *)smoothView {
    return self.categoryView.titles.count;
}

- (id<GKPageSmoothListViewDelegate>)smoothView:(GKPageSmoothView *)smoothView initListAtIndex:(NSInteger)index {
    GKSmoothListType listType = (GKSmoothListType)index;
    GKSmoothListView *listView = [[GKSmoothListView alloc] initWithListType:listType];
    return listView;
}

#pragma mark - 懒加载
- (GKPageSmoothView *)smoothView {
    if (!_smoothView) {
        _smoothView = [[GKPageSmoothView alloc] initWithDelegate:self];
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

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kBaseSegmentHeight)];
        _categoryView.titles = @[@"UITableView", @"UICollectionView", @"UIScrollView"];
        _categoryView.backgroundColor = [UIColor whiteColor];
        _categoryView.titleFont = [UIFont systemFontOfSize:14.0f];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:16.0f];
        _categoryView.titleColor = [UIColor blackColor];
        _categoryView.titleSelectedColor = [UIColor blackColor];
        _categoryView.titleLabelZoomEnabled = YES;
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
        _categoryView.indicators = @[lineView];
        
        _categoryView.contentScrollView = self.smoothView.listCollectionView;
    }
    return _categoryView;
}

@end
