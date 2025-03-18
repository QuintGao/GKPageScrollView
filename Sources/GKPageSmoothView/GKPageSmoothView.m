//
//  GKPageSmoothView.m
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2020/5/4.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKPageSmoothView.h"

static NSString *const GKPageSmoothViewCellID = @"smoothViewCell";

@interface GKPageSmoothCollectionView : UICollectionView<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *headerContainerView;

@end

@implementation GKPageSmoothCollectionView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.headerContainerView];
    if (CGRectContainsPoint(self.headerContainerView.bounds, point)) {
        return NO;
    }
    return YES;
}

@end

@interface GKPageSmoothView()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<GKPageSmoothViewDataSource> dataSource;
@property (nonatomic, strong) GKPageSmoothCollectionView  *listCollectionView;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, id<GKPageSmoothListViewDelegate>> *listDict;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIView *> *listHeaderDict;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) GKPageSmoothHoverType hoverType;

@property (nonatomic, strong) UIView *headerContainerView;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UIView *segmentedView;
@property (nonatomic, weak) UIScrollView *currentListScrollView;

@property (nonatomic, strong) UIView *bottomContainerView;

@property (nonatomic, assign) BOOL syncListContentOffsetEnabled;
@property (nonatomic, assign) CGFloat currentHeaderContainerViewY;

@property (nonatomic, assign) CGFloat headerContainerHeight;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat segmentedHeight;
@property (nonatomic, assign) CGFloat currentListInitializeContentOffsetY;

@property (nonatomic, assign) BOOL      isLoaded;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL       isDragScrollView;
@property (nonatomic, assign) CGFloat    lastTransitionY;
@property (nonatomic, assign) BOOL       isOnTop;

@property (nonatomic, assign) CGFloat    currentListPanBeganContentOffsetY;
@property (nonatomic, assign) BOOL       originBounces;
@property (nonatomic, assign) BOOL       originShowsVerticalScrollIndicator;

@property (nonatomic, assign) BOOL       isScroll;
@property (nonatomic, assign) NSInteger  willAppearIndex;
@property (nonatomic, assign) NSInteger  willDisappearIndex;

@property (nonatomic, assign) BOOL       isChangeOffset;

@end

@implementation GKPageSmoothView

- (instancetype)initWithDataSource:(id<GKPageSmoothViewDataSource>)dataSource {
    if (self = [super initWithFrame:CGRectZero]) {
        self.dataSource = dataSource;
        _listDict = [NSMutableDictionary dictionary];
        _listHeaderDict = [NSMutableDictionary dictionary];
        _ceilPointHeight = 0;
        _willAppearIndex = -1;
        _willDisappearIndex = -1;
        _resetPosition = YES;
        
        [self addSubview:self.listCollectionView];
        [self addSubview:self.headerContainerView];
        [self refreshHeaderView];
    }
    return self;
}

- (void)dealloc {
    for (id<GKPageSmoothListViewDelegate> listItem in self.listDict.allValues) {
        [listItem.listScrollView removeObserver:self forKeyPath:@"contentOffset"];
        [listItem.listScrollView removeObserver:self forKeyPath:@"contentSize"];
    }
    
    [self.headerView removeFromSuperview];
    [self.segmentedView removeFromSuperview];
    self.listCollectionView.dataSource = nil;
    self.listCollectionView.delegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isMainScrollDisabled) {
        CGRect frame = self.frame;
        frame.origin.y = self.headerContainerHeight;
        frame.size.height -= self.headerContainerHeight;
        [self refreshListFrame:frame];
        self.listCollectionView.frame = frame;
    }else {
        if (self.listCollectionView.superview == self) {
            [self refreshListFrame:self.bounds];
            self.listCollectionView.frame = self.bounds;
        }else {
            CGRect frame = self.bottomContainerView.frame;
            frame.size.width = self.frame.size.width;
            frame.size.height = self.frame.size.height - self.ceilPointHeight;
            self.bottomContainerView.frame = frame;
            
            frame = self.listCollectionView.frame;
            frame.origin.y = self.segmentedHeight;
            frame.size.width = self.frame.size.width;
            frame.size.height = self.bottomContainerView.frame.size.height - self.segmentedHeight;
            [self refreshListFrame:frame];
            self.listCollectionView.frame = frame;
        }
    }
    
    [self.listHeaderDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIView * _Nonnull obj, BOOL * _Nonnull stop) {
        CGRect frame = obj.frame;
        frame.origin.y = -self.headerContainerHeight;
        frame.size.height = self.headerContainerHeight;
        obj.frame = frame;
    }];
}

- (void)refreshListFrame:(CGRect)frame {
    for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
        CGRect f = list.listView.frame;
        if ((f.size.width != 0 && f.size.width != frame.size.width) || (f.size.height != 0 && f.size.height != frame.size.height)) {
            f.size.width = frame.size.width;
            f.size.height = frame.size.height;
            list.listView.frame = f;
            [self.listCollectionView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.08 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isChangeOffset = YES;
                [self setScrollView:self.listCollectionView offset:CGPointMake(self.currentIndex * frame.size.width, 0)];
            });
        }
    }
}

