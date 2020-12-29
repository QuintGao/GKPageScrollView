//
//  GKNestView.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/9/30.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "GKNestView.h"
#import "GKNestListView.h"
#import <JXCategoryView/JXCategoryView.h>

@interface GKNestView()<JXCategoryViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) JXCategoryTitleView *categoryView;

// 综合
@property (nonatomic, strong) GKNestListView *compListView;

// 销量
@property (nonatomic, strong) GKNestListView *saleListView;

// 价格
@property (nonatomic, strong) GKNestListView *priceListView;

@property (nonatomic, weak) UIScrollView     *currentListScrollView;
@property (nonatomic, copy) void (^listScrollCallback)(UIScrollView *scrollView);

@end

@implementation GKNestView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.categoryView];
        [self addSubview:self.contentScrollView];
        
        [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(40.0f);
        }];
        
        [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(self.categoryView.mas_bottom);
        }];
        
        [self categoryView:self.categoryView didSelectedItemAtIndex:0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat listW = self.contentScrollView.frame.size.width;
    CGFloat listH = self.contentScrollView.frame.size.height;
    
    self.compListView.frame = CGRectMake(0, 0, listW, listH);
    self.saleListView.frame = CGRectMake(listW, 0, listW, listH);
    self.priceListView.frame = CGRectMake(2 * listW, 0, listW, listH);
    
    self.contentScrollView.contentSize = CGSizeMake(3 * listW, 0);
}

#pragma mark - GKPageListViewDelegate
- (UIView *)listView {
    return self;
}

- (UIScrollView *)listScrollView {
    return self.currentListScrollView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.listScrollCallback = callback;
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            self.currentListScrollView = self.compListView.tableView;
            break;
        case 1:
            self.currentListScrollView = self.saleListView.tableView;
            break;
        case 2:
            self.currentListScrollView = self.priceListView.tableView;
            break;
            
        default:
            break;
    }
}

#pragma mark - 懒加载
- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] init];
        _categoryView.backgroundColor = [UIColor whiteColor];
        _categoryView.titles = @[@"综合", @"销量", @"价格"];
        _categoryView.titleFont = [UIFont systemFontOfSize:14.0f];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:14.0f];
        _categoryView.titleColor = [UIColor grayColor];
        _categoryView.titleSelectedColor = [UIColor grayColor];
        _categoryView.delegate = self;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
        _categoryView.indicators = @[lineView];
        
        _categoryView.contentScrollView = self.contentScrollView;
    }
    return _categoryView;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.bounces = NO;
        _contentScrollView.delegate = self;
        
        [_contentScrollView addSubview:self.compListView];
        [_contentScrollView addSubview:self.saleListView];
        [_contentScrollView addSubview:self.priceListView];
    }
    return _contentScrollView;
}

- (GKNestListView *)compListView {
    if (!_compListView) {
        _compListView = [GKNestListView new];
        
        __weak typeof(self) weakSelf = self;
        _compListView.scrollCallback = ^(UIScrollView * _Nonnull scrollView) {
            !weakSelf.listScrollCallback ? : weakSelf.listScrollCallback(scrollView);
        };
    }
    return _compListView;
}

- (GKNestListView *)saleListView {
    if (!_saleListView) {
        _saleListView = [GKNestListView new];
        
        __weak typeof(self) weakSelf = self;
        _saleListView.scrollCallback = ^(UIScrollView * _Nonnull scrollView) {
            !weakSelf.listScrollCallback ? : weakSelf.listScrollCallback(scrollView);
        };
    }
    return _saleListView;
}

- (GKNestListView *)priceListView {
    if (!_priceListView) {
        _priceListView = [GKNestListView new];
        
        __weak typeof(self) weakSelf = self;
        _priceListView.scrollCallback = ^(UIScrollView * _Nonnull scrollView) {
            !weakSelf.listScrollCallback ? : weakSelf.listScrollCallback(scrollView);
        };
    }
    return _priceListView;
}

@end
