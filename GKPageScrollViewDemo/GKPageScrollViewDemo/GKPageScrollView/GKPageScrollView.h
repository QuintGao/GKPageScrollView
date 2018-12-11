//
//  GKPageScrollView.h
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/26.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPageTableView.h"

@class GKPageScrollView;

@protocol GKPageListViewDelegate <NSObject>

@required

/**
 返回listView内部所持有的UIScrollView或UITableView或UICollectionView

 @return UIScrollView
 */
- (UIScrollView *)listScrollView;

/**
 当listView所持有的UIScrollView或UITableView或UICollectionView的代理方法`scrollViewDidScroll`回调时，
    需要调用该代理方法传入callback

 @param callback `scrollViewDidScroll`回调时调用的callback
 */
- (void)listViewDidScrollCallback:(void (^)(UIScrollView *scrollView))callback;

@end

@protocol GKPageScrollViewDelegate <NSObject>

@required
/**
 返回tableHeaderView

 @param pageScrollView pageScrollView description
 @return tableHeaderView
 */
- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView;

/**
 返回分页视图

 @param pageScrollView pageScrollView description
 @return pageView
 */
- (UIView *)pageViewInPageScrollView:(GKPageScrollView *)pageScrollView;


/**
 返回listView

 @param pageScrollView pageScrollView description
 @return listView
 */
- (NSArray <id <GKPageListViewDelegate>> *)listViewsInPageScrollView:(GKPageScrollView *)pageScrollView;

@optional

/**
 mainTableView开始滑动

 @param scrollView mainTableView
 */
- (void)mainTableViewWillBeginDragging:(UIScrollView *)scrollView;

/**
 mainTableView滑动，用于实现导航栏渐变、头图缩放等

 @param scrollView mainTableView
 @param isMainCanScroll 是否到达临界点，YES表示到达临界点，mainTableView不再滑动，NO表示我到达临界点，mainTableView仍可滑动
 */
- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll;

/**
 mainTableView结束滑动

 @param scrollView mainTableView
 @param decelerate 是否将要减速
 */
- (void)mainTableViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

/**
 mainTableView结束滑动

 @param scrollView mainTableView
 */
- (void)mainTableViewDidEndDecelerating:(UIScrollView *)scrollView;

@end

@interface GKPageScrollView : UIView

@property (nonatomic, weak) id<GKPageScrollViewDelegate> delegate;

@property (nonatomic, strong) GKPageTableView   *mainTableView;

// 吸顶临界点高度（默认值：状态栏+导航栏）
@property (nonatomic, assign) CGFloat           ceilPointHeight;

// 是否允许子列表下拉刷新
@property (nonatomic, assign) BOOL              isAllowListRefresh;

- (instancetype)initWithDelegate:(id <GKPageScrollViewDelegate>)delegate;

/**
 刷新headerView，headerView高度改变时调用
 */
- (void)refreshHeaderView;

/**
 刷新数据，刷新后pageView才能显示出来
 */
- (void)reloadData;

// 处理左右滑动与上下滑动的冲突
- (void)horizonScrollViewWillBeginScroll;
- (void)horizonScrollViewDidEndedScroll;

@end
