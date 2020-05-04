//
//  GKBaseListViewController.h
//  GKPageScrollViewDemo
//
//  Created by gaokun on 2018/12/11.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKBaseTableViewController.h"
#import "GKPageScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKBaseListViewController : GKBaseTableViewController<GKPageListViewDelegate>

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL  shouldLoadData;

@property (nonatomic, copy) void(^scrollToTop)(GKBaseListViewController *listVC,NSIndexPath *indexPath);

- (void)addHeaderRefresh;

@end

NS_ASSUME_NONNULL_END
