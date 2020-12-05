//
//  GKPageSmoothView.h
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2020/5/4.
//  Copyright © 2020 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@protocol GKPageSmoothViewDelegate <NSObject>

/// 返回页面header视图
/// @param smoothView smoothView description
- (UIView *)headerViewInSmoothView:(GKPageSmoothView *)smoothView;

/// 返回页面分段视图
/// @param smoothView smoothView description
- (UIView *)segmentedViewInSmoothView:(GKPageSmoothView *)smoothView;

/// 返回列表个数
/// @param smoothView smoothView description
- (NSInteger)numberOfListsInSmoothView:(GKPageSmoothView *)smoothView;

/// 根据index初始化一个列表实例，需实现`GKPageSmoothListViewDelegate`代理
/// @param smoothView smoothView description
/// @param index 对应的索引
- (id<GKPageSmoothListViewDelegate>)smoothView:(GKPageSmoothView *)smoothView initListAtIndex:(NSInteger)index;

@optional

/// containerView滑动代理
/// @param smoothView smoothView description
/// @param scrollView containerScrollView
- (void)smoothView:(GKPageSmoothView *)smoothView scrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface GKPageSmoothView : UIView

// 当前已经加载过的可用的列表字典，key是index值，value是对应列表
@property (nonatomic, strong, readonly) NSDictionary <NSNumber *, id<GKPageSmoothListViewDelegate>> *listDict;
@property (nonatomic, strong, readonly) UICollectionView *listCollectionView;
@property (nonatomic, assign) NSInteger defaultSelectedIndex;

/// 吸顶临界高度
@property (nonatomic, assign) CGFloat ceilPointHeight;

/// 是否内部控制指示器的显示与隐藏（默认为NO）
@property (nonatomic, assign) BOOL    isControlVerticalIndicator;

- (instancetype)initWithDelegate:(id<GKPageSmoothViewDelegate>)delegate NS_DESIGNATED_INITIALIZER;
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

@end
