//
//  GKNavigationBarConfigure.m
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/10.
//  Copyright © 2017年 高坤. All rights reserved.
//  https://github.com/QuintGao/GKNavigationBarViewController.git

#import "GKNavigationBarConfigure.h"
#import "UIViewController+GKCategory.h"

@interface GKNavigationBarConfigure()

@property (nonatomic, assign) BOOL  gk_lastDisableFixSpace;

@end

@implementation GKNavigationBarConfigure

static GKNavigationBarConfigure *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GKNavigationBarConfigure new];
    });
    return instance;
}

// 设置默认的导航栏外观
- (void)setupDefaultConfigure {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleColor      = [UIColor blackColor];
    
    self.titleFont       = [UIFont boldSystemFontOfSize:17.0];
    
    self.statusBarHidden = NO;
    
    self.statusBarStyle  = UIStatusBarStyleDefault;
    
    self.backStyle       = GKNavigationBarBackStyleBlack;
    
    self.gk_navItemLeftSpace   = 0;
    self.gk_navItemRightSpace  = 0;
    
    self.gk_pushTransitionCriticalValue = 0.3;
    self.gk_popTransitionCriticalValue  = 0.5;
    
    self.gk_translationX = 5.0f;
    self.gk_translationY = 5.0f;
    self.gk_scaleX = 0.95;
    self.gk_scaleY = 0.97;
    
    self.gk_lastDisableFixSpace = self.gk_lastDisableFixSpace;
}

- (void)setGk_navItemLeftSpace:(CGFloat)gk_navItemLeftSpace {
    _gk_navItemLeftSpace = gk_navItemLeftSpace;
}

- (void)setGk_navItemRightSpace:(CGFloat)gk_navItemRightSpace {
    _gk_navItemRightSpace = gk_navItemRightSpace;
}

- (void)setupCustomConfigure:(void (^)(GKNavigationBarConfigure *))block {
    [self setupDefaultConfigure];
    
    !block ? : block(self);
    
    self.gk_lastDisableFixSpace = self.gk_disableFixSpace;
}

// 更新配置
- (void)updateConfigure:(void (^)(GKNavigationBarConfigure *configure))block {
    !block ? : block(self);
    
    self.gk_lastDisableFixSpace = self.gk_disableFixSpace;
}

// 获取当前显示的控制器
- (UIViewController *)visibleController {
    return [[[UIApplication sharedApplication].windows firstObject].rootViewController gk_visibleViewControllerIfExist];
}

- (CGFloat)gk_fixedSpace {
    CGSize screentSize = [UIScreen mainScreen].bounds.size;
    return MIN(screentSize.width, screentSize.height) > 375 ? 20 : 16;
}

@end
