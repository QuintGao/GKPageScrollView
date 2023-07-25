//
//  GKSmoothListView.m
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2020/5/8.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKSmoothListView.h"
#import "GKBallLoadingView.h"
#import "GKDYHeaderView.h"
#import "GKDemoBaseViewController.h"
#import <MJRefresh/MJRefresh.h>

@interface GKSmoothListLayout : UICollectionViewFlowLayout

@end

@implementation GKSmoothListLayout

- (CGSize)collectionViewContentSize {
    CGFloat minContentSizeHeight = self.collectionView.bounds.size.height;
    CGSize size = [super collectionViewContentSize];
    if (size.height < minContentSizeHeight) {
        return CGSizeMake(size.width, minContentSizeHeight);
    }
    return size;
}

@end

@interface GKSmoothListView()<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UITableView  *tableView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView            *loadingBgView;

@property (nonatomic, weak) UIScrollView *smoothScrollView;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) BOOL isRequest;

@property (nonatomic, assign) GKSmoothListType listType;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, weak) GKBallLoadingView *loadingView;

@end

@implementation GKSmoothListView

- (instancetype)initWithListType:(GKSmoothListType)listType deleagte:(nonnull id<GKSmoothListViewDelegate>)delegate {
    if (self = [super init]) {
        self.listType = listType;
        self.delegate = delegate;
        
        if (listType == GKSmoothListType_ScrollView) {
            self.smoothScrollView = self.scrollView;
        }else if (listType == GKSmoothListType_TableView) {
            self.smoothScrollView = self.tableView;
        }else if (listType == GKSmoothListType_CollectionView) {
            self.smoothScrollView = self.collectionView;
        }
        [self addSubview:self.smoothScrollView];
        
        [self.smoothScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        __weak typeof(self) weakSelf = self;
        self.smoothScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            __strong typeof(weakSelf) self = weakSelf;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.count = 30;
                [self reloadData];
                [self.smoothScrollView.mj_header endRefreshing];
            });
        }];
        self.smoothScrollView.mj_header.ignoredScrollViewContentInsetTop = [self.delegate smoothViewHeaderContainerHeight];
        
        self.smoothScrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            __strong typeof(weakSelf) self = weakSelf;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.count+= 10;
                [self reloadData];
                if (self.count >= 100) {
                    [self.smoothScrollView.mj_footer endRefreshingWithNoMoreData];
                }else {
                    [self.smoothScrollView.mj_footer endRefreshing];
                }
            });
        }];
        
//        self.count = 100;
//        [self reloadData];
        
        [self.smoothScrollView addSubview:self.loadingBgView];
        self.loadingBgView.frame = CGRectMake(0, 20, kScreenW, 100);
    }
    return self;
}

- (instancetype)initWithListType:(GKSmoothListType)listType deleagte:(id<GKSmoothListViewDelegate>)delegate index:(NSInteger)index {
    if (self = [super init]) {
        self.listType = listType;
        self.delegate = delegate;
        self.index = index;
        
        if (listType == GKSmoothListType_ScrollView) {
            self.smoothScrollView = self.scrollView;
        }else if (listType == GKSmoothListType_TableView) {
            self.smoothScrollView = self.tableView;
        }else if (listType == GKSmoothListType_CollectionView) {
            self.smoothScrollView = self.collectionView;
        }
        [self addSubview:self.smoothScrollView];
        
        [self.smoothScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
//        self.smoothScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                self.count = 30;
//                [self reloadData];
//                [self.smoothScrollView.mj_header endRefreshing];
//            });
//        }];
        self.smoothScrollView.mj_header.ignoredScrollViewContentInsetTop = [self.delegate smoothViewHeaderContainerHeight];
        
        __weak typeof(self) weakSelf = self;
        self.smoothScrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            __strong typeof(weakSelf) self = weakSelf;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.count+= 10;
                [self reloadData];
                if (self.count >= 100) {
                    [self.smoothScrollView.mj_footer endRefreshingWithNoMoreData];
                }else {
                    [self.smoothScrollView.mj_footer endRefreshing];
                }
            });
        }];
        
//        self.count = 100;
//        [self reloadData];
        
        [self.smoothScrollView addSubview:self.loadingBgView];
        self.loadingBgView.frame = CGRectMake(0, 20, kScreenW, 100);
    }
    return self;
}

- (void)stopLoading {
    [self.loadingView stopLoading];
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
}

- (void)requestData {
    if (self.isRequest) return;
    
    GKBallLoadingView *loadingView = [GKBallLoadingView loadingViewInView:self.loadingBgView];
    [loadingView startLoading];
    self.loadingView = loadingView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [loadingView stopLoading];
        self.loadingBgView.hidden = YES;
        
        self.count = 30;
        if (self.index == 0) {
            self.count = 30;
        }else if (self.count == 1) {
            self.count = 3;
        }else {
            self.count = 5;
        }
        
        [self reloadData];
    });
}

- (void)reloadData {
    if (self.listType == GKSmoothListType_ScrollView) {
        self.scrollView.backgroundColor = UIColor.whiteColor;
        UIView *lastView = nil;
        for (NSInteger i = 0; i < self.count; i++) {
            UILabel *label = [UILabel new];
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:16.0f];
            label.text = [NSString stringWithFormat:@"第%zd行", i + 1];
            [self.scrollView addSubview:label];
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@30);
                make.top.equalTo(lastView ? lastView.mas_bottom : @0);
                make.width.mas_equalTo(self.scrollView.mas_width);
                make.height.mas_equalTo(50.0f);
            }];
            
            lastView = label;
        }
        
        [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            make.bottom.equalTo(lastView.mas_bottom);
        }];
    }else if (self.listType == GKSmoothListType_TableView) {
        [self.tableView reloadData];
    }else if (self.listType == GKSmoothListType_CollectionView) {
        [self.collectionView reloadData];
    }
}

#pragma mark - GKPageSmoothListViewDelegate
- (UIView *)listView {
    return self;
}

- (UIScrollView *)listScrollView {
    return self.smoothScrollView;
}

- (BOOL)listScrollViewShouldReset {
    return NO;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行", indexPath.row + 1];
    return cell;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor blackColor];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *textLabel = [UILabel new];
    textLabel.font = [UIFont systemFontOfSize:16.0f];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.text = [NSString stringWithFormat:@"第%zd", indexPath.item + 1];
    [cell.contentView addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(cell.contentView);
    }];
    
    return cell;
}

#pragma mark - 懒加载
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
//        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableViewCell"];
        _tableView.rowHeight = 50.0f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        GKSmoothListLayout *layout = [GKSmoothListLayout new];
        layout.minimumLineSpacing = 20;
        layout.minimumInteritemSpacing = 20;
        layout.itemSize = CGSizeMake((kScreenW - 60)/2, (kScreenW - 60)/2);
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"];
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

- (UIView *)loadingBgView {
    if (!_loadingBgView) {
        _loadingBgView = [UIView new];
    }
    return _loadingBgView;
}

@end
