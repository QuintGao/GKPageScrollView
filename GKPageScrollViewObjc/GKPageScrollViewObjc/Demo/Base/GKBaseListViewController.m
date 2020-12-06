//
//  GKBaseListViewController.m
//  GKPageScrollViewDemo
//
//  Created by gaokun on 2018/12/11.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKBaseListViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <WebKit/WebKit.h>

@interface GKBaseListViewController()<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, WKNavigationDelegate>

@property (nonatomic, strong) UIImageView   *loadingView;
@property (nonatomic, strong) UILabel       *loadLabel;

@property (nonatomic, copy) void(^listScrollViewScrollCallback)(UIScrollView *scrollView);

@property (nonatomic, assign) GKBaseListType listType;
@property (nonatomic, weak) UIScrollView *currentScrollView;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation GKBaseListViewController

- (instancetype)initWithListType:(GKBaseListType)listType {
    if (self = [super init]) {
        self.listType = listType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.listType == GKBaseListType_UITableView) {
        [self.view addSubview:self.tableView];
        self.currentScrollView = self.tableView;
    }else if (self.listType == GKBaseListType_UICollectionView) {
        [self.view addSubview:self.collectionView];
        self.currentScrollView = self.collectionView;
    }else if (self.listType == GKBaseListType_UIScrollView) {
        [self.view addSubview:self.scrollView];
        self.currentScrollView = self.scrollView;
    }else if (self.listType == GKBaseListType_WKWebView) {
        [self.view addSubview:self.webView];
        self.currentScrollView = self.webView.scrollView;
    }
    
    if (self.listType == GKBaseListType_WKWebView) {
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }else {
        [self.currentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    if (self.listType != GKBaseListType_WKWebView) {
        self.currentScrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefreshDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self loadMoreData];
            });
        }];
    }
    
    if (self.shouldLoadData) {
        [self.currentScrollView addSubview:self.loadingView];
        [self.currentScrollView addSubview:self.loadLabel];
        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.currentScrollView).offset(40.0f);
            make.centerX.equalTo(self.currentScrollView);
        }];
        
        [self.loadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loadingView.mas_bottom).offset(10.0f);
            make.centerX.equalTo(self.loadingView);
        }];
        
        self.count = 0;
        self.currentScrollView.mj_footer.hidden = self.count == 0;
        [self reloadData];
        
        [self showLoading];
        if (self.listType == GKBaseListType_WKWebView) {
            [self loadData];
        }else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hideLoading];
                [self loadData];
            });
        }
    }else {
        [self loadData];
    }
}

- (void)loadData {
    self.count = 30;
    
    if (self.listType == GKBaseListType_UIScrollView) {
        [self addCellToScrollView];
    }else if (self.listType == GKBaseListType_WKWebView) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/QuintGao/GKPageScrollView"]]];
    }
    
    [self reloadData];
}

- (void)loadMoreData {
    self.count += 20;
    
    if (self.count >= 100) {
        [self.currentScrollView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.currentScrollView.mj_footer endRefreshing];
    }
    
    if (self.listType == GKBaseListType_UIScrollView) {
        [self addCellToScrollView];
    }
    
    [self reloadData];
}

- (void)addCellToScrollView {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
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
        make.edges.equalTo(self.view);
        make.bottom.equalTo(lastView.mas_bottom);
    }];
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
    self.currentScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefreshDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.currentScrollView.mj_header endRefreshing];
            
            self.count = 30;
            [self reloadData];
        });
    }];
}

- (void)reloadData {
    if (self.listType == GKBaseListType_UITableView) {
        [self.tableView reloadData];
    }else if (self.listType == GKBaseListType_UICollectionView) {
        [self.collectionView reloadData];
    }
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

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    self.collectionView.mj_footer.hidden = self.count == 0;
    return self.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor redColor];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *textLabel = [UILabel new];
    textLabel.font = [UIFont systemFontOfSize:16.0f];
    textLabel.textColor = [UIColor blackColor];
    textLabel.text = [NSString stringWithFormat:@"第%zd", indexPath.item + 1];
    [cell.contentView addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(cell.contentView);
    }];
    
    return cell;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载成功");
    [self hideLoading];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
    [self hideLoading];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.listScrollViewScrollCallback ? : self.listScrollViewScrollCallback(scrollView);
}

#pragma mark - GKPageListViewDelegate
- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.currentScrollView;
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
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"listCell"];
    }
    return _tableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 20;
        layout.minimumInteritemSpacing = 20;
        layout.itemSize = CGSizeMake((kScreenW - 60)/2, (kScreenW - 60)/2);
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _collectionView.alwaysBounceVertical = YES;
    }
    return _collectionView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollView;
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.scrollView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _webView.navigationDelegate = self;
    }
    return _webView;
}

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
