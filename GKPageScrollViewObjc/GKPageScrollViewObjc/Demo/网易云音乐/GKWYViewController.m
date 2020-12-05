//
//  GKWYViewController.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKWYViewController.h"
#import "GKWYListViewController.h"
#import "GKWYHeaderView.h"
#import "JXCategoryView.h"

#define kCriticalPoint -ADAPTATIONRATIO * 50.0f

@interface GKWYViewController ()<GKPageScrollViewDelegate, JXCategoryViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) GKPageScrollView      *pageScrollView;

@property (nonatomic, strong) GKWYHeaderView        *headerView;

@property (nonatomic, strong) UIView                *pageView;
@property (nonatomic, strong) JXCategoryTitleView   *categoryView;
@property (nonatomic, strong) UIScrollView          *scrollView;

@property (nonatomic, strong) NSArray               *titles;
@property (nonatomic, strong) NSArray               *childVCs;

@property (nonatomic, strong) UIImageView           *headerBgImgView;
@property (nonatomic, strong) UIVisualEffectView    *effectView;

@end

@implementation GKWYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    self.gk_navLineHidden = YES;
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    self.gk_navTitleColor = [UIColor whiteColor];
    
    [self.view addSubview:self.headerBgImgView];
    [self.view addSubview:self.effectView];
    [self.view addSubview:self.pageScrollView];
    
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(GK_STATUSBAR_NAVBAR_HEIGHT, 0, 0, 0));
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(@0);
        make.width.mas_equalTo(kScreenW);
        make.height.mas_equalTo(kWYHeaderHeight);
    }];
    
    [self.headerBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kCriticalPoint);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.headerView.mas_top).offset(kWYHeaderHeight - kCriticalPoint);
        make.height.mas_greaterThanOrEqualTo(GK_STATUSBAR_NAVBAR_HEIGHT);
    }];
    
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kCriticalPoint);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.headerView.mas_top).offset(kWYHeaderHeight - kCriticalPoint);
        make.height.mas_greaterThanOrEqualTo(GK_STATUSBAR_NAVBAR_HEIGHT);
    }];
    
    [self.pageScrollView reloadData];
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
    return self.childVCs;
}

- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll {
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY >= kWYHeaderHeight) {
        [self.headerBgImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(GK_STATUSBAR_NAVBAR_HEIGHT);
        }];
        
        [self.effectView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(GK_STATUSBAR_NAVBAR_HEIGHT);
        }];
        self.effectView.alpha = 1.0f;
    }else {
        // 0到临界点 高度不变
        if (offsetY <= 0 && offsetY >= kCriticalPoint) {
            CGFloat criticalOffsetY = offsetY - kCriticalPoint;
            
            [self.headerBgImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(-criticalOffsetY);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.headerView.mas_top).offset(kWYHeaderHeight + criticalOffsetY);
            }];
            
            [self.effectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(-criticalOffsetY);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.headerView.mas_top).offset(kWYHeaderHeight + criticalOffsetY);
            }];
        }else { // 小于-20 下拉放大
            [self.headerBgImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.headerView.mas_top).offset(kWYHeaderHeight);
            }];
            
            [self.effectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.headerView.mas_top).offset(kWYHeaderHeight);
            }];
        }
        
        // 背景虚化
        // offsetY：0 - kWYHeaderHeight 透明度alpha：0-1
        CGFloat alpha = 0.0f;
        if (offsetY <= 0) {
            alpha = 0.0f;
        }else if (offsetY < kWYHeaderHeight) {
            alpha = offsetY / kWYHeaderHeight;
        }else {
            alpha = 1.0f;
        }
        self.effectView.alpha = alpha;
    }
    
    BOOL show = [self isAlbumNameLabelShowingOn];
    
    if (show) {
        self.gk_navTitle = @"";
    }else {
        self.gk_navTitle = self.headerView.nameLabel.text;
    }
}

- (BOOL)isAlbumNameLabelShowingOn {
    UIView *view = self.headerView.nameLabel;
    
    // 获取titlelabel在视图上的位置
    CGRect showFrame = [self.view convertRect:view.frame fromView:view.superview];
    
    showFrame.origin.y -= kNavBarHeight;
    
    // 判断是否有重叠部分
    BOOL intersects = CGRectIntersectsRect(self.view.bounds, showFrame);
    
    return !view.isHidden && view.alpha > 0.01 && intersects;
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    NSLog(@"刷新数据");
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewWillBeginScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewDidEndedScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.pageScrollView horizonScrollViewDidEndedScroll];
}

#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
        _pageScrollView.mainTableView.backgroundColor = [UIColor clearColor];
        _pageScrollView.ceilPointHeight = 0;
    }
    return _pageScrollView;
}

- (GKWYHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[GKWYHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kWYHeaderHeight)];
    }
    return _headerView;
}

- (UIImageView *)headerBgImgView {
    if (!_headerBgImgView) {
        _headerBgImgView = [UIImageView new];
        _headerBgImgView.contentMode = UIViewContentModeScaleAspectFill;
        _headerBgImgView.clipsToBounds = YES;
        _headerBgImgView.image = [UIImage imageNamed:@"wy_bg"];
    }
    return _headerBgImgView;
}

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _effectView.alpha = 0;
    }
    return _effectView;
}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = [UIView new];
        _pageView.backgroundColor = [UIColor clearColor];
        
        [_pageView addSubview:self.categoryView];
        [_pageView addSubview:self.scrollView];
    }
    return _pageView;
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 40.0f)];
        _categoryView.titles = self.titles;
        _categoryView.delegate = self;
        _categoryView.titleColor = [UIColor blackColor];
        _categoryView.titleSelectedColor = GKColorRGB(200, 38, 39);
        _categoryView.titleFont = [UIFont systemFontOfSize:16.0f];
        _categoryView.titleSelectedFont = [UIFont boldSystemFontOfSize:16.0f];
//        _categoryView.cellChangeInHalf = YES;   // 当scrollView滑动到一半时改变cell状态
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorColor = GKColorRGB(200, 38, 39);
        lineView.indicatorWidth = 30.0f;
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
        _categoryView.indicators = @[lineView];
        
        _categoryView.contentScrollView = self.scrollView;
        
        // 添加分割线
        UIView *btmLineView = [UIView new];
        btmLineView.frame = CGRectMake(0, 40 - 0.5, kScreenW, 0.5);
        btmLineView.backgroundColor = GKColorGray(200);
        [_categoryView addSubview:btmLineView];
    }
    return _categoryView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        CGFloat scrollW = kScreenW;
        CGFloat scrollH = kScreenH - kNavBarHeight - 40.0f;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, scrollW, scrollH)];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.gk_openGestureHandle = YES;
        
        [self.childVCs enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addChildViewController:vc];
            [self->_scrollView addSubview:vc.view];
            
            vc.view.frame = CGRectMake(idx * scrollW, 0, scrollW, scrollH);
        }];
        _scrollView.contentSize = CGSizeMake(self.childVCs.count * scrollW, 0);
                                                                     
    }
    return _scrollView;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"热门演唱", @"专辑", @"视频", @"艺人信息"];
    }
    return _titles;
}

- (NSArray *)childVCs {
    if (!_childVCs) {
        GKWYListViewController *hotVC = [GKWYListViewController new];
        
        GKWYListViewController *albumVC = [GKWYListViewController new];
        
        GKWYListViewController *videoVC = [GKWYListViewController new];
        
        GKWYListViewController *introVC = [GKWYListViewController new];
        
        _childVCs = @[hotVC, albumVC, videoVC, introVC];
    }
    return _childVCs;
}

@end
