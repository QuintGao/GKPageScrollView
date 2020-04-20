//
//  GKWYListViewController.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKWYListViewController.h"

@interface GKWYListViewController ()

@property (nonatomic, copy) void(^listScrollViewScrollBlock)(UIScrollView *scrollView);

@end

@implementation GKWYListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"listCell"];
    self.tableView.showsVerticalScrollIndicator = NO;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行", indexPath.row + 1];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.listScrollViewScrollBlock ? : self.listScrollViewScrollBlock(scrollView);
}

#pragma mark - GKPageListViewDelegate
- (UIScrollView *)listScrollView {
    return self.tableView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView * _Nonnull))callback {
    self.listScrollViewScrollBlock = callback;
}

@end
