//
//  GKWBViewController.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/27.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKWBViewController.h"
#import "GKWBPageViewController.h"
#import "GKWBListViewController.h"

#import "GKPageScrollView.h"
#import "GKWBHeaderView.h"

@interface GKWBViewController ()<GKPageScrollViewDelegate, WMPageControllerDataSource, WMPageControllerDelegate, GKWBPageViewControllDelegate>

@property (nonatomic, strong) GKPageScrollView          *pageScrollView;

@property (nonatomic, strong) GKWBHeaderView            *headerView;

@property (nonatomic, strong) GKWBPageViewController    *pageVC;
@property (nonatomic, strong) UIView                    *pageView;

@property (nonatomic, strong) NSArray                   *titles;
@property (nonatomic, strong) NSArray                   *childVCs;

@property (nonatomic, strong) UIView                    *titleView;
@property (nonatomic, strong) UILabel                   *titleLabel;

@end

@implementation GKWBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBarAlpha = 0.0f;
    
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    
    self.gk_navTitleView = self.titleView;

    self.gk_navLeftBarButtonItem = [UIBarButtonItem gk_itemWithTitle:nil image:[UIImage gk_imageNamed:@"btn_back_white"] target:self action:@selector(back)];
    self.gk_navRightBarButtonItem = [UIBarButtonItem gk_itemWithImage:[UIImage gk_imageNamed:@"wb_more"] target:self action:@selector(more)];
    
    [self.view addSubview:self.pageScrollView];
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.pageScrollView reloadData];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)more {
    
}

- (UIImage *)changeImageWithColor:(UIColor *)color image:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll {
    CGFloat offsetY = scrollView.contentOffset.y;
    
    // 偏移量 < 60 0
    // 偏移量 60 - 100 导航栏0-1渐变
    // 偏移量 > 100 1
    
    CGFloat alpha = 0;
    if (offsetY <= 60.0f) {
        alpha = 0.0f;
        
        self.titleLabel.alpha = 0;
        
        self.gk_statusBarStyle = UIStatusBarStyleLightContent;
        self.gk_navLeftBarButtonItem = [UIBarButtonItem gk_itemWithTitle:nil image:[UIImage gk_imageNamed:@"btn_back_white"] target:self action:@selector(back)];
        self.gk_navRightBarButtonItem = [UIBarButtonItem gk_itemWithImage:[UIImage imageNamed:@"wb_more"] target:self action:@selector(more)];
        
    }else if (offsetY >= 100.0f) {
        alpha = 1.0f;
        
        self.gk_statusBarStyle = UIStatusBarStyleDefault;
        self.gk_navLeftBarButtonItem = [UIBarButtonItem gk_itemWithTitle:nil image:[UIImage gk_imageNamed:@"btn_back_black"] target:self action:@selector(back)];
        
        self.gk_navRightBarButtonItem = [UIBarButtonItem gk_itemWithTitle:nil image:[self changeImageWithColor:[UIColor blackColor] image:[UIImage imageNamed:@"wb_more"]] target:self action:@selector(more)];
        
        // 92
        self.titleLabel.alpha = 1;
        
    }else {
        alpha = (offsetY - 60) / (100 - 60);
        
        if (alpha > 0.8) {
            self.gk_statusBarStyle = UIStatusBarStyleDefault;
            self.gk_navLeftBarButtonItem = [UIBarButtonItem gk_itemWithTitle:nil image:[UIImage gk_imageNamed:@"btn_back_black"] target:self action:@selector(back)];
            self.gk_navRightBarButtonItem = [UIBarButtonItem gk_itemWithTitle:nil image:[self changeImageWithColor:[UIColor blackColor] image:[UIImage imageNamed:@"wb_more"]] target:self action:@selector(more)];
            
            // 92
            self.titleLabel.alpha = (offsetY - 92) / (100 - 92);
            
        }else {
            self.titleLabel.alpha = 0;
            
            self.gk_statusBarStyle = UIStatusBarStyleLightContent;
            self.gk_navLeftBarButtonItem = [UIBarButtonItem gk_itemWithTitle:nil image:[UIImage gk_imageNamed:@"btn_back_white"] target:self action:@selector(back)];
            self.gk_navRightBarButtonItem = [UIBarButtonItem gk_itemWithImage:[UIImage imageNamed:@"wb_more"] target:self action:@selector(more)];
        }
    }
    
    if (self.gk_navBarAlpha != alpha) {
        self.gk_navBarAlpha = alpha;
    }
    
    // 头图下拉
    [self.headerView scrollViewDidScroll:scrollView.contentOffset.y];
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.childVCs.count;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.titles[index];
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    return self.childVCs[index];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0, kScreenW, 40.0f);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat maxY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:pageController.menuView]);
    return CGRectMake(0, maxY, kScreenW, kScreenH - maxY - self.pageScrollView.ceilPointHeight);
}

