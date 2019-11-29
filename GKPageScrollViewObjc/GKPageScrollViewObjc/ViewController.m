//
//  ViewController.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/2/20.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray   *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navTitle = @"Demo";
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    self.dataSource = @[@{@"title": @"微博个人主页", @"class": @"GKWBViewController"},
                        @{@"title": @"微博发现页", @"class": @"GKWBFindViewController"},
                        @{@"title": @"网易云歌手页", @"class": @"GKWYViewController"},
                        @{@"title": @"抖音个人主页", @"class": @"GKDYViewController"},
                        @{@"title": @"主页刷新", @"class": @"GKMainRefreshViewController"},
                        @{@"title": @"列表刷新", @"class": @"GKListRefreshViewController"},
                        @{@"title": @"列表懒加载", @"class": @"GKListLoadViewController"},
                        @{@"title": @"item加载", @"class": @"GKItemLoadViewController"},
                        @{@"title": @"Header左右滑动", @"class": @"GKHeaderScrollViewController"},
                        @{@"title": @"VTMagic使用", @"class": @"GKVTMagicViewController"},
//                        @{@"title": @"测试", @"class": @"GKTestViewController"},
                        @{@"title": @"嵌套使用1", @"class": @"GKNest1ViewController"},
                        @{@"title": @"嵌套使用2", @"class": @"GKNest2ViewController"}];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataSource[indexPath.row][@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataSource[indexPath.row];
    
    NSString *className = dic[@"class"];
    
    UIViewController *vc = [[NSClassFromString(className) alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
