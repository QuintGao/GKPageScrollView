//
//  GKSmoothCustomViewController.m
//  ObjcExample
//
//  Created by QuintGao on 2025/3/18.
//

#import "GKSmoothCustomViewController.h"
#import <GKPageSmoothView/GKPageSmoothView.h>
#import "GKCustomSegmentedView.h"
#import "GKBaseListViewController.h"

@interface GKSmoothCustomViewController ()<GKPageSmoothViewDataSource, GKPageSmoothViewDelegate, GKCustomSegmentedViewDelegate>

@property (nonatomic, strong) GKPageSmoothView *smoothView;

@property (nonatomic, strong) UIImageView *headerView;

@property (nonatomic, strong) GKCustomSegmentedView *segmentedView;

@end

@implementation GKSmoothCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitle = @"自定义Segmented";
    self.gk_navLineHidden = YES;
    self.gk_navTitleColor = [UIColor whiteColor];
    self.gk_navTitleFont = [UIFont boldSystemFontOfSize:18.0f];
    self.gk_navBackgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.smoothView];
    [self.smoothView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
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
    return 3;
}

- (id<GKPageSmoothListViewDelegate>)smoothView:(GKPageSmoothView *)smoothView initListAtIndex:(NSInteger)index {
    GKBaseListViewController *listVC = [[GKBaseListViewController alloc] initWithListType:index];
    return listVC;
}

#pragma mark - GKPageSmoothViewDelegate
- (void)smoothView:(GKPageSmoothView *)smoothView listDidAppearAtIndex:(NSInteger)index {
    [self.segmentedView scrollSelectWithIndex:index];
}

#pragma mark - GKCustomSegmentedViewDelegate
- (void)didClickSelectAtIndex:(NSInteger)index {
    [self.smoothView selectListWithIndex:index animated:YES];
}

#pragma mark - lazy
- (GKPageSmoothView *)smoothView {
    if (!_smoothView) {
        _smoothView = [[GKPageSmoothView alloc] initWithDataSource:self];
        _smoothView.delegate = self;
        _smoothView.listCollectionView.gk_openGestureHandle = YES;
    }
    return _smoothView;
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
