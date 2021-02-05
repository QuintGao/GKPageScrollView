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
    
    self.gk_navTitle = @"ObjcDemo";
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    self.dataSource = @[@{@"group": @"GKPageScrollView", @"list": @[@{@"title": @"微博个人主页", @"class": @"GKWBViewController"},
                                                                    @{@"title": @"微博发现页", @"class": @"GKWBFindViewController"},
                                                                    @{@"title": @"网易云歌手页", @"class": @"GKWYViewController"},
                                                                    @{@"title": @"抖音个人主页", @"class": @"GKDYViewController"},
                                                                    @{@"title": @"主页刷新", @"class": @"GKMainRefreshViewController"},
                                                                    @{@"title": @"列表刷新", @"class": @"GKListRefreshViewController"},
                                                                    @{@"title": @"列表懒加载", @"class": @"GKListLoadViewController"},
                                                                    @{@"title": @"item加载", @"class": @"GKItemLoadViewController"},
                                                                    @{@"title": @"Header左右滑动", @"class": @"GKHeaderScrollViewController"},
                                                                    @{@"title": @"VTMagic使用", @"class": @"GKVTMagicViewController"},
                                                                    @{@"title": @"嵌套使用1", @"class": @"GKNest1ViewController"},
                                                                    @{@"title": @"嵌套使用2", @"class": @"GKNest2ViewController"}]},
                        @{@"group": @"GKPageSmoothView", @"list": @[@{@"title": @"豆瓣电影主页", @"class": @"GKDBViewController"},
                                                                    @{@"title": @"滑动延续", @"class": @"GKSmoothViewController"},
                                                                    @{@"title": @"上下滑动切换tab", @"class": @"GKPinLocationViewController"}]}];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = self.dataSource[section];
    return [dic[@"list"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = self.dataSource[indexPath.section];
    
    cell.textLabel.text = dic[@"list"][indexPath.row][@"title"];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [UIView new];
    headerView.backgroundColor = UIColor.lightGrayColor;
    UILabel *title = [UILabel new];
    title.font = [UIFont systemFontOfSize:16];
    title.textColor = UIColor.blackColor;
    NSDictionary *dic = self.dataSource[section];
    title.text = dic[@"group"];
    [headerView addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(10);
        make.centerY.equalTo(headerView);
    }];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataSource[indexPath.section];
    
    NSDictionary *dict = dic[@"list"][indexPath.row];
    
    NSString *className = dict[@"class"];
    
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