#pragma mark - WMPageControllerDelegate
- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    
    NSLog(@"加载数据");
}

#pragma mark - GKWBPageViewControllDelegate
- (void)pageScrollViewWillBeginScroll {
//    [self.pageScrollView horizonScrollViewWillBeginScroll];
}

- (void)pageScrollViewDidEndedScroll {
//    [self.pageScrollView horizonScrollViewDidEndedScroll];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.headerView.frame = CGRectMake(0, 0, kScreenW, kWBHeaderHeight);
    
    if (kScreenH > kScreenW) {
        self.pageScrollView.ceilPointHeight = GK_STATUSBAR_NAVBAR_HEIGHT;
    }else {
        self.pageScrollView.ceilPointHeight = 44.0f;
    }
    [self.pageVC reloadData];
    self.pageVC.scrollView.gk_openGestureHandle = YES;
    self.pageScrollView.horizontalScrollViewList = @[self.pageVC.scrollView];
}

#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
        _pageScrollView.mainTableView.backgroundColor = GKColorGray(232);
        _pageScrollView.controlVerticalIndicator = YES;
//        _pageScrollView.contentScrollView = self.pageVC.scrollView;
    }
    return _pageScrollView;
}

- (GKWBHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[GKWBHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kWBHeaderHeight)];
    }
    return _headerView;
}

- (GKWBPageViewController *)pageVC {
    if (!_pageVC) {
        _pageVC = [[GKWBPageViewController alloc] init];
        _pageVC.dataSource = self;
        _pageVC.delegate = self;
        _pageVC.scrollDelegate = self;
        
        // 菜单属性
        _pageVC.menuItemWidth = kScreenW / 4.0f - 20;
        _pageVC.menuViewStyle = WMMenuViewStyleLine;
        
        _pageVC.titleSizeNormal     = 16.0f;
        _pageVC.titleSizeSelected   = 16.0f;
        _pageVC.titleColorNormal    = [UIColor grayColor];
        _pageVC.titleColorSelected  = [UIColor blackColor];
        
        // 进度条属性
        _pageVC.progressColor               = GKColorRGB(250, 69, 6);
        _pageVC.progressWidth               = 30.0f;
        _pageVC.progressHeight              = 3.0f;
        _pageVC.progressViewBottomSpace     = 2.0f;
        _pageVC.progressViewCornerRadius    = _pageVC.progressHeight / 2;
        
        // 调皮效果
        _pageVC.progressViewIsNaughty       = YES;
    }
    return _pageVC;
}

- (UIView *)pageView {
    if (!_pageView) {
        [self addChildViewController:self.pageVC];
        [self.pageVC didMoveToParentViewController:self];
        
        _pageView = self.pageVC.view;
    }
    return _pageView;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"主页", @"微博", @"视频", @"故事"];
    }
    return _titles;
}

- (NSArray *)childVCs {
    if (!_childVCs) {
        GKWBListViewController *homeVC = [GKWBListViewController new];
        
        GKWBListViewController *wbVC = [GKWBListViewController new];
        
        GKWBListViewController *videoVC = [GKWBListViewController new];
        
        GKWBListViewController *storyVC = [GKWBListViewController new];
        
        _childVCs = @[homeVC, wbVC, videoVC, storyVC];
    }
    return _childVCs;
}

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
        _titleView.backgroundColor = [UIColor clearColor];
        
        [_titleView addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.titleView);
        }];
    }
    return _titleView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:18.0f];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = @"广文博见V";
        _titleLabel.alpha = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