- (void)refreshHeaderView {
    [self loadHeaderAndSegmentedView];
    [self refreshHeaderContainerView];
}

- (void)refreshSegmentedView {
    self.segmentedView = [self.dataSource segmentedViewInSmoothView:self];
    [self.headerContainerView addSubview:self.segmentedView];

    [self refreshHeaderContainerHeight];
    [self refreshHeaderContainerView];
}

- (void)reloadData {
    self.currentListScrollView = nil;
    self.syncListContentOffsetEnabled = NO;
    self.currentHeaderContainerViewY = 0;
    self.isLoaded = YES;
    
    [self.listHeaderDict.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.listHeaderDict removeAllObjects];
    
    for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
        [list.listScrollView removeObserver:self forKeyPath:@"contentOffset"];
        [list.listScrollView removeObserver:self forKeyPath:@"contentSize"];
        [list.listView removeFromSuperview];
    }
    [_listDict removeAllObjects];
    
    __weak __typeof(self) weakSelf = self;
    [self refreshWidthCompletion:^(CGSize size) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self setScrollView:self.listCollectionView offset:CGPointMake(size.width * self.currentIndex, 0)];
        [self.listCollectionView reloadData];
        
        // 首次加载
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self listWillAppear:self.currentIndex];
            [self listDidAppear:self.currentIndex];
        });
    }];
}

- (void)scrollToOriginalPoint {
    [self scrollToOriginalPointAnimated:YES];
}

- (void)scrollToOriginalPointAnimated:(BOOL)animated {
    [self.currentListScrollView setContentOffset:CGPointMake(0, -self.headerContainerHeight) animated:animated];
}

- (void)scrollToCriticalPoint {
    [self scrollToCriticalPointAnimated:YES];
}

- (void)scrollToCriticalPointAnimated:(BOOL)animated {
    [self.currentListScrollView setContentOffset:CGPointMake(0, -(self.segmentedHeight+self.ceilPointHeight)) animated:animated];
}

- (void)showingOnTop {
    if (self.bottomContainerView.isHidden) return;
    [self dragBegan];
    [self dragShowing];
}

- (void)showingOnBottom {
    if (self.bottomContainerView.isHidden) return;
    [self dragDismiss];
}

- (void)selectListWithIndex:(NSInteger)index animated:(BOOL)animated {
    if (self.currentIndex == index) {
        return;
    }
    
    CGPoint offset = CGPointMake(index * self.listCollectionView.bounds.size.width, 0);
    [self.listCollectionView setContentOffset:offset animated:animated];
    [self listWillDisappear:self.currentIndex];
    [self listDidDisappear:self.currentIndex];
    [self listWillAppear:index];
    [self listDidAppear:index];
}

- (void)setDefaultSelectedIndex:(NSInteger)defaultSelectedIndex {
    _defaultSelectedIndex = defaultSelectedIndex;
    self.currentIndex = defaultSelectedIndex;
}

- (void)setBottomHover:(BOOL)bottomHover {
    _bottomHover = bottomHover;
    
    if (bottomHover) {
        __weak __typeof(self) weakSelf = self;
        [self refreshWidthCompletion:^(CGSize size) {
            __strong __typeof(weakSelf) self = weakSelf;
            self.bottomContainerView.frame = CGRectMake(0, size.height - self.segmentedHeight, size.width, size.height - self.ceilPointHeight);
            [self addSubview:self.bottomContainerView];
            
            if (self.headerHeight > size.height) {
                self.segmentedView.frame = CGRectMake(0, 0, size.width, self.segmentedHeight);
                [self.bottomContainerView addSubview:self.segmentedView];
            }
        }];
    }else {
        [self.bottomContainerView removeFromSuperview];
    }
}

