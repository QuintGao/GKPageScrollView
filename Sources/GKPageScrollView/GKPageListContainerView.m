//
//  GKPageListContainerView.m
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2019/3/13.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKPageListContainerView.h"
#import "GKPageTableView.h"
#import "GKPageScrollView.h"
#import <objc/runtime.h>

@interface GKPageListContainerScrollView : UIScrollView<UIGestureRecognizerDelegate>
@property (nonatomic, assign, getter=isNestEnabled) BOOL nestEnabled;
@property (nonatomic, weak) id<GKPageListContainerScrollViewGestureDelegate> gestureDelegate;
@end

@implementation GKPageListContainerScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.gestureDelegate respondsToSelector:@selector(pageListContainerScrollView:gestureRecognizerShouldBegin:)]) {
        return [self.gestureDelegate pageListContainerScrollView:self gestureRecognizerShouldBegin:gestureRecognizer];
    }else {
        if (self.isNestEnabled) {
            if ([gestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
                CGFloat velocityX = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view].x;
                // x大于0就是右滑
                if (velocityX > 0) {
                    if (self.contentOffset.x == 0) {
                        return NO;
                    }
                }else if (velocityX < 0) { // x小于0是往左滑
                    if (self.contentOffset.x + self.bounds.size.width == self.contentSize.width) {
                        return NO;
                    }
                }
            }
        }
    }
    
    if ([self panBack:gestureRecognizer]) return NO;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.gestureDelegate respondsToSelector:@selector(pageListContainerScrollView:gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        [self.gestureDelegate pageListContainerScrollView:self gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    
    if ([self panBack:gestureRecognizer]) return YES;
    
    return NO;
}

- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint point = [self.panGestureRecognizer translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        
        // 设置手势滑动的位置距屏幕左边的区域
        CGFloat locationDistance = [UIScreen mainScreen].bounds.size.width;
        
        if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStatePossible) {
            CGPoint location = [gestureRecognizer locationInView:self];
            if (point.x > 0 && location.x < locationDistance && self.contentOffset.x <= 0) {
                return YES;
            }
        }
    }
    return NO;
}

@end

@interface GKPageListContainerCollectionView : UICollectionView<UIGestureRecognizerDelegate>

@property (nonatomic, assign, getter=isNestEnabled) BOOL nestEnabled;
@property (nonatomic, weak) id<GKPageListContainerScrollViewGestureDelegate> gestureDelegate;

@end

@implementation GKPageListContainerCollectionView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.gestureDelegate respondsToSelector:@selector(pageListContainerScrollView:gestureRecognizerShouldBegin:)]) {
        return [self.gestureDelegate pageListContainerScrollView:self gestureRecognizerShouldBegin:gestureRecognizer];
    }else {
        if (self.isNestEnabled) {
            if ([gestureRecognizer isMemberOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
                CGFloat velocityX = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view].x;
                // x大于0就是右滑
                if (velocityX > 0) {
                    if (self.contentOffset.x == 0) {
                        return NO;
                    }
                }else if (velocityX < 0) { // x小于0是往左滑
                    if (self.contentOffset.x + self.bounds.size.width == self.contentSize.width) {
                        return NO;
                    }
                }
            }
        }
    }
    
    if ([self panBack:gestureRecognizer]) return NO;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.gestureDelegate respondsToSelector:@selector(pageListContainerScrollView:gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [self.gestureDelegate pageListContainerScrollView:self gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    
    if ([self panBack:gestureRecognizer]) return YES;
    
    return NO;
}

- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint point = [self.panGestureRecognizer translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        
        // 设置手势滑动的位置距屏幕左边的区域
        CGFloat locationDistance = [UIScreen mainScreen].bounds.size.width;
        
        if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStatePossible) {
            CGPoint location = [gestureRecognizer locationInView:self];
            if (point.x > 0 && location.x < locationDistance && self.contentOffset.x <= 0) {
                return YES;
            }
        }
    }
    return NO;
}

@end

@interface GKPageListContainerViewController : UIViewController
@property (copy) void(^viewWillAppearBlock)(void);
@property (copy) void(^viewDidAppearBlock)(void);
@property (copy) void(^viewWillDisappearBlock)(void);
@property (copy) void(^viewDidDisappearBlock)(void);
@end

@implementation GKPageListContainerViewController

- (void)dealloc {
    self.viewWillAppearBlock = nil;
    self.viewDidAppearBlock = nil;
    self.viewWillDisappearBlock = nil;
    self.viewDidDisappearBlock = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.viewWillAppearBlock();
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewDidAppearBlock();
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.viewWillDisappearBlock();
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.viewDidDisappearBlock();
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods { return NO; }

@end

@interface GKPageListContainerView()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<GKPageListContainerViewDelegate> delegate;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, id<GKPageListViewDelegate>> *validListDict;
@property (nonatomic, assign) NSInteger willAppearIndex;
@property (nonatomic, assign) NSInteger willDisappearIndex;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) GKPageListContainerViewController *containerVC;

