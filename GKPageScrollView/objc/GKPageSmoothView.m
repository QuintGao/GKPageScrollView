//
//  GKPageSmoothView.m
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2020/5/4.
//  Copyright © 2020 gaokun. All rights reserved.
//

#import "GKPageSmoothView.h"
#import "GKPageDefine.h"

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


@interface GKPageSmoothView()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<GKPageSmoothViewDelegate> delegate;
@property (nonatomic, strong) GKPageSmoothCollectionView  *listCollectionView;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, id<GKPageSmoothListViewDelegate>> *listDict;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIView *> *listHeaderDict;

@property (nonatomic, strong) UIView *headerContainerView;
@property (nonatomic, weak) UIScrollView *currentListScrollView;

@property (nonatomic, assign) BOOL syncListContentOffsetEnabled;
@property (nonatomic, assign) CGFloat currentHeaderContainerViewY;

@property (nonatomic, assign) CGFloat headerContainerHeight;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat segmentedHeight;
@property (nonatomic, assign) CGFloat currentListInitializeContentOffsetY;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL      isLoaded;

@end

@implementation GKPageSmoothView

- (instancetype)initWithDelegate:(id<GKPageSmoothViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        _listDict = [NSMutableDictionary dictionary];
        _listHeaderDict = [NSMutableDictionary dictionary];
        _ceilPointHeight = GKPAGE_NAVBAR_HEIGHT;
        
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    self.headerContainerView = [UIView new];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.listCollectionView = [[GKPageSmoothCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.listCollectionView.dataSource = self;
    self.listCollectionView.delegate = self;
    self.listCollectionView.pagingEnabled = YES;
    self.listCollectionView.bounces = NO;
    self.listCollectionView.showsHorizontalScrollIndicator = NO;
    self.listCollectionView.scrollsToTop = NO;
    [self.listCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:GKPageSmoothViewCellID];
    if (@available(iOS 11.0, *)) {
        self.listCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    if (@available(iOS 10.0, *)) {
        self.listCollectionView.prefetchingEnabled = NO;
        
    }
    [self addSubview:self.listCollectionView];
    _listCollectionView.headerContainerView = self.headerContainerView;
    
    [self addSubview:self.headerContainerView];
    [self refreshHeaderView];
}

- (void)dealloc {
    for (id<GKPageSmoothListViewDelegate> listItem in self.listDict.allValues) {
        [listItem.listScrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.listCollectionView.frame = self.bounds;
}

- (void)refreshHeaderView {
    // 重新设置headerView及segmentedView的frame
    UIView *headerView = [self.delegate headerViewInSmoothView:self];
    UIView *segmentedView = [self.delegate segmentedViewInSmoothView:self];
    [self.headerContainerView addSubview:headerView];
    [self.headerContainerView addSubview:segmentedView];
    
    self.headerHeight = headerView.bounds.size.height;
    self.segmentedHeight = segmentedView.bounds.size.height;
    self.headerContainerHeight = self.headerHeight + self.segmentedHeight;
    
    __weak __typeof(self) weakSelf = self;
    [self refreshWidthCompletion:^(CGFloat width) {
        __strong __typeof(self) self = weakSelf;
        
        self.headerContainerView.frame = CGRectMake(0, 0, width, self.headerContainerHeight);
        headerView.frame = CGRectMake(0, 0, width, self.headerHeight);
        segmentedView.frame = CGRectMake(0, self.headerHeight, width, self.segmentedHeight);
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
    [self refreshWidthCompletion:^(CGFloat width) {
        __strong __typeof(self) self = weakSelf;
        
        [self.listCollectionView setContentOffset:CGPointMake(width * self.currentIndex, 0) animated:NO];
        [self.listCollectionView reloadData];
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.isLoaded ? 1 : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.delegate numberOfListsInSmoothView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GKPageSmoothViewCellID forIndexPath:indexPath];
    id<GKPageSmoothListViewDelegate> list = self.listDict[@(indexPath.item)];
    if (list == nil) {
        list = [self.delegate smoothView:self initListAtIndex:indexPath.item];
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
        listScrollView.contentInset = UIEdgeInsetsMake(self.headerContainerHeight, 0, 0, 0);
        if (CGSizeEqualToSize(listScrollView.contentSize, CGSizeZero)) {
            listScrollView.contentSize = CGSizeMake(listScrollView.contentSize.width, self.bounds.size.height);
        }
        
        self.currentListInitializeContentOffsetY = -listScrollView.contentInset.top + MIN(-self.currentHeaderContainerViewY, (self.headerHeight - self.ceilPointHeight));
        listScrollView.contentOffset = CGPointMake(0, self.currentListInitializeContentOffsetY);
        UIView *listHeader = [[UIView alloc] initWithFrame:CGRectMake(0, -self.headerContainerHeight, self.bounds.size.width, self.headerContainerHeight)];
        [listScrollView addSubview:listHeader];
        if (self.headerContainerView.superview == nil) {
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
    return self.bounds.size;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self listDidAppear:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self listDidDisappear:indexPath.item];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(smoothView:scrollViewDidScroll:)]) {
        [self.delegate smoothView:self scrollViewDidScroll:scrollView];
    }
    
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    NSInteger ratio = (int)scrollView.contentOffset.x % (int)scrollView.bounds.size.width;
    
    UIScrollView *listScrollView = self.listDict[@(index)].listScrollView;
    if (index != self.currentIndex && ratio == 0 && !(scrollView.isDragging || scrollView.isDecelerating) && listScrollView.contentOffset.y <= -(self.segmentedHeight + self.ceilPointHeight)) {
        [self horizontalScrollDidEndAtIndex:index];
    }else {
        // 左右滚动的时候，把headerContainerView添加到self，达到悬浮的效果
        if (self.headerContainerView.superview != self) {
            self.headerContainerView.frame = CGRectMake(0, self.currentHeaderContainerViewY, self.headerContainerView.bounds.size.width, self.headerContainerView.bounds.size.height);
            [self addSubview:self.headerContainerView];
        }
    }
    if (self.currentIndex != index) {
        self.currentIndex = index;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
        [self horizontalScrollDidEndAtIndex:index];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
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

#pragma mark - Private Methods
- (void)listScrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.listCollectionView.isDragging || self.listCollectionView.isDecelerating) return;
    
    NSInteger listIndex = [self listIndexForListScrollView:scrollView];
    if (listIndex != self.currentIndex) return;
    self.currentListScrollView = scrollView;
    CGFloat contentOffsetY = scrollView.contentOffset.y + self.headerContainerHeight;
    
    if (contentOffsetY < (self.headerHeight - self.ceilPointHeight)) {
        self.syncListContentOffsetEnabled = YES;
        self.currentHeaderContainerViewY = -contentOffsetY;
        for (id<GKPageSmoothListViewDelegate> list in self.listDict.allValues) {
            if (list.listScrollView != scrollView) {
                [list.listScrollView setContentOffset:scrollView.contentOffset animated:NO];
            }
        }
        UIView *listHeader = [self listHeaderForListScrollView:scrollView];
        if (self.headerContainerView.superview != listHeader) {
            self.headerContainerView.frame = CGRectMake(0, 0, self.headerContainerView.bounds.size.width, self.headerContainerView.bounds.size.height);
            [listHeader addSubview:self.headerContainerView];
        }
        
        if (self.isControlVerticalIndicator && self.ceilPointHeight != 0) {
            self.currentListScrollView.showsVerticalScrollIndicator = NO;
        }
    }else {
        if (self.headerContainerView.superview != self) {
            self.headerContainerView.frame = CGRectMake(0, -(self.headerHeight - self.ceilPointHeight), self.headerContainerView.bounds.size.width, self.headerContainerView.bounds.size.height);
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
}

- (void)refreshWidthCompletion:(void(^)(CGFloat width))completion {
    __block CGFloat width = self.bounds.size.width;
    
    if (width == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            width = self.bounds.size.width;
            !completion ? : completion(width);
        });
    }else {
        !completion ? : completion(width);
    }
}

- (void)horizontalScrollDidEndAtIndex:(NSInteger)index {
    self.currentIndex = index;
    UIView *listHeader = self.listHeaderDict[@(index)];
    UIScrollView *listScrollView = self.listDict[@(index)].listScrollView;
    if (listHeader != nil && listScrollView.contentOffset.y <= -(self.segmentedHeight + self.ceilPointHeight)) {
        for (id<GKPageSmoothListViewDelegate> listItem in self.listDict.allValues) {
            listItem.listScrollView.scrollsToTop = (listItem.listScrollView == listScrollView);
        }
        self.headerContainerView.frame = CGRectMake(0, 0, self.headerContainerView.bounds.size.width, self.headerContainerView.bounds.size.height);
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
    NSUInteger count = [self.delegate numberOfListsInSmoothView:self];
    if (count <= 0 || index >= count) {
        return;
    }
    
    id<GKPageSmoothListViewDelegate> list = self.listDict[@(index)];
    if (list && [list respondsToSelector:@selector(listViewDidAppear)]) {
        [list listViewDidAppear];
    }
}

- (void)listDidDisappear:(NSInteger)index {
    NSUInteger count = [self.delegate numberOfListsInSmoothView:self];
    if (count <= 0 || index >= count) {
        return;
    }
    
    id<GKPageSmoothListViewDelegate> list = self.listDict[@(index)];
    if (list && [list respondsToSelector:@selector(listViewDidDisappear)]) {
        [list listViewDidDisappear];
    }
}

@end