- (void)setAllowDragBottom:(BOOL)allowDragBottom {
    _allowDragBottom = allowDragBottom;
    
    if (self.bottomHover) {
        if (allowDragBottom) {
            [self.bottomContainerView addGestureRecognizer:self.panGesture];
        }else {
            [self.bottomContainerView removeGestureRecognizer:self.panGesture];
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.isLoaded ? 1 : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfListsInSmoothView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKPageSmoothViewCellID forIndexPath:indexPath];
    id<GKPageSmoothListViewDelegate> list = self.listDict[@(indexPath.item)];
    if (list == nil) {
        list = [self.dataSource smoothView:self initListAtIndex:indexPath.item];
        if ([list isKindOfClass:UIViewController.class]) {
            UIResponder *next = self.superview;
            while (next != nil) {
                if ([next isKindOfClass:UIViewController.class]) {
                    [((UIViewController *)next) addChildViewController:(UIViewController *)list];
                    break;
                }
                next = next.nextResponder;
            }
        }
        _listDict[@(indexPath.item)] = list;
        [list.listView setNeedsLayout];
        
        UIScrollView *listScrollView = list.listScrollView;
        if ([listScrollView isKindOfClass:[UITableView class]]) {
            ((UITableView *)listScrollView).estimatedRowHeight = 0;
            ((UITableView *)listScrollView).estimatedSectionHeaderHeight = 0;
            ((UITableView *)listScrollView).estimatedSectionFooterHeight = 0;
        }
        if (@available(iOS 11.0, *)) {
            listScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        if (listScrollView) {
            CGFloat minContentSizeHeight = self.bounds.size.height - self.segmentedHeight - self.ceilPointHeight;
            if (listScrollView.contentSize.height < minContentSizeHeight && self.isHoldUpScrollView) {
                listScrollView.contentSize = CGSizeMake(self.bounds.size.width, minContentSizeHeight);
            }
        }
        
        if (!self.isMainScrollDisabled) {
            if (!self.isOnTop) {
                UIEdgeInsets insets = listScrollView.contentInset;
                insets.top = self.headerContainerHeight;
                listScrollView.contentInset = insets;
                self.currentListInitializeContentOffsetY = -listScrollView.contentInset.top + MIN(-self.currentHeaderContainerViewY, (self.headerHeight - self.ceilPointHeight));
                [self setScrollView:listScrollView offset:CGPointMake(0, self.currentListInitializeContentOffsetY)];
            }
            UIView *listHeader = [[UIView alloc] initWithFrame:CGRectMake(0, -self.headerContainerHeight, self.bounds.size.width, self.headerContainerHeight)];
            [listScrollView addSubview:listHeader];
            
            if (!self.isOnTop) {
                if (!collectionView.isDragging) {
                    CGFloat indexPercent = collectionView.contentOffset.x/collectionView.bounds.size.width;
                    NSInteger index = floor(indexPercent);
                    [self horizontalScrollDidEndAtIndex:index];
                }else if (self.headerContainerView.superview == nil) {
                    [listHeader addSubview:self.headerContainerView];
                }
            }
            self.listHeaderDict[@(indexPath.item)] = listHeader;
        }
        
        [listScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [listScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        // bug fix #69 修复首次进入时可能出现的headerView无法下拉的问题
        [listScrollView setContentOffset:listScrollView.contentOffset];
    }
    for (id<GKPageSmoothListViewDelegate> listItem in self.listDict.allValues) {
        listItem.listScrollView.scrollsToTop = (listItem == list);
    }
    
    UIView *listView = list.listView;
    if (listView != nil && listView.superview != cell.contentView) {
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        listView.frame = cell.bounds;
        [cell.contentView addSubview:listView];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
        list.listView.frame = (CGRect){{0, 0}, self.listCollectionView.bounds.size};
    }
    return self.listCollectionView.bounds.size;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.panGesture.enabled = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isChangeOffset) {
        self.isChangeOffset = NO;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(smoothView:scrollViewDidScroll:)]) {
        [self.delegate smoothView:self scrollViewDidScroll:scrollView];
    }
    
    CGFloat indexPercent = scrollView.contentOffset.x/scrollView.bounds.size.width;
    NSInteger index = floor(indexPercent);
    self.isScroll = YES;
    
    if (!self.isMainScrollDisabled) {
        if (!self.isOnTop) {
            UIScrollView *listScrollView = self.listDict[@(index)].listScrollView;
            if (index != self.currentIndex && indexPercent - index == 0 && !(scrollView.isDragging || scrollView.isDecelerating) && listScrollView.contentOffset.y <= -(self.segmentedHeight + self.ceilPointHeight)) {
                [self horizontalScrollDidEndAtIndex:index];
            }else {
                // 左右滚动的时候，把headerContainerView添加到self，达到悬浮的效果
                if (self.headerContainerView.superview != self) {
                    CGRect frame = self.headerContainerView.frame;
                    frame.origin.y = self.currentHeaderContainerViewY;
                    self.headerContainerView.frame = frame;
                    [self addSubview:self.headerContainerView];
                }
            }
        }
    }
    
    if (!scrollView.isDragging && !scrollView.isTracking && !scrollView.isDecelerating) {
        return;
    }
    CGFloat ratio = scrollView.contentOffset.x/scrollView.bounds.size.width;
    NSInteger maxCount = round(scrollView.contentSize.width/scrollView.bounds.size.width);
    NSInteger leftIndex = floorf(ratio);
    leftIndex = MAX(0, MIN(maxCount - 1, leftIndex));
    NSInteger rightIndex = leftIndex + 1;
    if (ratio < 0 || rightIndex >= maxCount) {
        [self listDidAppearOrDisappear:scrollView];
        return;
    }
    if (rightIndex == self.currentIndex) {
        //当前选中的在右边，用户正在从右边往左边滑动
        if (self.listDict[@(leftIndex)] != nil) {
            if (self.willAppearIndex == -1) {
                self.willAppearIndex = leftIndex;
                [self listWillAppear:self.willAppearIndex];
            }
        }
        if (self.willDisappearIndex == -1) {
            self.willDisappearIndex = rightIndex;
            [self listWillDisappear:self.willDisappearIndex];
        }
    }else {
        //当前选中的在左边，用户正在从左边往右边滑动
        if (self.listDict[@(rightIndex)] != nil) {
            if (self.willAppearIndex == -1) {
                self.willAppearIndex = rightIndex;
                [self listWillAppear:self.willAppearIndex];
            }
        }
        if (self.willDisappearIndex == -1) {
            self.willDisappearIndex = leftIndex;
            [self listWillDisappear:self.willDisappearIndex];
        }
    }
    [self listDidAppearOrDisappear:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // 滑动到一半又取消滑动处理
        if (self.willDisappearIndex != -1) {
            [self listWillAppear:self.willDisappearIndex];
            [self listWillDisappear:self.willAppearIndex];
            [self listDidAppear:self.willDisappearIndex];
            [self listDidDisappear:self.willAppearIndex];
            self.willDisappearIndex = -1;
            self.willAppearIndex = -1;
        }
    }
    if (self.isMainScrollDisabled) return;
    if (!decelerate) {
        NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
        [self horizontalScrollDidEndAtIndex:index];
    }
    self.panGesture.enabled = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 滑动到一半又取消滑动处理
    if (self.willDisappearIndex != -1) {
        [self listWillAppear:self.willDisappearIndex];
        [self listWillDisappear:self.willAppearIndex];
        [self listDidAppear:self.willDisappearIndex];
        [self listDidDisappear:self.willAppearIndex];
        self.willDisappearIndex = -1;
        self.willAppearIndex = -1;
    }
    if (self.isMainScrollDisabled) return;
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self horizontalScrollDidEndAtIndex:index];
    self.panGesture.enabled = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (!self.isLoaded) return;
    // 修复快速闪烁问题
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.currentIndex = index;
    self.currentListScrollView = self.listDict[@(index)].listScrollView;
    self.isScroll = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.isScroll && self.headerContainerView.superview == self) {
            [self horizontalScrollDidEndAtIndex:index];
        }
    });
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        if (scrollView && scrollView.window) {
            [self listScrollViewDidScroll:scrollView];
        }
    }else if ([keyPath isEqualToString:@"contentSize"]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        if (scrollView && scrollView.window) {
            CGFloat minContentSizeHeight = self.bounds.size.height - self.segmentedHeight - self.ceilPointHeight;
            CGFloat contentH = scrollView.contentSize.height;
            if (minContentSizeHeight > contentH && self.isHoldUpScrollView) {
                scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, minContentSizeHeight);
                // 新的scrollView第一次加载的时候重置contentOffset
                if (self.currentListScrollView != nil && scrollView != self.currentListScrollView) {
                    if (!CGSizeEqualToSize(scrollView.contentSize, CGSizeZero) && !self.isOnTop) {
                        [self setScrollView:scrollView offset:CGPointMake(0, self.currentListInitializeContentOffsetY)];
                    }
                }
            }else {
                BOOL shouldReset = YES;
                for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
                    if (list.listScrollView == scrollView && [list respondsToSelector:@selector(listScrollViewShouldReset)]) {
                        shouldReset = [list listScrollViewShouldReset];
                    }
                }
                
                if (minContentSizeHeight > contentH && shouldReset && !self.isMainScrollDisabled) {
                    [self setScrollView:scrollView offset:CGPointMake(scrollView.contentOffset.x, -self.headerContainerHeight)];
                    [self listScrollViewDidScroll:scrollView];
                }
            }
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Gesture
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(smoothViewDragBegan:)]) {
            [self.delegate smoothViewDragBegan:self];
        }
        [self dragBegan];
        
        // 记录scrollView的某些属性
        self.originBounces = self.scrollView.bounces;
        self.originShowsVerticalScrollIndicator = self.scrollView.showsVerticalScrollIndicator;
        
        // bug fix #47，当UIScrollView向下滚动的时候，向下拖拽完成手势操作导致的错乱问题
        if (self.currentListScrollView.isDecelerating) {
            [self.currentListScrollView setContentOffset:self.currentListScrollView.contentOffset animated:NO];
        }
    }
    
    CGPoint translation = [panGesture translationInView:self.bottomContainerView];
    if (self.isDragScrollView) {
        [self allowScrolling:self.scrollView];
        // 当UIScrollView在最顶部时，处理视图的滑动
        if (self.scrollView.contentOffset.y <= 0) {
            if (translation.y > 0) { // 向下拖拽
                [self forbidScrolling:self.scrollView];
                self.isDragScrollView = NO;
                
                CGRect frame = self.bottomContainerView.frame;
                frame.origin.y += translation.y;
                self.bottomContainerView.frame = frame;
                
                if (!self.isAllowDragScroll) {
                    self.scrollView.panGestureRecognizer.enabled = NO;
                    self.scrollView.panGestureRecognizer.enabled = YES;
                }
            }
        }
    }else {
        CGFloat offsetY = self.scrollView.contentOffset.y;
        CGFloat ceilPointY = self.ceilPointHeight;
        
        if (offsetY <= 0) {
            [self forbidScrolling:self.scrollView];
            if (translation.y > 0) { // 向下拖拽
                CGRect frame = self.bottomContainerView.frame;
                frame.origin.y += translation.y;
                self.bottomContainerView.frame = frame;
            }else if (translation.y < 0 && self.bottomContainerView.frame.origin.y > ceilPointY) { // 向上拖拽
                CGRect frame = self.bottomContainerView.frame;
                frame.origin.y = MAX((self.bottomContainerView.frame.origin.y + translation.y), ceilPointY);
                self.bottomContainerView.frame = frame;
            }
        }else {
            if (translation.y < 0 && self.bottomContainerView.frame.origin.y > ceilPointY) {
                CGRect frame = self.bottomContainerView.frame;
                frame.origin.y = MAX((self.bottomContainerView.frame.origin.y + translation.y), ceilPointY);
                self.bottomContainerView.frame = frame;
            }
            
            if (self.bottomContainerView.frame.origin.y > ceilPointY) {
                [self forbidScrolling:self.scrollView];
            }else {
                [self allowScrolling:self.scrollView];
            }
        }
    }
    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [panGesture velocityInView:self.bottomContainerView];
        if (velocity.y < 0) { // 上滑
            if (fabs(self.lastTransitionY) > 5 && self.isDragScrollView == NO) {
                [self dragShowing];
            }else {
                if (self.bottomContainerView.frame.origin.y > (self.ceilPointHeight + self.bottomContainerView.frame.size.height / 2)) {
                    [self dragDismiss];
                }else {
                    [self dragShowing];
                }
            }
        }else { // 下滑
            if (fabs(self.lastTransitionY) > 5 && self.isDragScrollView == NO && !self.scrollView.isDecelerating) {
                [self dragDismiss];
            }else {
                if (self.bottomContainerView.frame.origin.y > (self.ceilPointHeight + self.bottomContainerView.frame.size.height / 2)) {
                    [self dragDismiss];
                }else {
                    [self dragShowing];
                }
            }
        }
        
        [self allowScrolling:self.scrollView];
        self.isDragScrollView = NO;
        self.scrollView = nil;
    }
    
    [panGesture setTranslation:CGPointZero inView:self.bottomContainerView];
    self.lastTransitionY = translation.y;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.panGesture) {
        UIView *touchView = touch.view;
        while (touchView != nil) {
            if (touchView == self.currentListScrollView) {
                self.scrollView = (UIScrollView *)touchView;
                self.isDragScrollView = YES;
                break;
            }else if (touchView == self.bottomContainerView) {
                self.isDragScrollView = NO;
                break;
            }
            touchView = (UIView *)[touchView nextResponder];
        }
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // 左右滑动时禁止上下滑动
    CGPoint transition = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (transition.x != 0) return NO;
    return YES;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.panGesture) {
        if (otherGestureRecognizer == self.scrollView.panGestureRecognizer) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Private Methods
- (void)listWillAppear:(NSInteger)index {
    if (![self checkIndexValid:index]) return;
    id<GKPageSmoothListViewDelegate> list = _listDict[@(index)];
    
    if (list && [list respondsToSelector:@selector(listViewWillAppear)]) {
        [list listViewWillAppear];
    }
}

- (void)listDidAppear:(NSInteger)index {
    if (![self checkIndexValid:index]) {
        return;
    }
    self.currentIndex = index;
    id<GKPageSmoothListViewDelegate> list = _listDict[@(index)];
    if (list && [list respondsToSelector:@selector(listViewDidAppear)]) {
        [list listViewDidAppear];
    }
    if ([self.delegate respondsToSelector:@selector(smoothView:listDidAppearAtIndex:)]) {
        [self.delegate smoothView:self listDidAppearAtIndex:index];
    }
}

- (void)listWillDisappear:(NSInteger)index {
    if (![self checkIndexValid:index]) {
        return;
    }
    id<GKPageSmoothListViewDelegate> list = _listDict[@(index)];
    if (list && [list respondsToSelector:@selector(listViewWillDisappear)]) {
        [list listViewWillDisappear];
    }
}

- (void)listDidDisappear:(NSInteger)index {
    if (![self checkIndexValid:index]) {
        return;
    }
    id<GKPageSmoothListViewDelegate> list = _listDict[@(index)];
    if (list && [list respondsToSelector:@selector(listViewDidDisappear)]) {
        [list listViewDidDisappear];
    }
}

- (BOOL)checkIndexValid:(NSInteger)index {
    NSUInteger count = [self.dataSource numberOfListsInSmoothView:self];
    if (count <= 0 || index >= count) {
        return NO;
    }
    return YES;
}

- (void)listDidAppearOrDisappear:(UIScrollView *)scrollView {
    CGFloat currentIndexPercent = scrollView.contentOffset.x/scrollView.bounds.size.width;
    if (self.willAppearIndex != -1 || self.willDisappearIndex != -1) {
        NSInteger disappearIndex = self.willDisappearIndex;
        NSInteger appearIndex = self.willAppearIndex;
        if (self.willAppearIndex > self.willDisappearIndex) {
            //将要出现的列表在右边
            if (currentIndexPercent >= self.willAppearIndex) {
                self.willDisappearIndex = -1;
                self.willAppearIndex = -1;
                [self listDidDisappear:disappearIndex];
                [self listDidAppear:appearIndex];
            }
        }else {
            //将要出现的列表在左边
            if (currentIndexPercent <= self.willAppearIndex) {
                self.willDisappearIndex = -1;
                self.willAppearIndex = -1;
                [self listDidDisappear:disappearIndex];
                [self listDidAppear:appearIndex];
            }
        }
    }
}

- (void)listScrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isMainScrollDisabled) {
        if ([self.delegate respondsToSelector:@selector(smoothView:listScrollViewDidScroll:contentOffset:)]) {
            [self.delegate smoothView:self listScrollViewDidScroll:scrollView contentOffset:scrollView.contentOffset];
        }
        return;
    }
    
    if (self.listCollectionView.isDragging || self.listCollectionView.isDecelerating) return;
    
    if (self.isOnTop) { // 在顶部时无需处理headerView
        self.hoverType = GKPageSmoothHoverTypeTop;
        // 取消scrollView下滑时的弹性效果
        // buf fix #47，iOS12及以下系统isDragging会出现不准确的情况，所以这里改为用isTracking判断
        if (self.isAllowDragScroll && (scrollView.isTracking || scrollView.isDecelerating)) {
            if (scrollView.contentOffset.y < 0) {
                [self setScrollView:scrollView offset:CGPointZero];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(smoothView:listScrollViewDidScroll:contentOffset:)]) {
            [self.delegate smoothView:self listScrollViewDidScroll:scrollView contentOffset:scrollView.contentOffset];
        }
    }else { // 不在顶部，通过列表scrollView滑动确定悬浮位置
        NSInteger listIndex = [self listIndexForListScrollView:scrollView];
        if (listIndex != self.currentIndex) return;
        self.currentListScrollView = scrollView;
        CGFloat contentOffsetY = scrollView.contentOffset.y + self.headerContainerHeight;
        
        if (contentOffsetY < (self.headerHeight - self.ceilPointHeight)) {
            self.hoverType = GKPageSmoothHoverTypeNone;
            self.syncListContentOffsetEnabled = YES;
            self.currentHeaderContainerViewY = -contentOffsetY;
            for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
                if (list.listScrollView != scrollView) {
                    [self setScrollView:list.listScrollView offset:scrollView.contentOffset];
                }
            }
            UIView *listHeader = [self listHeaderForListScrollView:scrollView];
            if (self.headerContainerView.superview != listHeader) {
                CGRect frame = self.headerContainerView.frame;
                frame.origin.y = 0;
                self.headerContainerView.frame = frame;
                [listHeader addSubview:self.headerContainerView];
            }
            
            if (self.isControlVerticalIndicator && self.ceilPointHeight != 0) {
                self.currentListScrollView.showsVerticalScrollIndicator = NO;
            }
            
            if (self.isBottomHover) {
                if (contentOffsetY < (self.headerContainerHeight - self.frame.size.height)) {
                    self.hoverType = GKPageSmoothHoverTypeBottom;
                    if (self.segmentedView.superview != self.bottomContainerView) {
                        self.bottomContainerView.hidden = NO;
                        CGRect frame = self.segmentedView.frame;
                        frame.origin.y = 0;
                        self.segmentedView.frame = frame;
                        [self.bottomContainerView addSubview:self.segmentedView];
                    }
                }else {
                    if (self.segmentedView.superview != self.headerContainerView) {
                        self.bottomContainerView.hidden = YES;
                        CGRect frame = self.segmentedView.frame;
                        frame.origin.y = self.headerHeight;
                        self.segmentedView.frame = frame;
                        [self.headerContainerView addSubview:self.segmentedView];
                    }
                }
            }
        }else {
            self.hoverType = GKPageSmoothHoverTypeTop;
            if (self.headerContainerView.superview != self) {
                CGRect frame = self.headerContainerView.frame;
                frame.origin.y = - (self.headerHeight - self.ceilPointHeight);
                self.headerContainerView.frame = frame;
                [self addSubview:self.headerContainerView];
            }
            
            if (self.isControlVerticalIndicator) {
                self.currentListScrollView.showsVerticalScrollIndicator = YES;
            }
            
            if (self.syncListContentOffsetEnabled) {
                self.syncListContentOffsetEnabled = NO;
                self.currentHeaderContainerViewY = -(self.headerHeight - self.ceilPointHeight);
                for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
                    if (list.listScrollView != scrollView) {
                        [self setScrollView:list.listScrollView offset:CGPointMake(0, -(self.segmentedHeight + self.ceilPointHeight))];
                    }
                }
            }
        }
        CGPoint contentOffset = CGPointMake(scrollView.contentOffset.x, contentOffsetY);
        if ([self.delegate respondsToSelector:@selector(smoothView:listScrollViewDidScroll:contentOffset:)]) {
            [self.delegate smoothView:self listScrollViewDidScroll:scrollView contentOffset:contentOffset];
        }
    }
}

