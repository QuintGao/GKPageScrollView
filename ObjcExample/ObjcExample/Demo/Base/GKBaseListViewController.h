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

typedef NS_ENUM(NSUInteger, GKBaseListType) {
    GKBaseListType_UITableView          = 0,
    GKBaseListType_UICollectionView     = 1,
    GKBaseListType_UIScrollView         = 2,
    GKBaseListType_WKWebView            = 3
};

@interface GKBaseListViewController : UIViewController<GKPageListViewDelegate>

- (instancetype)initWithListType:(GKBaseListType)listType;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL  shouldLoadData;

@property (nonatomic, copy) void(^scrollToTop)(GKBaseListViewController *listVC,NSIndexPath *indexPath);

- (void)addHeaderRefresh;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
