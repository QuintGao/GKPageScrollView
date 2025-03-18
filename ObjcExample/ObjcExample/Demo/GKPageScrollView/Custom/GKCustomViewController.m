//
//  GKCustomViewController.m
//  ObjcExample
//
//  Created by QuintGao on 2025/3/18.
//

#import "GKCustomViewController.h"
#import <GKPageScrollView/GKPageScrollView.h>
#import "GKCustomSegmentedView.h"
#import "GKBaseListViewController.h"

@interface GKCustomViewController ()<GKPageScrollViewDelegate, GKCustomSegmentedViewDelegate>

@property (nonatomic, strong) GKPageScrollView *pageScrollView;

@property (nonatomic, strong) UIImageView *headerView;

@property (nonatomic, strong) GKCustomSegmentedView *segmentedView;

@end

@implementation GKCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitleColor = [UIColor whiteColor];
    self.gk_navTitleFont = [UIFont boldSystemFontOfSize:18.0f];
    self.gk_navBackgroundColor = [UIColor clearColor];
    self.gk_navLineHidden = YES;
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    self.gk_navTitle = @"自定义Segmented";
    
    [self initUI];
    
    [self.pageScrollView reloadData];
}

- (void)initUI {
    [self.view addSubview:self.pageScrollView];
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - GKPageScrollViewDelegate
- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.headerView;
}

- (UIView *)segmentedViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.segmentedView;
}

- (NSInteger)numberOfListsInPageScrollView:(GKPageScrollView *)pageScrollView {
    return 3;
}

- (id<GKPageListViewDelegate>)pageScrollView:(GKPageScrollView *)pageScrollView initListAtIndex:(NSInteger)index {
    GKBaseListViewController *listVC = [[GKBaseListViewController alloc] initWithListType:index];
    return listVC;
}

- (void)pageScrollView:(GKPageScrollView *)pageScrollView listDidAppearAtIndex:(NSInteger)index {
    [self.segmentedView scrollSelectWithIndex:index];
}

#pragma mark - GKCustomSegmentedViewDelegate
- (void)didClickSelectAtIndex:(NSInteger)index {
    [self.pageScrollView selectListWithIndex:index animated:YES];
}

#pragma mark - lazy
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
        _pageScrollView.listContainerType = GKPageListContainerType_ScrollView;
        _pageScrollView.lazyLoadList = YES;
    }
    return _pageScrollView;
}

- (UIImageView *)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kBaseHeaderHeight)];
        _headerView.image = [UIImage imageNamed:@"test"];
    }
    return _headerView;
}

- (GKCustomSegmentedView *)segmentedView {
    if (!_segmentedView) {
        _segmentedView = [[GKCustomSegmentedView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kBaseSegmentHeight)];
        _segmentedView.delegate = self;
    }
    return _segmentedView;
}

@end