@end

@implementation GKPageListContainerView

- (instancetype)initWithContainerType:(GKPageListContainerType)containerType delegate:(id<GKPageListContainerViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        _containerType = containerType;
        _delegate = delegate;
        _validListDict = [NSMutableDictionary dictionary];
        _willAppearIndex = -1;
        _willDisappearIndex = -1;
        _initListPercent = 0.01;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    _containerVC = [[GKPageListContainerViewController alloc] init];
    _containerVC.view.backgroundColor = UIColor.clearColor;
    [self addSubview:self.containerVC.view];
    __weak __typeof(self) weakSelf = self;
    _containerVC.viewWillAppearBlock = ^{
        [weakSelf listWillAppear:weakSelf.currentIndex];
    };
    _containerVC.viewDidAppearBlock = ^{
        [weakSelf listDidAppear:weakSelf.currentIndex];
    };
    _containerVC.viewWillDisappearBlock = ^{
        [weakSelf listWillDisappear:weakSelf.currentIndex];
    };
    _containerVC.viewDidDisappearBlock = ^{
        [weakSelf listDidDisappear:weakSelf.currentIndex];
    };
    if (self.containerType == GKPageListContainerType_ScrollView) {
        if ([self.delegate respondsToSelector:@selector(scrollViewClassInListContainerView:)] && [[self.delegate scrollViewClassInListContainerView:self] isKindOfClass:object_getClass([UIScrollView class])]) {
            _scrollView = (UIScrollView *)[[[self.delegate scrollViewClassInListContainerView:self] alloc] init];
        }else {
            _scrollView = [[GKPageListContainerScrollView alloc] init];
        }
        self.scrollView.backgroundColor = UIColor.clearColor;
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.bounces = NO;
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.containerVC.view addSubview:self.scrollView];
    }else {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if ([self.delegate respondsToSelector:@selector(scrollViewClassInListContainerView:)] && [[self.delegate scrollViewClassInListContainerView:self] isKindOfClass:object_getClass([UICollectionView class])]) {
            _collectionView = (UICollectionView *)[[[self.delegate scrollViewClassInListContainerView:self] alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        }else {
            _collectionView = [[GKPageListContainerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        }
        self.collectionView.backgroundColor = UIColor.clearColor;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.pagingEnabled = YES;
        self.collectionView.scrollsToTop = NO;
        self.collectionView.bounces = NO;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        if (@available(iOS 10.0, *)) {
            self.collectionView.prefetchingEnabled = NO;
        }
        if (@available(iOS 11.0, *)) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.containerVC.view addSubview:self.collectionView];
        _scrollView = _collectionView;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    UIResponder *next = newSuperview;
    while (next != nil) {
        if ([next isKindOfClass:UIViewController.class]) {
            [((UIViewController *)next) addChildViewController:self.containerVC];
            break;
        }
        next = next.nextResponder;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerVC.view.frame = self.bounds;
    if (self.containerType == GKPageListContainerType_ScrollView) {
        if (CGRectEqualToRect(self.scrollView.frame, CGRectZero) || !CGSizeEqualToSize(self.scrollView.bounds.size, self.bounds.size)) {
            self.scrollView.frame = self.bounds;
            self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * [self.delegate numberOfRowsInListContainerView:self], self.scrollView.bounds.size.height);
            [_validListDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, id<GKPageListViewDelegate>  _Nonnull obj, BOOL * _Nonnull stop) {
                [obj listView].frame = CGRectMake(key.intValue * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
            }];
            self.scrollView.contentOffset = CGPointMake(self.currentIndex * self.scrollView.bounds.size.width, 0);
        }else {
            self.scrollView.frame = self.bounds;
            self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * [self.delegate numberOfRowsInListContainerView:self], self.scrollView.bounds.size.height);
        }
    }else {
        if (CGRectEqualToRect(self.collectionView.frame, CGRectZero) || !CGSizeEqualToSize(self.collectionView.bounds.size, self.bounds.size)) {
            self.collectionView.frame = self.bounds;
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionView reloadData];
            self.collectionView.contentOffset = CGPointMake(self.currentIndex * self.collectionView.bounds.size.width, 0);
        }else {
            self.collectionView.frame = self.bounds;
        }
    }
}

- (void)setInitListPercent:(CGFloat)initListPercent {
    _initListPercent = initListPercent;
    if (initListPercent <= 0 || initListPercent >= 1) {
        [NSException exceptionWithName:NSInvalidArgumentException reason:@"initListPercent值范围为开区间(0,1),即不包括0和1" userInfo:nil];
    }
}

- (void)setNestEnabled:(BOOL)nestEnabled {
    _nestEnabled = nestEnabled;
    if ([self.scrollView isKindOfClass:[GKPageListContainerScrollView class]]) {
        ((GKPageListContainerScrollView *)self.scrollView).nestEnabled = nestEnabled;
    }else if ([self.scrollView isKindOfClass:[GKPageListContainerCollectionView class]]) {
        ((GKPageListContainerCollectionView *)self.scrollView).nestEnabled = nestEnabled;
    }
}

- (void)setGestureDelegate:(id<GKPageListContainerScrollViewGestureDelegate>)gestureDelegate {
    _gestureDelegate = gestureDelegate;
    if ([self.scrollView isKindOfClass:[GKPageListContainerScrollView class]]) {
        ((GKPageListContainerScrollView *)self.scrollView).gestureDelegate = gestureDelegate;
    }else if ([self.scrollView isKindOfClass:[GKPageListContainerCollectionView class]]) {
        ((GKPageListContainerCollectionView *)self.scrollView).gestureDelegate = gestureDelegate;
    }
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.delegate numberOfRowsInListContainerView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    id<GKPageListViewDelegate> list = _validListDict[@(indexPath.row)];
    if (list != nil) {
        [list listView].frame = cell.bounds;
        [cell.contentView addSubview:[list listView]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView.isDragging && !scrollView.isTracking && !scrollView.isDecelerating) return;
    CGFloat ratio = scrollView.contentOffset.x / scrollView.bounds.size.width;
    NSInteger maxCount = round(scrollView.contentSize.width / scrollView.bounds.size.width);
    NSInteger leftIndex = floorf(ratio);
    leftIndex = MAX(0, MIN(maxCount - 1, leftIndex));
    NSInteger rightIndex = leftIndex + 1;
    if (ratio < 0 || rightIndex >= maxCount) {
        [self listDidAppearOrDisappear:scrollView];
        return;
    }
    CGFloat remainderRatio = ratio - leftIndex;
    if (rightIndex == self.currentIndex) {
        // 当前选中的在右边，用户正在从右往左滑动
        if (self.validListDict[@(leftIndex)] == nil && remainderRatio < (1 - self.initListPercent)) {
            [self initListIfNeededAtIndex:leftIndex];
        }else if (self.validListDict[@(leftIndex)] != nil) {
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
        // 当前选中的在左边，用户正在从左往右滑动
        if (self.validListDict[@(rightIndex)] == nil && remainderRatio > self.initListPercent) {
            [self initListIfNeededAtIndex:rightIndex];
        }else if (self.validListDict[@(rightIndex)] != nil) {
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.willDisappearIndex != -1) {
        [self listWillAppear:self.willDisappearIndex];
        [self listWillDisappear:self.willAppearIndex];
        [self listDidAppear:self.willDisappearIndex];
        [self listDidDisappear:self.willAppearIndex];
        self.willAppearIndex = -1;
        self.willDisappearIndex = -1;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (self.willDisappearIndex != -1) {
            [self listWillAppear:self.willDisappearIndex];
            [self listWillDisappear:self.willAppearIndex];
            [self listDidAppear:self.willDisappearIndex];
            [self listDidDisappear:self.willAppearIndex];
            self.willAppearIndex = -1;
            self.willDisappearIndex = -1;
        }
    }
}

#pragma mark - Private
- (void)initListIfNeededAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(listContainerView:canInitListAtIndex:)]) {
        BOOL canInitList = [self.delegate listContainerView:self canInitListAtIndex:index];
        if (!canInitList) {
            return;
        }
    }
    id<GKPageListViewDelegate> list = _validListDict[@(index)];
    if (list != nil) {
        // 列表已经创建好了
        return;
    }
    list = [self.delegate listContainerView:self initListForIndex:index];
    if ([list isKindOfClass:UIViewController.class]) {
        [self.containerVC addChildViewController:(UIViewController *)list];
    }
    _validListDict[@(index)] = list;
    
    switch (self.containerType) {
        case GKPageListContainerType_ScrollView: {
            [list listView].frame = CGRectMake(index * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
            [self.scrollView addSubview:[list listView]];
        }
            break;
        case GKPageListContainerType_CollectionView: {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            if (cell != nil) {
                [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [list listView].frame = cell.contentView.bounds;
                [cell.contentView addSubview:[list listView]];
            }
        }
            break;
    }
}

- (void)listWillAppear:(NSInteger)index {
    if (![self checkIndexValid:index]) return;
    id<GKPageListViewDelegate> list = _validListDict[@(index)];
    if (list != nil) {
        if ([list respondsToSelector:@selector(listWillAppear)]) {
            [list listWillAppear];
        }
        if ([list isKindOfClass:UIViewController.class]) {
            [((UIViewController *)list) beginAppearanceTransition:YES animated:NO];
        }
    }else {
        // 当前列表未被创建（页面初始化或通过点击触发的listWillAppear)
        [self initListIfNeededAtIndex:index];
        [self listWillAppear:index];
    }
}

- (void)listDidAppear:(NSInteger)index {
    if (![self checkIndexValid:index]) return;
    self.currentIndex = index;
    id<GKPageListViewDelegate> list = _validListDict[@(index)];
    if ([list respondsToSelector:@selector(listDidAppear)]) {
        [list listDidAppear];
    }
    if ([list isKindOfClass:UIViewController.class]) {
        [((UIViewController *)list) endAppearanceTransition];
    }
    if ([self.delegate respondsToSelector:@selector(listContainerView:listDidAppearAtIndex:)]) {
        [self.delegate listContainerView:self listDidAppearAtIndex:index];
    }
}

- (void)listWillDisappear:(NSInteger)index {
    if (![self checkIndexValid:index]) return;
    id<GKPageListViewDelegate> list = _validListDict[@(index)];
    if ([list respondsToSelector:@selector(listWillDisappear)]) {
        [list listWillDisappear];
    }
    if ([list isKindOfClass:UIViewController.class]) {
        [((UIViewController *)list) beginAppearanceTransition:NO animated:NO];
    }
}

- (void)listDidDisappear:(NSInteger)index {
    if (![self checkIndexValid:index]) return;
    id<GKPageListViewDelegate> list = _validListDict[@(index)];
    if ([list respondsToSelector:@selector(listDidDisappear)]) {
        [list listDidDisappear];
    }
    if ([list isKindOfClass:UIViewController.class]) {
        [((UIViewController *)list) endAppearanceTransition];
    }
}

- (BOOL)checkIndexValid:(NSInteger)index {
    NSUInteger count = [self.delegate numberOfRowsInListContainerView:self];
    if (count <= 0 || index >= count) {
        return NO;
    }
    return YES;
}

- (void)listDidAppearOrDisappear:(UIScrollView *)scrollView {
    CGFloat currentIndexPercent = scrollView.contentOffset.x / scrollView.bounds.size.width;
    if (self.willAppearIndex != -1 && self.willDisappearIndex != -1) {
        NSInteger appearIndex = self.willAppearIndex;
        NSInteger disappearIndex = self.willDisappearIndex;
        if (self.willAppearIndex > self.willDisappearIndex) {
            // 将要出现的列表在右边
            if (currentIndexPercent >= self.willAppearIndex) {
                self.willAppearIndex = -1;
                self.willDisappearIndex = -1;
                [self listDidDisappear:disappearIndex];
                [self listDidAppear:appearIndex];
            }
        }else {
            // 将要出现的列表在左边
            if (currentIndexPercent <= self.willAppearIndex) {
                self.willAppearIndex = -1;
                self.willDisappearIndex = -1;
                [self listDidDisappear:disappearIndex];
                [self listDidAppear:appearIndex];
            }
        }
    }
}

#pragma mark - listContainer
- (UIScrollView *)contentScrollView {
    return self.scrollView;
}

- (void)setDefaultSelectedIndex:(NSInteger)index {
    self.currentIndex = index;
}

- (void)didClickSelectedItemAtIndex:(NSInteger)index {
    if (![self checkIndexValid:index]) return;
    self.willAppearIndex = -1;
    self.willDisappearIndex = -1;
    if (self.currentIndex != index) {
        [self listWillDisappear:self.currentIndex];
        [self listDidDisappear:self.currentIndex];
        [self listWillAppear:index];
        [self listDidAppear:index];
    }
}

- (void)reloadData {
    [_validListDict enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, id<GKPageListViewDelegate>  _Nonnull obj, BOOL * _Nonnull stop) {
        [[obj listView] removeFromSuperview];
        if ([obj isKindOfClass:UIViewController.class]) {
            [((UIViewController *)obj) removeFromParentViewController];
        }
    }];
    [_validListDict removeAllObjects];
    if (self.containerType == GKPageListContainerType_ScrollView) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * [self.delegate numberOfRowsInListContainerView:self], self.scrollView.bounds.size.height);
    }else {
        [self.collectionView reloadData];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self listWillAppear:self.currentIndex];
        [self listDidAppear:self.currentIndex];
    });
}

@end
