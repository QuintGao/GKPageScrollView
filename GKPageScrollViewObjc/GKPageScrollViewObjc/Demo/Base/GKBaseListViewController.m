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

@property (nonatomic, strong) UIImageView   *loadingView;
@property (nonatomic, strong) UILabel       *loadLabel;

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
    
    if (self.shouldLoadData) {
        [self.tableView addSubview:self.loadingView];
        [self.tableView addSubview:self.loadLabel];
        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tableView).offset(40.0f);
            make.centerX.equalTo(self.tableView);
        }];
        
        [self.loadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loadingView.mas_bottom).offset(10.0f);
            make.centerX.equalTo(self.loadingView);
        }];
        
        [self loadData];
    }
}

- (void)loadData {
    self.count = 0;
    
    [self showLoading];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.count = 30;
        
        [self hideLoading];
        
        [self.tableView reloadData];
    });
}

- (void)showLoading {
    self.loadingView.hidden = NO;
    self.loadLabel.hidden   = NO;
    [self.loadingView startAnimating];
}

- (void)hideLoading {
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    self.loadLabel.hidden   = YES;
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
    self.tableView.mj_footer.hidden = self.count == 0;
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行", indexPath.row + 1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    !self.scrollToTop ? : self.scrollToTop(self, indexPath);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.listScrollViewScrollCallback ? : self.listScrollViewScrollCallback(scrollView);
}

#pragma mark - GKPageListViewDelegate
- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.listScrollViewScrollCallback = callback;
}

- (UIImage *)changeImageWithImage:(UIImage *)image color:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 懒加载
- (UIImageView *)loadingView {
    if (!_loadingView) {
        NSMutableArray *images = [NSMutableArray new];
        for (NSInteger i = 0; i < 4; i++) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_list_icn_loading%zd", i + 1];
            
            UIImage *img = [self changeImageWithImage:[UIImage imageNamed:imageName] color:GKColorRGB(200, 38, 39)];
            
            [images addObject:img];
        }
        
        for (NSInteger i = 4; i > 0; i--) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_list_icn_loading%zd", i];
            
            UIImage *img = [self changeImageWithImage:[UIImage imageNamed:imageName] color:GKColorRGB(200, 38, 39)];
            
            [images addObject:img];
        }
        
        UIImageView *loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
        loadingView.animationImages     = images;
        loadingView.animationDuration   = 0.75;
        loadingView.hidden              = YES;
        
        _loadingView = loadingView;
    }
    return _loadingView;
}

- (UILabel *)loadLabel {
    if (!_loadLabel) {
        _loadLabel              = [UILabel new];
        _loadLabel.font         = [UIFont systemFontOfSize:14.0f];
        _loadLabel.textColor    = [UIColor grayColor];
        _loadLabel.text         = @"正在加载...";
        _loadLabel.hidden       = YES;
    }
    return _loadLabel;
}

@end
