//
//  GKNest2ViewController.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/10/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "GKNest2ViewController.h"
#import "GKNestScrollView.h"
#import "GKNest2View.h"
#import <JXCategoryView/JXCategoryView.h>

@interface GKNest2ViewController ()<JXCategoryViewDelegate, UIScrollViewDelegate, GKNestScrollViewGestureDelegate>

@property (nonatomic, strong) JXCategoryTitleView *categoryView;

@property (nonatomic, strong) GKNestScrollView    *contentScrollView;

@property (nonatomic, weak) GKNest2View           *nestView;

@end

@implementation GKNest2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_backStyle = GKNavigationBarBackStyleBlack;
    self.gk_navTitleView = self.categoryView;
    
    [self.view addSubview:self.contentScrollView];
    
    [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
    }];
    
    [self categoryView:self.categoryView didSelectedItemAtIndex:0];
}

#pragma mark - JXCateogryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    self.nestView = (GKNest2View *)self.contentScrollView.subviews[index];
}

#pragma mark - GKNestScrollViewGestureDelegate
- (BOOL)nestScrollView:(GKNestScrollView *)scrollView gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self panBackWithScrollView:scrollView gestureRecognizer:gestureRecognizer]) {
        return NO;
    }
    
    UIScrollView *listScrollView = self.nestView.pageScrollView.listContainerView.collectionView;
    
    if (listScrollView.isTracking || listScrollView.isDragging) {
        if ([gestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
            CGFloat velocityX = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view].x;
            // x大于0就是右滑，如果列表容器没有滑动到最右边，禁止滑动
            if (velocityX > 0) {
                if (listScrollView.contentOffset.x != 0) {
                    return NO;
                }
            }else if (velocityX < 0) { // x小于0是往左滑
                if (listScrollView.contentOffset.x + listScrollView.bounds.size.width != listScrollView.contentSize.width) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (BOOL)nestScrollView:(GKNestScrollView *)scrollView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self panBackWithScrollView:scrollView gestureRecognizer:gestureRecognizer]) return YES;
    
    return NO;
}

// 检查contentScrollView是否滑动到边缘
- (BOOL)checkIsContentScrollEdge {
    UIScrollView *listCollectionView = self.nestView.pageScrollView.listContainerView.collectionView;
    
    if (listCollectionView.contentOffset.x == 0 || (listCollectionView.contentOffset.x + listCollectionView.frame.size.width) == listCollectionView.contentSize.width) {
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
- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 44.0f)];
        _categoryView.titles = @[@"精选", @"时尚", @"电器", @"超市", @"生活", @"运动", @"饰品", @"数码", @"家装", @"手机"];
        _categoryView.titleFont = [UIFont systemFontOfSize:15.0f];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:16.0f];
        _categoryView.titleColor = [UIColor blackColor];
        _categoryView.titleSelectedColor = [UIColor blackColor];
        _categoryView.delegate = self;
        _categoryView.contentEdgeInsetLeft = 0;
        _categoryView.contentEdgeInsetRight = 0;
        
        JXCategoryIndicatorLineView *lineView = [JXCategoryIndicatorLineView new];
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
        _categoryView.indicators = @[lineView];
        
        _categoryView.contentScrollView = self.contentScrollView;
    }
    return _categoryView;
}

- (GKNestScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [GKNestScrollView new];
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.delegate = self;
        _contentScrollView.gestureDelegate = self;
        _contentScrollView.pagingEnabled = YES;

        CGFloat width = kScreenW;
        CGFloat height = kScreenH - GK_STATUSBAR_HEIGHT - 50.0f;

        [self.categoryView.titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKNest2View *nestView = [GKNest2View new];
            nestView.frame = CGRectMake(idx * width, 0, width, height);
            nestView.mainScrollView = self->_contentScrollView;
            [self->_contentScrollView addSubview:nestView];
        }];

        _contentScrollView.contentSize = CGSizeMake(self.categoryView.titles.count * width, 0);
    }
    return _contentScrollView;
}

@end
