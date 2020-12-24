//
//  GKPageSmoothView.h
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2020/5/4.
//  Copyright © 2020 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GKPageSmoothHoverType) {
    GKPageSmoothHoverTypeNone   = 0,    // 未悬停
    GKPageSmoothHoverTypeTop    = 1,    // 顶部悬停
    GKPageSmoothHoverTypeBottom = 2     // 底部悬停
};

@class GKPageSmoothView;

@protocol GKPageSmoothListViewDelegate <NSObject>

/// 返回listView，如果是vc就返回vc.view,如果是自定义view，就返回view本身
- (UIView *)listView;

/// 返回vc或view内部持有的UIScrollView或UITableView或UICollectionView
- (UIScrollView *)listScrollView;

@optional
- (void)listViewDidAppear;
- (void)listViewDidDisappear;

@end

@protocol GKPageSmoothViewDataSource <NSObject>

/// 返回页面的headerView视图
/// @param smoothView smoothView
- (UIView *)headerViewInSmoothView:(GKPageSmoothView *)smoothView;

/// 返回需要悬浮的分段视图
/// @param smoothView smoothView
- (UIView *)segmentedViewInSmoothView:(GKPageSmoothView *)smoothView;

/// 返回列表个数
/// @param smoothView smoothView
- (NSInteger)numberOfListsInSmoothView:(GKPageSmoothView *)smoothView;

/// 根据index初始化一个列表实例，列表需实现`GKPageSmoothListViewDelegate`代理
/// @param smoothView smoothView
/// @param index 列表索引
- (id<GKPageSmoothListViewDelegate>)smoothView:(GKPageSmoothView *)smoothView initListAtIndex:(NSInteger)index;

@end

@protocol GKPageSmoothViewDelegate <NSObject>

@optional

/// 列表容器滑动代理
/// @param smoothView smoothView
/// @param scrollView containerScrollView
- (void)smoothView:(GKPageSmoothView *)smoothView scrollViewDidScroll:(UIScrollView *)scrollView;

/// 当前列表滑动代理
/// @param smoothView smoothView
/// @param scrollView 当前的列表scrollView
/// @param contentOffset 转换后的contentOffset
- (void)smoothView:(GKPageSmoothView *)smoothView listScrollViewDidScroll:(UIScrollView *)scrollView contentOffset:(CGPoint)contentOffset;

/// 开始拖拽代理
/// @param smoothView smoothView
- (void)smoothViewDragBegan:(GKPageSmoothView *)smoothView;

/// 结束拖拽代理
/// @param smoothView smoothView
/// @param isOnTop 是否通过拖拽滑动到顶部
- (void)smoothViewDragEnded:(GKPageSmoothView *)smoothView isOnTop:(BOOL)isOnTop;

@end

@interface GKPageSmoothView : UIView

/// 代理
@property (nonatomic, weak) id<GKPageSmoothViewDelegate> delegate;

// 当前已经加载过的可用的列表字典，key是index值，value是对应列表
@property (nonatomic, strong, readonly) NSDictionary <NSNumber *, id<GKPageSmoothListViewDelegate>> *listDict;
@property (nonatomic, strong, readonly) UICollectionView *listCollectionView;
@property (nonatomic, assign) NSInteger defaultSelectedIndex;

/// 吸顶临界高度（默认为0）
@property (nonatomic, assign) CGFloat ceilPointHeight;

/// 是否内部控制指示器的显示与隐藏（默认为NO）
@property (nonatomic, assign, getter=isControlVerticalIndicator) BOOL controlVerticalIndicator;

/// 是否支持底部悬停，默认NO，只有当前headerView高度大于pageSmoothView高度时才生效
@property (nonatomic, assign, getter=isBottomHover) BOOL bottomHover;

/// 是否允许底部拖拽，默认NO，当bottomHover为YES时才生效
@property (nonatomic, assign, getter=isAllowDragBottom) BOOL allowDragBottom;

/// 是否允许底部拖拽时滑动scrollView，默认NO
@property (nonatomic, assign, getter=isAllowDragScroll) BOOL allowDragScroll;

/// smoothView悬停类型
@property (nonatomic, assign, readonly) GKPageSmoothHoverType hoverType;

/// 是否通过拖拽滑动到顶部
@property (nonatomic, assign, readonly) BOOL isOnTop;

- (instancetype)initWithDataSource:(id<GKPageSmoothViewDataSource>)dataSource NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/**
 刷新headerView，headerView高度改变时调用
 */
- (void)refreshHeaderView;

/**
 刷新数据，刷新后pageView才能显示出来
 注意：如果需要动态改变headerView的高度，请在refreshHeaderView后在调用reloadData方法
 */
- (void)reloadData;

/// 显示在顶部
- (void)showingOnTop;

/// 显示在底部
- (void)showingOnBottom;

@end
