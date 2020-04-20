//
//  GKListRefreshViewController.m
//  GKPageScrollViewDemo
//
//  Created by gaokun on 2018/12/11.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKListRefreshViewController.h"

@interface GKListRefreshViewController ()

@end

@implementation GKListRefreshViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitle = @"ListRefresh";
    self.gk_navLineHidden = YES;
    self.gk_navTitleColor = [UIColor whiteColor];
    
    self.pageScrollView.isAllowListRefresh = YES;
    
    // 列表添加下拉刷新
    [self.childVCs enumerateObjectsUsingBlock:^(GKBaseListViewController *listVC, NSUInteger idx, BOOL * _Nonnull stop) {
        [listVC addHeaderRefresh];
    }];
    
    [self.pageScrollView reloadData];
}

@end
