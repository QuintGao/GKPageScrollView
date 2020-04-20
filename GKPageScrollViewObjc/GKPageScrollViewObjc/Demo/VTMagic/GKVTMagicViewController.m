//
//  GKVTMagicViewController.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/6/6.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "GKVTMagicViewController.h"
#import "GKBaseListViewController.h"
#import "GKPageScrollView.h"
#import <VTMagic/VTMagic.h>

@interface GKVTMagicViewController ()<GKPageScrollViewDelegate, VTMagicViewDataSource, VTMagicViewDelegate, GKPageTableViewGestureDelegate>

@property (nonatomic, strong) GKPageScrollView  *pageScrollView;

@property (nonatomic, strong) UIView            *headerView;

@property (nonatomic, strong) UIView            *pageView;

@property (nonatomic, strong) VTMagicController *magicController;

@property (nonatomic, strong) NSArray           *titles;
@property (nonatomic, strong) NSArray           *childVCs;

@end

@implementation GKVTMagicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBarAlpha = 0;
    self.gk_navTitle = @"VTMagic使用";
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    self.gk_navTitleColor = [UIColor whiteColor];
    
    [self.view addSubview:self.pageScrollView];
    
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.pageScrollView reloadData];
    
    [self.magicController.magicView reloadData];
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
    UIScrollView *scrollView = [self.magicController.magicView valueForKey:@"contentView"];
    
    if (otherGestureRecognizer == scrollView.panGestureRecognizer) {
        return NO;
    }
    return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

#pragma mark - VTMagicViewDataSource
- (NSArray<NSString *> *)menuTitlesForMagicView:(VTMagicView *)magicView {
    return self.titles;
}

- (UIButton *)magicView:(VTMagicView *)magicView menuItemAtIndex:(NSUInteger)itemIndex {
    static NSString *itemIdentifier = @"itemIdentifier";
    UIButton *menuItem = [magicView dequeueReusableItemWithIdentifier:itemIdentifier];
    if (!menuItem) {
        menuItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuItem setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [menuItem setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        menuItem.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.f];
    }
    return menuItem;
}

- (UIViewController *)magicView:(VTMagicView *)magicView viewControllerAtPage:(NSUInteger)pageIndex {
    return self.childVCs[pageIndex];
}

#pragma mark - VTMagicViewDelegate

#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
        _pageScrollView.mainTableView.gestureDelegate = self;
    }
    return _pageScrollView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200.0f)];
        _headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"test"]];
    }
    return _headerView;
}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = self.magicController.view;
    }
    return _pageView;
}

- (VTMagicController *)magicController {
    if (!_magicController) {
        _magicController = [[VTMagicController alloc] init];
        _magicController.magicView.navigationColor = [UIColor whiteColor];
        _magicController.magicView.sliderColor = [UIColor redColor];
        _magicController.magicView.layoutStyle = VTLayoutStyleDivide;
        _magicController.magicView.switchStyle = VTSwitchStyleDefault;
        _magicController.magicView.navigationHeight = 40.f;
        _magicController.magicView.dataSource = self;
        _magicController.magicView.delegate = self;
    }
    return _magicController;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"详情", @"热门", @"相关", @"聊天"];
    }
    return _titles;
}

- (NSArray *)childVCs {
    if (!_childVCs) {
        GKBaseListViewController *detailVC = [GKBaseListViewController new];
        detailVC.shouldLoadData = NO;
        
        GKBaseListViewController *hotVC = [GKBaseListViewController new];
        hotVC.shouldLoadData = NO;
        
        GKBaseListViewController *aboutVC = [GKBaseListViewController new];
        aboutVC.shouldLoadData = NO;
        
        GKBaseListViewController *chatVC = [GKBaseListViewController new];
        chatVC.shouldLoadData = NO;
        
        _childVCs = @[detailVC, hotVC, aboutVC, chatVC];
    }
    return _childVCs;
}

@end