- (void)loadHeaderAndSegmentedView {
    self.headerView = [self.dataSource headerViewInSmoothView:self];
    self.segmentedView = [self.dataSource segmentedViewInSmoothView:self];
    [self.headerContainerView addSubview:self.headerView];
    [self.headerContainerView addSubview:self.segmentedView];
    
    // 刷新高度
    [self refreshHeaderContainerHeight];
}

- (void)refreshHeaderContainerView {
    __weak __typeof(self) weakSelf = self;
    [self refreshWidthCompletion:^(CGSize size) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self refreshHeaderContainerHeight];
        
        CGRect frame = self.headerContainerView.frame;
        if (CGRectEqualToRect(frame, CGRectZero)) {
            frame = CGRectMake(0, 0, size.width, self.headerContainerHeight);
        }else {
            frame.size.height = self.headerContainerHeight;
        }
        self.headerContainerView.frame = frame;
        
        self.headerView.frame = CGRectMake(0, 0, size.width, self.headerHeight);
        self.segmentedView.frame =  CGRectMake(0, self.headerHeight, size.width, self.segmentedHeight);
        
        if (self.segmentedView.superview != self.headerContainerView) { // 修复headerHeight < size.height, headerContainerHeight > size.height时segmentedView.superView为bottomContainerView
            [self.headerContainerView addSubview:self.segmentedView];
        }
        
        if (!self.isMainScrollDisabled) {
            for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
                UIEdgeInsets insets = list.listScrollView.contentInset;
                insets.top = self.headerContainerHeight;
                list.listScrollView.contentInset = insets;
                if (self.isResetPosition) {
                    [self setScrollView:list.listScrollView offset:CGPointMake(0, -self.headerContainerHeight)];
                }
            }
            for (UIView *listHeader in self.listHeaderDict.allValues) {
                CGRect frame = listHeader.frame;
                frame.origin.y = -self.headerContainerHeight;
                frame.size.height = self.headerContainerHeight;
                listHeader.frame = frame;
            }
        }
        
        if (self.isBottomHover) {
            if (self.headerHeight > size.height) {
                self.bottomContainerView.hidden = NO; // 修复滑动到非悬浮状态后执行刷新导致bottomContainerView未显示的问题
                self.segmentedView.frame = CGRectMake(0, 0, size.width, self.segmentedHeight);
                [self.bottomContainerView addSubview:self.segmentedView];
            }
            if (self.hoverType == GKPageSmoothHoverTypeBottom) {
                self.bottomContainerView.frame = CGRectMake(0, size.height - self.segmentedHeight, size.width, size.height - self.ceilPointHeight);
                [self setupDismissLayout];
            }else if (self.hoverType == GKPageSmoothHoverTypeTop) {
                // 记录当前列表的滑动位置
                self.currentListPanBeganContentOffsetY = self.currentListScrollView.contentOffset.y;
                [self.listDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, id<GKPageSmoothListViewDelegate>  _Nonnull obj, BOOL * _Nonnull stop) {
                    obj.listScrollView.contentInset = UIEdgeInsetsZero;
                    [self setScrollView:obj.listScrollView offset:CGPointZero];
                    
                    CGRect frame = obj.listView.frame;
                    frame.size = self.listCollectionView.bounds.size;
                    obj.listView.frame = frame;
                }];
            }
        }
    }];
}

