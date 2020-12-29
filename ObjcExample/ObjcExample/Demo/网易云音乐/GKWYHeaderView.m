//
//  GKWYHeaderView.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKWYHeaderView.h"

@interface GKWYHeaderView()

@property (nonatomic, strong) UILabel               *countLabel;

@property (nonatomic, strong) UILabel               *tagLabel;

@property (nonatomic, strong) UIButton              *personalBtn;

@property (nonatomic, strong) UIButton              *collectBtn;

@end

@implementation GKWYHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.nameLabel];
        [self addSubview:self.countLabel];
        [self addSubview:self.tagLabel];
        [self addSubview:self.personalBtn];
        [self addSubview:self.collectBtn];
        
        // 110 44
        [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-ADAPTATIONRATIO * 26.0f);
            make.left.equalTo(self).offset(ADAPTATIONRATIO * 15.0f);
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.tagLabel);
            make.bottom.equalTo(self.tagLabel.mas_top).offset(-ADAPTATIONRATIO * 12.0f);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.tagLabel);
            make.bottom.equalTo(self.countLabel.mas_top).offset(-20.0f);
        }];
        
        [self.collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.tagLabel.mas_bottom);
            make.right.equalTo(self).offset(-ADAPTATIONRATIO * 20.0f);
            make.width.mas_equalTo(ADAPTATIONRATIO * 150.0f);
            make.height.mas_equalTo(ADAPTATIONRATIO * 50.0f);
        }];
        
        [self.personalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.tagLabel.mas_bottom);
            make.right.equalTo(self.collectBtn.mas_left).offset(-ADAPTATIONRATIO * 20.0f);
            make.width.mas_equalTo(ADAPTATIONRATIO * 150.0f);
            make.height.mas_equalTo(ADAPTATIONRATIO * 50.0f);
        }];
    }
    return self;
}

#pragma mark - 懒加载
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.text = @"展展与罗罗";
    }
    return _nameLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [UILabel new];
        _countLabel.font = [UIFont systemFontOfSize:13.0f];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.text = @"被收藏了60182次";
    }
    return _countLabel;
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [UILabel new];
        _tagLabel.font = [UIFont systemFontOfSize:13.0f];
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.text = @"网页音乐人";
    }
    return _tagLabel;
}

- (UIButton *)personalBtn {
    if (!_personalBtn) {
        _personalBtn = [UIButton new];
        _personalBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_personalBtn setTitle:@"个人主页" forState:UIControlStateNormal];
        [_personalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _personalBtn.layer.cornerRadius = ADAPTATIONRATIO * 25.0f;
        _personalBtn.layer.masksToBounds = YES;
        _personalBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _personalBtn.layer.borderWidth = 0.5f;
    }
    return _personalBtn;
}

- (UIButton *)collectBtn {
    if (!_collectBtn) {
        _collectBtn = [UIButton new];
        _collectBtn.backgroundColor = [UIColor redColor];
        _collectBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_collectBtn setTitle:@"收藏" forState:UIControlStateNormal];
        [_collectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _collectBtn.layer.cornerRadius = ADAPTATIONRATIO * 22.0f;
        _collectBtn.layer.masksToBounds = YES;
    }
    return _collectBtn;
}

@end
