//
//  GKIndexListViewController.m
//  GKPageScrollViewDemo
//
//  Created by QuintGao on 2018/12/11.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKIndexListViewController.h"

@interface GKIndexListViewController()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) void(^listScrollViewScrollCallback)(UIScrollView *scrollView);

@property (nonatomic, strong) NSArray *array;

@property (nonatomic, assign) BOOL isChangeSection;

@end

@implementation GKIndexListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.array = @[@{@"title": @"A", @"list": @[@"assfsdf", @"adfdfsdf", @"adfkdfdsf", @"adkfjdik", @"adkjfdsf"]},
                   @{@"title": @"B", @"list": @[@"bsgdsfd", @"badsfsfs", @"bdsafsdfd", @"bidfjidd", @"bsidfadd"]},
                   @{@"title": @"C", @"list": @[@"csfsdfs", @"csdfsfds", @"csdfasdif", @"casdifdj", @"casdkfds"]},
                   @{@"title": @"D", @"list": @[@"dsafdfs", @"dsfdsfdf", @"dsfadfdfd", @"dsafodsf", @"dsafoisf"]},
                   @{@"title": @"E", @"list": @[@"esafdfs", @"esfdsfdf", @"esfadfdfd", @"esafodsf", @"esafoisf"]},
                   @{@"title": @"F", @"list": @[@"fsafdfs", @"fsfdsfdf", @"fsfadfdfd", @"fsafodsf", @"fsafoisf"]}];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (!self.view.superview) return;
    if (CGSizeEqualToSize(self.view.superview.frame.size, CGSizeZero)) return;
    
    CGRect frame = self.view.frame;
    frame.size = self.view.superview.bounds.size;
    self.view.frame = frame;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *list = self.array[section][@"list"];
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    NSArray *list = self.array[indexPath.section][@"list"];
    cell.textLabel.text = list[indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.array[section][@"title"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[@"A", @"B", @"C", @"D", @"E", @"F"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    self.isChangeSection = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isChangeSection = NO;
    });
    return index;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.listScrollViewScrollCallback ? : self.listScrollViewScrollCallback(scrollView);
}

#pragma mark - GKPageListViewDelegate or GKPageSmoothListViewDelegate
- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.listScrollViewScrollCallback = callback;
}

- (BOOL)isListScrollViewNeedScroll {
    return self.isChangeSection;
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"listCell"];
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
    }
    return _tableView;
}

@end
