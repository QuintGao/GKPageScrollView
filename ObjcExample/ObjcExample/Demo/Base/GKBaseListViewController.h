//
//  GKBaseListViewController.h
//  GKPageScrollViewDemo
//
//  Created by QuintGao on 2018/12/11.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKBaseTableViewController.h"
#import <GKPageScrollView/GKPageScrollView.h>
#import <GKPageSmoothView/GKPageSmoothView.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKBaseListType) {
    GKBaseListType_UITableView          = 0,
    GKBaseListType_UICollectionView     = 1,
    GKBaseListType_UIScrollView         = 2,
    GKBaseListType_WKWebView            = 3
};

@interface GKBaseListViewController : UIViewController<GKPageListViewDelegate, GKPageSmoothListViewDelegate>

- (instancetype)initWithListType:(GKBaseListType)listType;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL shouldLoadData;

@property (nonatomic, assign) BOOL disableLoadMore;

@property (nonatomic, copy) void(^listItemClick)(GKBaseListViewController *listVC, NSIndexPath *indexPath);

- (void)addHeaderRefresh;

- (void)reloadData;
- (void)refreshWithCompletion:(nullable void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
