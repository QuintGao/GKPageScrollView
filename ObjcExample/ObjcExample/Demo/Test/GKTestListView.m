//
//  GKTestListView.m
//  GKPageScrollViewDemo
//
//  Created by gaokun on 2018/12/6.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKTestListView.h"
#import <MJRefresh/MJRefresh.h>

@interface GKTestListView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView   *listTableView;

@property (nonatomic, strong) void(^listScrollViewScrollCallback)(UIScrollView *scrollView);

@property (nonatomic, assign) CGFloat beginOffset;

@property (nonatomic, assign) BOOL      isLoad;

@end

@implementation GKTestListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.listTableView];
        
        [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self setCount:20];
        
//        self.listTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//            NSLog(@"mj_footer刷新");
//        }];
//
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadData)];
//        [self.listTableView addGestureRecognizer:tap];
    }
    return self;
}

- (void)setCount:(NSInteger)count {
    self.isLoad = YES;
    
    [self.listTableView reloadData];
}

- (void)loadData {
    if ([self.delegate respondsToSelector:@selector(listLoadData)]) {
        [self.delegate listLoadData];
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.isLoad ? 20 : 0;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
//    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行", indexPath.row + 1];
//    return cell;
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.listScrollViewScrollCallback ? : self.listScrollViewScrollCallback(scrollView);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"list开始滑动");
    self.beginOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"list结束滑动");
    if (scrollView.contentOffset.y >= self.beginOffset) {
        if (scrollView.contentOffset.y == self.beginOffset && self.beginOffset == 0) return;
        [self btmHide];
    }else {
        [self btmShow];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"list结束滑动，无减速");
    if (!decelerate) {
        if (scrollView.contentOffset.y >= self.beginOffset) {
            if (scrollView.contentOffset.y == self.beginOffset && self.beginOffset == 0) return;
            [self btmHide];
        }else {
            [self btmShow];
        }
    }
}

- (void)btmShow {
    if ([self.delegate respondsToSelector:@selector(bottomShow)]) {
        [self.delegate bottomShow];
    }
}

- (void)btmHide {
    if ([self.delegate respondsToSelector:@selector(bottomHide)]) {
        [self.delegate bottomHide];
    }
}

#pragma mark - GKPageListViewDelegate
- (UIScrollView *)listScrollView {
    return self.listTableView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.listScrollViewScrollCallback = callback;
}

#pragma mark - 懒加载
- (UITableView *)listTableView {
    if (!_listTableView) {
        _listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listTableView.dataSource = self;
        _listTableView.delegate = self;
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"listCell"];
    }
    return _listTableView;
}

@end
