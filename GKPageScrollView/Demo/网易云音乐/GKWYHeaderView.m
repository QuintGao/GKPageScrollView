//
//  GKWYHeaderView.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKWYHeaderView.h"

@interface GKWYHeaderView()

@property (nonatomic, strong) UIImageView           *bgImgView;
@property (nonatomic, strong) UIVisualEffectView    *effectView;

@property (nonatomic, strong) UILabel               *nameLabel;

@property (nonatomic, assign) CGRect                bgImgFrame;

@end

@implementation GKWYHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgImgView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.effectView];
        
        self.bgImgFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.bgImgView.frame = self.bgImgFrame;
        
        [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15.0f);
            make.bottom.equalTo(self).offset(-20.0f);
        }];
    }
    return self;
}

- (void)scrollViewDidScroll:(CGFloat)offsetY {
    // 上滑显示模糊效果
    // offsetY < 50 0
    // 50 < offsetY < kHeaderHeight - kNavBarHeight  渐变
    // offsetY > kHeaderHeight - kNavBarHeight 1
    CGFloat alpha = 0;
    if (offsetY < 50) {
        alpha = 0;
    }else if (offsetY > kWYHeaderHeight - kNavBarHeight) {
        alpha = 1;
    }else {
        alpha = (offsetY - 50) / (kWYHeaderHeight - kNavBarHeight - 50);
    }
    self.effectView.alpha = alpha;
    
    // 下拉放大
    CGRect frame = self.bgImgFrame;
    frame.size.height -= offsetY;
    frame.origin.y = offsetY;
    self.bgImgView.frame = frame;
}

#pragma mark - 懒加载
- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [UIImageView new];
        _bgImgView.image = [UIImage imageNamed:@"wy_bg"];
        _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImgView.clipsToBounds = YES;
    }
    return _bgImgView;
}

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _effectView.alpha = 0;
    }
    return _effectView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.text = @"展展与罗罗";
    }
    return _nameLabel;
}

@end
