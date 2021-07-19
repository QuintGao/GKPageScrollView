//
//  GKDBViewController.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2020/12/17.
//  Copyright © 2020 gaokun. All rights reserved.
//

#import "GKDBViewController.h"
#import "GKPageSmoothView.h"
#import "GKDBListView.h"

@interface GKDBViewController ()<GKPageSmoothViewDataSource, GKPageSmoothViewDelegate, JXCategoryViewDelegate>

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) GKPageSmoothView *smoothView;

@property (nonatomic, strong) UIImageView *headerView;

@property (nonatomic, strong) UIView    *segmentedView;

@property (nonatomic, strong) JXCategorySubTitleView *categoryView;

@property (nonatomic, strong) JXCategoryIndicatorAlignmentLineView *lineView;

@property (nonatomic, assign) BOOL isTitleViewShow;
@property (nonatomic, assign) CGFloat originAlpha;

@property (nonatomic, assign) CGFloat lastRatio;

@end

@implementation GKDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    self.gk_navBarAlpha = 0;
    self.gk_navBackgroundColor = GKColorRGB(123, 106, 89);
    self.gk_navTitle = @"电影";
    self.gk_navTitleColor = UIColor.whiteColor;
    
    [self.view addSubview:self.smoothView];
    [self.smoothView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.categoryView.contentScrollView = self.smoothView.listCollectionView;
    [self.smoothView reloadData];
}

#pragma mark - GKPageSmoothViewDataSource
- (UIView *)headerViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.headerView;
}

- (UIView *)segmentedViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.segmentedView;
}

- (NSInteger)numberOfListsInSmoothView:(GKPageSmoothView *)smoothView {
    return self.categoryView.titles.count;
}

- (id<GKPageSmoothListViewDelegate>)smoothView:(GKPageSmoothView *)smoothView initListAtIndex:(NSInteger)index {
    GKDBListView *listView = [GKDBListView new];
    return listView;
}

#pragma mark - GKPageSmoothViewDelegate
- (void)smoothView:(GKPageSmoothView *)smoothView listScrollViewDidScroll:(UIScrollView *)scrollView contentOffset:(CGPoint)contentOffset {
    if (smoothView.isOnTop) return;
    
    // 导航栏显隐
    CGFloat offsetY = contentOffset.y;
    CGFloat alpha = 0;
    if (offsetY <= 0) {
        alpha = 0;
    }else if (offsetY > 60) {
        alpha = 1;
        [self changeTitle:YES];
    }else {
        alpha = offsetY / 60;
        [self changeTitle:NO];
    }
    self.gk_navBarAlpha = alpha;
}

- (void)smoothViewDragBegan:(GKPageSmoothView *)smoothView {
    if (smoothView.isOnTop) return;
    
    self.isTitleViewShow = (self.gk_navTitleView != nil);
    self.originAlpha = self.gk_navBarAlpha;
}

- (void)smoothViewDragEnded:(GKPageSmoothView *)smoothView isOnTop:(BOOL)isOnTop {
    // titleView已经显示，不作处理
    if (self.isTitleViewShow) return;
    
    if (isOnTop) {
        self.gk_navBarAlpha = 1.0f;
        [self changeTitle:YES];
    }else {
        self.gk_navBarAlpha = self.originAlpha;
        [self changeTitle:NO];
    }
}

- (void)changeTitle:(BOOL)isShow {
    if (isShow) {
        if (self.gk_navTitle == nil) return;
        self.gk_navTitle = nil;
        self.gk_navTitleView = self.titleView;
    }else {
        if (self.gk_navTitleView == nil) return;
        self.gk_navTitle = @"电影";
        self.gk_navTitleView = nil;
    }
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index {
    [self.smoothView showingOnTop];
}

#pragma mark - 懒加载
- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100, 44.0f)];
        
        UIImage *image = [UIImage imageNamed:@"db_title"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        imgView.frame = CGRectMake(0, 0, 44.0f * image.size.width / image.size.height, 44.0f);
        [_titleView addSubview:imgView];
    }
    return _titleView;
}

- (GKPageSmoothView *)smoothView {
    if (!_smoothView) {
        _smoothView = [[GKPageSmoothView alloc] initWithDataSource:self];
        _smoothView.delegate = self;
        _smoothView.ceilPointHeight = GK_STATUSBAR_NAVBAR_HEIGHT;
        _smoothView.bottomHover = YES;
        _smoothView.allowDragBottom = YES;
        _smoothView.allowDragScroll = YES;
        // 解决与返回手势滑动冲突
        _smoothView.listCollectionView.gk_openGestureHandle = YES;
    }
    return _smoothView;
}

- (UIImageView *)headerView {
    if (!_headerView) {
        UIImage *image = [UIImage imageNamed:@"douban"];
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _headerView.image = image;
    }
    return _headerView;
}

- (UIView *)segmentedView {
    if (!_segmentedView) {
        _segmentedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        _segmentedView.backgroundColor = [UIColor whiteColor];
        [_segmentedView addSubview:self.categoryView];
        
        UIView *topView = [UIView new];
        topView.backgroundColor = [UIColor lightGrayColor];
        topView.layer.cornerRadius = 3;
        topView.layer.masksToBounds = YES;
        [_segmentedView addSubview:topView];
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self->_segmentedView).offset(5);
            make.centerX.equalTo(self->_segmentedView);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(6);
        }];
    }
    return _segmentedView;
}

- (JXCategorySubTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategorySubTitleView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 40)];
        _categoryView.backgroundColor = UIColor.whiteColor;
        _categoryView.averageCellSpacingEnabled = NO;
        _categoryView.contentEdgeInsetLeft = 16;
        _categoryView.delegate = self;
        _categoryView.titles = @[@"影评", @"讨论"];
        _categoryView.titleFont = [UIFont systemFontOfSize:16];
        _categoryView.titleColor = UIColor.grayColor;
        _categoryView.titleSelectedColor = UIColor.blackColor;
        _categoryView.subTitles = @[@"342", @"2004"];
        _categoryView.subTitleFont = [UIFont systemFontOfSize:11];
        _categoryView.subTitleColor = UIColor.grayColor;
        _categoryView.subTitleSelectedColor = UIColor.grayColor;
        _categoryView.positionStyle = JXCategorySubTitlePositionStyle_Right;
        _categoryView.alignStyle = JXCategorySubTitleAlignStyle_Top;
        _categoryView.cellSpacing = 30;
        _categoryView.cellWidthIncrement = 0;
        _categoryView.ignoreSubTitleWidth = YES;
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.indicatorColor = UIColor.blackColor;
        _categoryView.indicators = @[self.lineView];
        
        _categoryView.contentScrollView = self.smoothView.listCollectionView;
    }
    return _categoryView;
}

-  (JXCategoryIndicatorAlignmentLineView *)lineView {
    if (!_lineView) {
        _lineView = [JXCategoryIndicatorAlignmentLineView new];
        _lineView.indicatorColor = UIColor.blackColor;
    }
    return _lineView;
}

@end