- (void)refreshHeaderContainerHeight {
    self.headerHeight = self.headerView.bounds.size.height;
    self.segmentedHeight = self.segmentedView.bounds.size.height;
    self.headerContainerHeight = self.headerHeight + self.segmentedHeight;
}

- (void)refreshWidthCompletion:(void(^)(CGSize size))completion {
    if (self.bounds.size.width == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            !completion ? : completion(self.bounds.size);
        });
    }else {
        !completion ? : completion(self.bounds.size);
    }
}

- (void)horizontalScrollDidEndAtIndex:(NSInteger)index {
    self.currentIndex = index;
    UIView *listHeader = self.listHeaderDict[@(index)];
    UIScrollView *listScrollView = self.listDict[@(index)].listScrollView;
    self.currentListScrollView = listScrollView;
    if (self.isOnTop) return;
    if (listHeader != nil && listScrollView.contentOffset.y <= -(self.segmentedHeight + self.ceilPointHeight)) {
        for (id<GKPageSmoothListViewDelegate> listItem in self.listDict.allValues) {
            listItem.listScrollView.scrollsToTop = (listItem.listScrollView == listScrollView);
        }
        CGRect frame = self.headerContainerView.frame;
        frame.origin.y = 0;
        self.headerContainerView.frame = frame;
        if (self.headerContainerView.superview != listHeader) {
            [listHeader addSubview:self.headerContainerView];
        }
        
        CGFloat minContentSizeHeight = self.bounds.size.height - self.segmentedHeight - self.ceilPointHeight;
        if (minContentSizeHeight > listScrollView.contentSize.height && !self.isHoldUpScrollView) {
            [self setScrollView:listScrollView offset:CGPointMake(listScrollView.contentOffset.x, -self.headerContainerHeight)];
            [self listScrollViewDidScroll:listScrollView];
        }
    }
}

