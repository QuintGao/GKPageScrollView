//
//  GKPageSmoothView.m
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2020/5/4.
//  Copyright © 2020 gaokun. All rights reserved.
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

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL      isLoaded;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL       isDragScrollView;
@property (nonatomic, assign) CGFloat    lastTransitionY;
@property (nonatomic, assign) BOOL       isOnTop;

@property (nonatomic, assign) CGFloat    currentListPanBeganContentOffsetY;
@property (nonatomic, assign) BOOL       originBounces;
@property (nonatomic, assign) BOOL       originShowsVerticalScrollIndicator;

@end

@implementation GKPageSmoothView

- (instancetype)initWithDataSource:(id<GKPageSmoothViewDataSource>)dataSource {
    if (self = [super initWithFrame:CGRectZero]) {
        self.dataSource = dataSource;
        _listDict = [NSMutableDictionary dictionary];
        _listHeaderDict = [NSMutableDictionary dictionary];
        _ceilPointHeight = 0;
        
        [self addSubview:self.listCollectionView];
        [self addSubview:self.headerContainerView];
        [self refreshHeaderView];
    }
    return self;
}

- (void)dealloc {
    for (id<GKPageSmoothListViewDelegate> listItem in self.listDict.allValues) {
        [listItem.listScrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.listCollectionView.superview == self) {
        self.listCollectionView.frame = self.bounds;
    }else {
        CGRect frame = self.listCollectionView.frame;
        frame.origin.y = self.segmentedHeight;
        frame.size.height = self.bottomContainerView.frame.size.height - self.segmentedHeight;
        self.listCollectionView.frame = frame;
    }
}

- (void)refreshHeaderView {
    [self loadHeaderAndSegmentedView];
    
    __weak __typeof(self) weakSelf = self;
    [self refreshWidthCompletion:^(CGSize size) {
        __strong __typeof(weakSelf) self = weakSelf;
        CGRect frame = self.headerContainerView.frame;
        if (CGRectEqualToRect(frame, CGRectZero)) {
            frame = CGRectMake(0, 0, size.width, self.headerContainerHeight);
        }else {
            frame.size.height = self.headerContainerHeight;
        }
        self.headerContainerView.frame = frame;
        
        self.headerView.frame = CGRectMake(0, 0, size.width, self.headerHeight);
        self.segmentedView.frame =  CGRectMake(0, self.headerHeight, size.width, self.segmentedHeight);
        
        for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
            list.listScrollView.contentInset = UIEdgeInsetsMake(self.headerContainerHeight, 0, 0, 0);
        }
        
        if (self.isBottomHover) {
            self.bottomContainerView.frame = CGRectMake(0, size.height - self.segmentedHeight, size.width, size.height - self.ceilPointHeight);
            
            if (self.headerHeight > size.height) {
                self.segmentedView.frame = CGRectMake(0, 0, size.width, self.segmentedHeight);
                [self.bottomContainerView addSubview:self.segmentedView];
            }
        }
    }];
}

