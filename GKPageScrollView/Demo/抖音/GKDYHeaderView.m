//
//  GKDYHeaderView.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYHeaderView.h"

@interface GKDYHeaderView()

@property (nonatomic, assign) CGRect        bgImgFrame;
@property (nonatomic, strong) UIImageView   *bgImgView;

@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UIImageView   *iconImgView;
@property (nonatomic, strong) UIImageView   *contentImgView;

@end

@implementation GKDYHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgImgView];
        
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.iconImgView];
        [self.contentView addSubview:self.contentImgView];
        
        self.bgImgFrame = CGRectMake(0, 0, frame.size.width, kDYBgImgHeight);
        self.bgImgView.frame = self.bgImgFrame;
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(kDYBgImgHeight, 0, 0, 0));
        }];
        
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10.0f);
            make.top.equalTo(self.contentView).offset(-15.0f);
            make.width.height.mas_equalTo(96.0f);
        }];
        
        [self.contentImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImgView.mas_bottom);
            make.left.right.bottom.equalTo(self);
        }];
    }
    return self;
}

- (void)scrollViewDidScroll:(CGFloat)offsetY {
    CGRect frame = self.bgImgFrame;
    // 上下放大
    frame.size.height -= offsetY;
    frame.origin.y = offsetY;
    
    // 左右放大
    if (offsetY <= 0) {
        frame.size.width = frame.size.height * self.bgImgFrame.size.width / self.bgImgFrame.size.height;
        frame.origin.x   = (self.frame.size.width - frame.size.width) / 2;
    }
    
    self.bgImgView.frame = frame;
}

#pragma mark - 懒加载
- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [UIImageView new];
        _bgImgView.image = [UIImage imageNamed:@"dy_bg"];
        _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImgView.clipsToBounds = YES;
    }
    return _bgImgView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = GKColorRGB(34, 33, 37);
    }
    return _contentView;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [UIImageView new];
        _iconImgView.image = [UIImage imageNamed:@"dy_icon"];
        _iconImgView.layer.cornerRadius = 48.0f;
        _iconImgView.layer.masksToBounds = YES;
        _iconImgView.layer.borderColor = GKColorRGB(34, 33, 37).CGColor;
        _iconImgView.layer.borderWidth = 3;
    }
    return _iconImgView;
}

- (UIImageView *)contentImgView {
    if (!_contentImgView) {
        _contentImgView = [UIImageView new];
        _contentImgView.image = [UIImage imageNamed:@"dy_content"];
    }
    return _contentImgView;
}

@end
