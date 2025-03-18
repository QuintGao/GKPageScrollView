//
//  GKCustomSegmentedView.m
//  ObjcExample
//
//  Created by QuintGao on 2025/3/18.
//

#import "GKCustomSegmentedView.h"

@interface GKCustomSegmentedView()

@end

@implementation GKCustomSegmentedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = UIColor.whiteColor;
    
    NSArray *titles = @[@"作品", @"收藏", @"喜欢"];
    [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:obj forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        btn.tag = idx;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width / 3;
    CGFloat height = self.bounds.size.height;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(idx * width, 0, width, height);
    }];
}

- (void)btnClick:(UIButton *)sender {
    NSInteger index = sender.tag;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == index) {
            [obj setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        } else {
            [obj setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(didClickSelectAtIndex:)]) {
        [self.delegate didClickSelectAtIndex:index];
    }
}

- (void)scrollSelectWithIndex:(NSInteger)index {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == index) {
            [obj setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        } else {
            [obj setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        }
    }];
}

@end
