//
//  GKNest1ViewController.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/9/30.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "GKNest1ViewController.h"
#import "GKPageScrollView.h"
#import "GKNestView.h"

@interface GKNest1ViewController()<GKPageScrollViewDelegate, JXCategoryViewDelegate, GKPageTableViewGestureDelegate, JXCategoryCollectionViewGestureDelegate>

@property (nonatomic, strong) GKPageScrollView      *pageScrollView;

@property (nonatomic, strong) UIImageView           *headerView;

@property (nonatomic, strong) JXCategoryTitleView   *categoryView;

@property (nonatomic, weak) GKNestView              *currentNestView;

@end

@implementation GKNest1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    self.gk_navLineHidden = YES;
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    
    [self.view addSubview:self.pageScrollView];
    
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.pageScrollView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self categoryView:self.categoryView didSelectedItemAtIndex:0];
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
    nestView.contentScrollView.gk_openGestureHandle = YES;
    return nestView;
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    self.currentNestView = (GKNestView *)self.pageScrollView.validListDict[@(index)];
}

#pragma mark - GKPageTableViewGestureDelegate
- (BOOL)pageTableView:(GKPageTableView *)tableView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer.view == self.categoryView.collectionView) {
        return NO;
    }
    
    if (otherGestureRecognizer.view == self.currentNestView.contentScrollView) {
        return NO;
    }
    
    return [gestureRecognizer.view isKindOfClass:[UIScrollView class]] && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]];
}

#pragma mark - JXCategoryCollectionViewGestureDelegate
- (BOOL)categoryCollectionView:(JXCategoryCollectionView *)collectionView gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([self panBackWithScrollView:collectionView gestureRecognizer:gestureRecognizer]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)categoryCollectionView:(JXCategoryCollectionView *)collectionView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([self panBackWithScrollView:collectionView gestureRecognizer:gestureRecognizer]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)panBackWithScrollView:(UIScrollView *)scrollView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == scrollView.panGestureRecognizer) {
        CGPoint point = [scrollView.panGestureRecognizer translationInView:scrollView];
        UIGestureRecognizerState state = gestureRecognizer.state;
        
        // 设置手势滑动的位置距屏幕左边的区域
        CGFloat locationDistance = [UIScreen mainScreen].bounds.size.width;
        
        if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStatePossible) {
            CGPoint location = [gestureRecognizer locationInView:scrollView];
            if (point.x > 0 && location.x < locationDistance && scrollView.contentOffset.x <= 0) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
        _pageScrollView.lazyLoadList = YES;
        _pageScrollView.mainTableView.gestureDelegate = self;
        _pageScrollView.listContainerView.collectionView.gk_openGestureHandle = YES;
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
        _categoryView.collectionView.gestureDelegate = self;
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
        _categoryView.indicators = @[lineView];
        
        _categoryView.contentScrollView = self.pageScrollView.listContainerView.collectionView;
        
        UIView *bottomLineView = [UIView new];
        bottomLineView.backgroundColor = [UIColor grayColor];
        [_categoryView addSubview:bottomLineView];
        
        [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self->_categoryView);
            make.height.mas_equalTo(0.5f);
        }];
    }
    return _categoryView;
}

@end
