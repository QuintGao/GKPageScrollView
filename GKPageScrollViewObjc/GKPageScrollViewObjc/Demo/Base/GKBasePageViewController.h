//
//  GKBasePageViewController.h
//  GKPageScrollViewDemo
//
//  Created by gaokun on 2018/12/11.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDemoBaseViewController.h"
#import "GKPageScrollView.h"
#import "GKBaseListViewController.h"
#import "JXCategoryView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKBasePageViewController : GKDemoBaseViewController<GKPageScrollViewDelegate>

// pageScrollView
@property (nonatomic, strong) GKPageScrollView  *pageScrollView;

@property (nonatomic, strong) JXCategoryTitleView   *segmentView;
@property (nonatomic, strong) UIScrollView          *contentScrollView;

@property (nonatomic, strong) NSArray           *childVCs;

@end

NS_ASSUME_NONNULL_END