- (UIView *)listHeaderForListScrollView:(UIScrollView *)scrollView {
    for (NSNumber *index in self.listDict) {
        if (self.listDict[index].listScrollView == scrollView) {
            return self.listHeaderDict[index];
        }
    }
    return nil;
}

- (NSInteger)listIndexForListScrollView:(UIScrollView *)scrollView {
    for (NSNumber *index in self.listDict) {
        if (self.listDict[index].listScrollView == scrollView) {
            return index.integerValue;
        }
    }
    return 0;
}

- (void)allowScrolling:(UIScrollView *)scrollView {
    scrollView.bounces = self.originBounces;
    scrollView.showsVerticalScrollIndicator = self.originShowsVerticalScrollIndicator;
}

- (void)forbidScrolling:(UIScrollView *)scrollView {
    [self setScrollView:scrollView offset:CGPointZero];
    scrollView.bounces = NO;
    scrollView.showsVerticalScrollIndicator = NO;
}

- (void)dragBegan {
    self.isOnTop = YES;
    [self setupShowingLayout];
}

- (void)dragDismiss {
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.bottomContainerView.frame;
        frame.origin.y = self.frame.size.height - self.segmentedHeight;
        self.bottomContainerView.frame = frame;
    } completion:^(BOOL finished) {
        [self setupDismissLayout];
        
        self.isOnTop = NO;
        if ([self.delegate respondsToSelector:@selector(smoothViewDragEnded:isOnTop:)]) {
            [self.delegate smoothViewDragEnded:self isOnTop:self.isOnTop];
        }
    }];
}

