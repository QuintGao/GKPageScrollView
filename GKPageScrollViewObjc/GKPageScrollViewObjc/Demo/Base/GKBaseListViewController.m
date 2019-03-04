//
//  GKBaseListViewController.m
//  GKPageScrollViewDemo
//
//  Created by gaokun on 2018/12/11.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKBaseListViewController.h"
#import <MJRefresh/MJRefresh.h>

@interface GKBaseListViewController()

@property (nonatomic, copy) void(^listScrollViewScrollCallback)(UIScrollView *scrollView);

@end

@implementation GKBaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    self.count = 30;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"listCell"];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefreshDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.count += 20;
            
            if (self.count >= 100) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [self.tableView.mj_footer endRefreshing];
            }
            [self.tableView reloadData];
        });
    }];
}

- (void)addHeaderRefresh {
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefreshDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
            
            self.count = 30;
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行", indexPath.row + 1];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.listScrollViewScrollCallback ? : self.listScrollViewScrollCallback(scrollView);
}

#pragma mark - GKPageListViewDelegate
- (UIScrollView *)listScrollView {
    return self.tableView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.listScrollViewScrollCallback = callback;
}

@end
