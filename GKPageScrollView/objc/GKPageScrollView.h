//
//  GKPageScrollView.h
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/26.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPageTableView.h"
#import "GKPageListContainerView.h"

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

@optional

/**
 返回listView
 
 @return UIView
 */
- (UIView *)listView;

@end

@protocol GKPageScrollViewDelegate <NSObject>

@required

/**
 返回tableHeaderView

 @param pageScrollView pageScrollView description
 @return tableHeaderView
 */
- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView;

@optional

#pragma mark - 是否懒加载列表，优先级高于属性isLazyLoadList
/**
 返回是否懒加载列表（据此代理实现懒加载和非懒加载相应方法）
 
 @param pageScrollView paegScrollView description
 @return 是否懒加载
 */
- (BOOL)shouldLazyLoadListInPageScrollView:(GKPageScrollView *)pageScrollView;

#pragma mark - 非懒加载相关方法(`shouldLazyLoadListInPageScrollView`方法返回NO时必须实现下面的方法)
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

#pragma mark - 懒加载相关方法(`shouldLazyLoadListInPageScrollView`方法返回YES时必须实现下面的方法)

/**
 返回中间的segmentedView

 @param pageScrollView pageScrollView description
 @return segmentedView
 */
- (UIView *)segmentedViewInPageScrollView:(GKPageScrollView *)pageScrollView;
/**
 返回列表的数量

 @param pageScrollView pageScrollView description
 @return 列表的数量
 */
- (NSInteger)numberOfListsInPageScrollView:(GKPageScrollView *)pageScrollView;

/**
 根据index初始化一个列表实例，需实现`GKPageListViewDelegate`代理

 @param pageScrollView pageScrollView description
 @param index 对应的索引
 @return 实例对象
 */
- (id<GKPageListViewDelegate>)pageScrollView:(GKPageScrollView *)pageScrollView initListAtIndex:(NSInteger)index;

#pragma mark - mainTableView滚动相关方法

/**
 mainTableView开始滑动

 @param scrollView mainTableView
 */
- (void)mainTableViewWillBeginDragging:(UIScrollView *)scrollView;

/**
 mainTableView滑动，用于实现导航栏渐变、头图缩放等

 @param scrollView mainTableView
 @param isMainCanScroll mainTableView是否可滑动，YES表示可滑动，没有到达临界点，NO表示不可滑动，已到达临界点
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

@property (nonatomic, strong, readonly) GKPageTableView   *mainTableView;

@property (nonatomic, strong, readonly) GKPageListContainerView *listContainerView;

// 当前已经加载过的可用的列表字典，key是index值，value是对应列表
@property (nonatomic, strong, readonly) NSDictionary <NSNumber *, id<GKPageListViewDelegate>> *validListDict;

// 吸顶临界点高度（默认值：状态栏+导航栏）
@property (nonatomic, assign) CGFloat           ceilPointHeight;

// 是否允许子列表下拉刷新
@property (nonatomic, assign) BOOL              isAllowListRefresh;

// 是否在吸顶状态下禁止mainScroll滑动
@property (nonatomic, assign) BOOL              isDisableMainScrollInCeil;

// 是否懒加载列表（默认为NO）
@property (nonatomic, assign) BOOL              isLazyLoadList;

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

/**
 滑动到原点，可用于在吸顶状态下，点击返回按钮，回到原始状态
 */
- (void)scrollToOriginalPoint;

/**
 滑动到临界点，可用于当headerView较长情况下，直接跳到临界点状态
 */
- (void)scrollToCriticalPoint;

// 用于自行处理滑动
- (void)listScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)mainScrollViewDidScroll:(UIScrollView *)scrollView;

@end