- (void)dragShowing {
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.bottomContainerView.frame;
        frame.origin.y = self.ceilPointHeight;
        self.bottomContainerView.frame = frame;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(smoothViewDragEnded:isOnTop:)]) {
            [self.delegate smoothViewDragEnded:self isOnTop:self.isOnTop];
        }
    }];
}

- (void)setupShowingLayout {
    // 将headerContainerView添加到self
    if (self.headerContainerView.superview != self) {
        CGRect frame = self.headerContainerView.frame;
        frame.origin.y = -(self.currentListScrollView.contentOffset.y + self.headerContainerHeight);
        self.headerContainerView.frame = frame;
        [self insertSubview:self.headerContainerView belowSubview:self.bottomContainerView];
    }
    
    // 将listCollectionView添加到bottomContainerView
    if (self.listCollectionView.superview != self.bottomContainerView) {
        CGRect frame = self.listCollectionView.frame;
        frame.origin.y = self.segmentedHeight;
        frame.size.height = self.bottomContainerView.frame.size.height - self.segmentedHeight;
        self.listCollectionView.frame = frame;
        [self.bottomContainerView addSubview:self.listCollectionView];
        self->_listCollectionView.headerContainerView = nil;
        
        // 记录当前列表的滑动位置
        self.currentListPanBeganContentOffsetY = self.currentListScrollView.contentOffset.y;
        
        for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
            list.listScrollView.contentInset = UIEdgeInsetsZero;
            [self setScrollView:list.listScrollView offset:CGPointZero];
            
            CGRect frame = list.listView.frame;
            frame.size = self.listCollectionView.bounds.size;
            list.listView.frame = frame;
        }
    }
}