- (void)reloadData {
    self.currentListScrollView = nil;
    self.currentIndex = self.defaultSelectedIndex;
    self.syncListContentOffsetEnabled = NO;
    self.currentHeaderContainerViewY = 0;
    self.isLoaded = YES;
    
    [self.listHeaderDict removeAllObjects];
    
    for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
        [list.listScrollView removeObserver:self forKeyPath:@"contentOffset"];
        [list.listView removeFromSuperview];
    }
    [_listDict removeAllObjects];
    
    __weak __typeof(self) weakSelf = self;
    [self refreshWidthCompletion:^(CGSize size) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self.listCollectionView setContentOffset:CGPointMake(size.width * self.currentIndex, 0) animated:NO];
        [self.listCollectionView reloadData];
    }];
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
        _listDict[@(indexPath.item)] = list;
        [list.listView setNeedsLayout];
        [list.listView layoutIfNeeded];
        
        UIScrollView *listScrollView = list.listScrollView;
        if ([listScrollView isKindOfClass:[UITableView class]]) {
            ((UITableView *)listScrollView).estimatedRowHeight = 0;
            ((UITableView *)listScrollView).estimatedSectionHeaderHeight = 0;
            ((UITableView *)listScrollView).estimatedSectionFooterHeight = 0;
        }
        if (@available(iOS 11.0, *)) {
            listScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        if (CGSizeEqualToSize(listScrollView.contentSize, CGSizeZero)) {
            listScrollView.contentSize = CGSizeMake(listScrollView.contentSize.width, self.bounds.size.height);
        }
        
        if (!self.isOnTop) {
            listScrollView.contentInset = UIEdgeInsetsMake(self.headerContainerHeight, 0, 0, 0);
            self.currentListInitializeContentOffsetY = -listScrollView.contentInset.top + MIN(-self.currentHeaderContainerViewY, (self.headerHeight - self.ceilPointHeight));
            listScrollView.contentOffset = CGPointMake(0, self.currentListInitializeContentOffsetY);
        }
        UIView *listHeader = [[UIView alloc] initWithFrame:CGRectMake(0, -self.headerContainerHeight, self.bounds.size.width, self.headerContainerHeight)];
        [listScrollView addSubview:listHeader];
        
        if (!self.isOnTop && self.headerContainerView.superview == nil) {
            [listHeader addSubview:self.headerContainerView];
        }
        self.listHeaderDict[@(indexPath.item)] = listHeader;
        [listScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    for (id<GKPageSmoothListViewDelegate> listItem in self.listDict.allValues) {
        listItem.listScrollView.scrollsToTop = (listItem == list);
    }
    
    UIView *listView = list.listView;
    if (listView != nil && listView.superview != cell.contentView) {
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        listView.frame = cell.contentView.bounds;
        [cell.contentView addSubview:listView];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.listCollectionView.bounds.size;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self listDidAppear:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self listDidDisappear:indexPath.item];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.panGesture.enabled = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(smoothView:scrollViewDidScroll:)]) {
        [self.delegate smoothView:self scrollViewDidScroll:scrollView];
    }
    
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    NSInteger ratio = (int)scrollView.contentOffset.x % (int)scrollView.bounds.size.width;
    
    if (!self.isOnTop) {
        UIScrollView *listScrollView = self.listDict[@(index)].listScrollView;
        if (index != self.currentIndex && ratio == 0 && !(scrollView.isDragging || scrollView.isDecelerating) && listScrollView.contentOffset.y <= -(self.segmentedHeight + self.ceilPointHeight)) {
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
    
    if (index != self.currentIndex && ratio == 0) {
        self.currentIndex = index;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
        [self horizontalScrollDidEndAtIndex:index];
    }
    self.panGesture.enabled = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self horizontalScrollDidEndAtIndex:index];
    self.panGesture.enabled = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self horizontalScrollDidEndAtIndex:index];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        if (scrollView != nil) {
            [self listScrollViewDidScroll:scrollView];
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
- (void)listScrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.listCollectionView.isDragging || self.listCollectionView.isDecelerating) return;
    
    if (self.isOnTop) { // 在顶部时无需处理headerView
        // 取消scrollView下滑时的弹性效果
        // buf fix #47，iOS12及以下系统isDragging会出现不准确的情况，所以这里改为用isTracking判断
        if (self.isAllowDragScroll && (scrollView.isTracking || scrollView.isDecelerating)) {
            if (scrollView.contentOffset.y < 0) {
                scrollView.contentOffset = CGPointZero;
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
                    [list.listScrollView setContentOffset:scrollView.contentOffset animated:NO];
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
                for (id<GKPageSmoothListViewDelegate> listItem in self.listDict.allValues) {
                    if (listItem.listScrollView != scrollView) {
                        [listItem.listScrollView setContentOffset:CGPointMake(0, -(self.segmentedHeight + self.ceilPointHeight)) animated:NO];
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
        [listHeader addSubview:self.headerContainerView];
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

- (void)listDidAppear:(NSInteger)index {
    NSUInteger count = [self.dataSource numberOfListsInSmoothView:self];
    if (count <= 0 || index >= count) return;
    
    id<GKPageSmoothListViewDelegate> list = self.listDict[@(index)];
    if (list && [list respondsToSelector:@selector(listViewDidAppear)]) {
        [list listViewDidAppear];
    }
}

- (void)listDidDisappear:(NSInteger)index {
    NSUInteger count = [self.dataSource numberOfListsInSmoothView:self];
    if (count <= 0 || index >= count) return;
    
    id<GKPageSmoothListViewDelegate> list = self.listDict[@(index)];
    if (list && [list respondsToSelector:@selector(listViewDidDisappear)]) {
        [list listViewDidDisappear];
    }
}

- (void)allowScrolling:(UIScrollView *)scrollView {
    scrollView.bounces = self.originBounces;
    scrollView.showsVerticalScrollIndicator = self.originShowsVerticalScrollIndicator;
}

- (void)forbidScrolling:(UIScrollView *)scrollView {
    scrollView.contentOffset = CGPointZero;
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
            list.listScrollView.contentOffset = CGPointZero;
            
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
            list.listScrollView.contentOffset = CGPointZero;
            
            CGRect frame = list.listView.frame;
            frame.size = self.listCollectionView.bounds.size;
            list.listView.frame = frame;
        }
        self.currentListScrollView.contentOffset = CGPointMake(0, self.currentListPanBeganContentOffsetY);
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
