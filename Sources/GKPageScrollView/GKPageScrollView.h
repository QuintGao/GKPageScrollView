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
 返回listView，懒加载方式时必传
 
 @return UIView
 */
- (UIView *)listView;

// 列表生命周期，懒加载方式时有效
- (void)listWillAppear;
- (void)listDidAppear;
- (void)listWillDisappear;
- (void)listDidDisappear;

/// 当子列表的scrollView需要改变位置时返回YES
- (BOOL)isListScrollViewNeedScroll;

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

#pragma mark - pageScrollView刷新回调
- (void)pageScrollViewReloadCell:(GKPageScrollView *)pageScrollView;

// 更新cell属性，可自定义cell的背景色等
- (void)pageScrollView:(GKPageScrollView *)pageScrollView updateCell:(UITableViewCell *)cell;

#pragma mark - mainTableView滚动相关方法

/// mainTableView开始滑动
/// @param scrollView mainTableView
- (void)mainTableViewWillBeginDragging:(UIScrollView *)scrollView;

/// mainTableView滑动，用于实现导航栏渐变、头图缩放等功能
/// @param scrollView mainTableView
/// @param isMainCanScroll mainTableView是否可以滑动，YES表示可滑动，没有到达临界点，NO表示不可滑动，已到达临界点
- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll;

/// mainTableView结束滚动
/// @param scrollView mainTableView
/// @param decelerate 是否将要减速
- (void)mainTableViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

/// mainTableView结束滚动
/// @param scrollView mainTableView
- (void)mainTableViewDidEndDecelerating:(UIScrollView *)scrollView;

/// mainTableView结束动画
/// @param scrollView mainTableView
- (void)mainTableViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

// 返回自定义UIScrollView或UICollectionView的class
- (Class)scrollViewClassInListContainerViewInPageScrollView:(GKPageScrollView *)pageScrollView;

// 控制能否初始化index对应的列表。有些业务需求，需要在某些情况下才允许初始化列表
- (BOOL)pageScrollViewListContainerView:(GKPageListContainerView *)containerView canInitListAtIndex:(NSInteger)index;

@end

@interface GKPageScrollView : UIView

/// 主列表
@property (nonatomic, strong, readonly) GKPageTableView *mainTableView;

/// 包裹segmentedView和列表容器的view
@property (nonatomic, weak, readonly) UIView *pageView;

/// 当前滑动的子列表
@property (nonatomic, weak, readonly) UIScrollView *currentListScrollView;

/// 懒加载形式的容器
@property (nonatomic, strong, readonly) GKPageListContainerView *listContainerView;

/// 懒加载容器的类型，默认UICollectionView
@property (nonatomic, assign) GKPageListContainerType listContainerType;

// 当前已经加载过的可用的列表字典，key是index值，value是对应列表
@property (nonatomic, strong, readonly) NSDictionary <NSNumber *, id<GKPageListViewDelegate>> *validListDict;

// 横向滑动的scrollView列表，用于解决左右滑动与上下滑动手势冲突
@property (nonatomic, strong) NSArray *horizontalScrollViewList;

// 吸顶临界点高度（默认值：状态栏+导航栏）
@property (nonatomic, assign) CGFloat ceilPointHeight;

/// 是否禁止主页滑动，默认NO
@property (nonatomic, assign, getter=isMainScrollDisabled) BOOL mainScrollDisabled;

// 是否允许子列表下拉刷新
@property (nonatomic, assign, getter=isAllowListRefresh) BOOL allowListRefresh;

// 是否在吸顶状态下禁止mainScroll滑动
@property (nonatomic, assign, getter=isDisableMainScrollInCeil) BOOL disableMainScrollInCeil;

// 是否懒加载列表（默认为NO）
@property (nonatomic, assign, getter=isLazyLoadList) BOOL lazyLoadList;

// 是否内部控制指示器的显示与隐藏（默认为NO）
@property (nonatomic, assign, getter=isControlVerticalIndicator) BOOL controlVerticalIndicator;

// 列表容器在UITableViewFooter中显示（默认NO）
@property (nonatomic, assign, getter=isShowInFooter) BOOL showInFooter;

// 当调用refreshHeaderView方法后，是否恢复到初始位置，默认NO
@property (nonatomic, assign, getter=isRestoreWhenRefreshHeader) BOOL restoreWhenRefreshHeader;

// 当调用refreshHeaderView方法后，是否保持临界状态，默认NO
@property (nonatomic, assign, getter=isKeepCriticalWhenRefreshHeader) BOOL keepCriticalWhenRefreshHeader;

// 自动查找横向scrollView，设置为YES则不用传入horizontalScrollViewList，默认NO
@property (nonatomic, assign, getter=isAutoFindHorizontalScrollView) BOOL autoFindHorizontalScrollView;

// 内部属性，尽量不要修改
// 是否滑动到临界点，可有偏差
@property (nonatomic, assign) BOOL isCriticalPoint;
// 是否到达临界点，无偏差
@property (nonatomic, assign) BOOL isCeilPoint;
// mainTableView是否可滑动
@property (nonatomic, assign) BOOL isMainCanScroll;
// listScrollView是否可滑动
@property (nonatomic, assign) BOOL isListCanScroll;

- (instancetype)initWithDelegate:(id<GKPageScrollViewDelegate>)delegate NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// 刷新headerView，headerView高度改变时调用
- (void)refreshHeaderView;

/// 刷新segmentedView，segmentedView高度变化时调用
- (void)refreshSegmentedView;

/// 刷新数据，刷新后pageView才能显示出来
- (void)reloadData;

// 处理左右滑动与上下滑动的冲突
- (void)horizonScrollViewWillBeginScroll;
- (void)horizonScrollViewDidEndedScroll;

// 滑动到原点，可用于在吸顶状态下，点击返回按钮，回到原始状态
- (void)scrollToOriginalPoint;
- (void)scrollToOriginalPointAnimated:(BOOL)animated;

// 滑动到临界点，可用于当headerView较长情况下，直接跳到临界点状态
- (void)scrollToCriticalPoint;
- (void)scrollToCriticalPointAnimated:(BOOL)animated;

// 用于自行处理滑动
- (void)listScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)mainScrollViewDidScroll:(UIScrollView *)scrollView;

@end