- (void)setupDismissLayout {
    UIView *listHeader = [self listHeaderForListScrollView:self.currentListScrollView];
    if (self.headerContainerView.superview != listHeader) {
        CGRect frame = self.headerContainerView.frame;
        frame.origin.y = 0;
        self.headerContainerView.frame = frame;
        [listHeader addSubview:self.headerContainerView];
    }
    
    if (self.listCollectionView.superview != self) {
        self.listCollectionView.frame = self.bounds;
        [self insertSubview:self.listCollectionView belowSubview:self.bottomContainerView];
        self->_listCollectionView.headerContainerView = self.headerContainerView;
        
        for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
            list.listScrollView.contentInset = UIEdgeInsetsMake(self.headerContainerHeight, 0, 0, 0);
            if (list.listScrollView != self.currentListScrollView) {
                [self setScrollView:list.listScrollView offset:CGPointZero];
            }
            
            CGRect frame = list.listView.frame;
            frame.size = self.listCollectionView.bounds.size;
            list.listView.frame = frame;
        }
        [self setScrollView:self.currentListScrollView offset:CGPointMake(0, self.currentListPanBeganContentOffsetY)];
    }
}

- (void)setScrollView:(UIScrollView *)scrollView offset:(CGPoint)offset {
    if (!CGPointEqualToPoint(scrollView.contentOffset, offset)) {
        [scrollView setContentOffset:offset animated:NO];
    }
}

#pragma mark - Getter
- (UICollectionView *)listCollectionView {
    if (!_listCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _listCollectionView = [[GKPageSmoothCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _listCollectionView.dataSource = self;
        _listCollectionView.delegate = self;
        _listCollectionView.pagingEnabled = YES;
        _listCollectionView.bounces = NO;
        _listCollectionView.showsHorizontalScrollIndicator = NO;
        _listCollectionView.showsVerticalScrollIndicator = NO;
        _listCollectionView.scrollsToTop = NO;
        [_listCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:GKPageSmoothViewCellID];
        if (@available(iOS 11.0, *)) {
            _listCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 10.0, *)) {
            _listCollectionView.prefetchingEnabled = NO;
        }
        _listCollectionView.headerContainerView = self.headerContainerView;
    }
    return _listCollectionView;
}

- (UIView *)headerContainerView {
    if (!_headerContainerView) {
        _headerContainerView = [UIView new];
    }
    return _headerContainerView;
}

- (UIView *)bottomContainerView {
    if (!_bottomContainerView) {
        _bottomContainerView = [UIView new];
        _bottomContainerView.backgroundColor = UIColor.whiteColor;
    }
    return _bottomContainerView;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

@end
