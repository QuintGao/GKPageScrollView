//
//  GKPageListContainerView.h
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2019/3/13.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKPageListViewDelegate;

@class GKPageTableView, GKPageListContainerView, GKPageListContainerCollectionView;

/**
 列表容器的类型
 - ScrollView：UIScrollView。优势：没有副作用。劣势：实时的视图内存占用相对大一点，因为加载之后的所有列表视图都在视图层级里面
 - CollectionView：UICollectionView。优势：因为列表被添加到cell上，实时的视图内存占用更少。劣势：因为cell的重用机制的问题，导致列表被移除屏幕外之后，会被放入缓存区，而不存在于视图层级中，如果刚好你的列表使用了下拉刷新视图，在快速切换过程中，就会导致下拉刷新回调不成功的问题。
 */
typedef NS_ENUM(NSUInteger, GKPageListContainerType) {
    GKPageListContainerType_ScrollView,
    GKPageListContainerType_CollectionView
};

@protocol GKPageListContainerScrollViewGestureDelegate <NSObject>

- (BOOL)pageListContainerScrollView:(UIScrollView *)scrollView gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
- (BOOL)pageListContainerScrollView:(UIScrollView *)scrollView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

@end

@protocol GKPageListContainerViewDelegate <NSObject>

/// 返回list的数量
- (NSInteger)numberOfRowsInListContainerView:(GKPageListContainerView *)listContainerView;

/// 返回实现了`GKPageListViewDelegate`协议的UIView或UIViewController
- (id<GKPageListViewDelegate>)listContainerView:(GKPageListContainerView *)listContainerView initListForIndex:(NSInteger)index;

@optional
/// 返回自定义UIScrollView或UICollectionView的class
- (Class)scrollViewClassInListContainerView:(GKPageListContainerView *)listContainerView;

/// 控制能否初始化对应index的列表。有些业务需求，需要在某些情况下才能初始化某些列表，通过该代理实现控制
- (BOOL)listContainerView:(GKPageListContainerView *)listContainerView canInitListAtIndex:(NSInteger)index;

/// 列表显示
- (void)listContainerView:(GKPageListContainerView *)listContainerView listDidAppearAtIndex:(NSInteger)index;

@end

@interface GKPageListContainerView : UIView

@property (nonatomic, assign, readonly) GKPageListContainerType containerType;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

// 已经加载过的列表字典，key是index，value是列表
@property (nonatomic, strong, readonly) NSDictionary <NSNumber *, id<GKPageListViewDelegate>> *validListDict;

// 滚动切换的时候，滚动距离超过一页的多少百分比，就触发列表初始化，默认0.01（即列表显示了一点就触发加载）。范围0~1，开区间不包括0和1
@property (nonatomic, assign) CGFloat initListPercent;

@property (nonatomic, assign, getter=isNestEnabled) BOOL nestEnabled;
@property (nonatomic, weak) id<GKPageListContainerScrollViewGestureDelegate> gestureDelegate;

@property (nonatomic, assign, readonly) NSInteger currentIndex;

- (instancetype)initWithContainerType:(GKPageListContainerType)containerType delegate:(id<GKPageListContainerViewDelegate>)delegate NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

@interface GKPageListContainerView (ListContainer)
- (void)setDefaultSelectedIndex:(NSInteger)index;
- (UIScrollView *)contentScrollView;
- (void)reloadData;
- (void)didClickSelectedItemAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
