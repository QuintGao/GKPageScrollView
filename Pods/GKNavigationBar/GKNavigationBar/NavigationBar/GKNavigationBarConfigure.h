//
//  GKNavigationBarConfigure.h
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+GKNavigationBar.h"
#import "UIViewController+GKNavigationBar.h"
#import "UIBarButtonItem+GKNavigationBar.h"
#import "UIImage+GKNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKNavigationBarConfigure : NSObject

/// 导航栏背景色，默认白色
@property (nonatomic, strong) UIColor   *backgroundColor;

/// 导航栏分割线背景色，默认nil，使用系统颜色
@property (nonatomic, strong) UIColor   *lineColor;

/// 导航栏分割线是否隐藏，默认NO
@property (nonatomic, assign) BOOL      lineHidden;

/// 导航栏标题颜色，默认黑色
@property (nonatomic, strong) UIColor   *titleColor;

/// 导航栏标题字体，默认系统字体17
@property (nonatomic, strong) UIFont    *titleFont;

/// 返回按钮图片(默认nil，优先级高于backStyle)
@property (nonatomic, strong) UIImage   *backImage;

/// 返回按钮样式，默认GKNavigationBarBackStyleBlack
@property (nonatomic, assign) GKNavigationBarBackStyle backStyle;

/// 是否禁止导航栏左右item间距调整，默认是NO
@property (nonatomic, assign) BOOL      gk_disableFixSpace;

/// 导航栏左侧按钮距屏幕左边间距，默认是0，可自行调整
@property (nonatomic, assign) CGFloat   gk_navItemLeftSpace;

/// 导航栏右侧按钮距屏幕右边间距，默认是0，可自行调整
@property (nonatomic, assign) CGFloat   gk_navItemRightSpace;

/// 是否隐藏状态栏，默认NO
@property (nonatomic, assign) BOOL      statusBarHidden;

/// 状态栏类型，默认UIStatusBarStyleDefault
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

// 调整导航栏间距时需要屏蔽的VC（默认nil），支持Class或NSString，NSString支持部分匹配如前缀
@property (nonatomic, strong) NSArray *shiledItemSpaceVCs;

/// 导航栏左右间距，内部使用
@property (nonatomic, assign, readonly) CGFloat navItemLeftSpace;
@property (nonatomic, assign, readonly) CGFloat navItemRightSpace;

/// 单例，设置一次全局使用
+ (instancetype)sharedInstance;

/// 设置默认配置
- (void)setupDefaultConfigure;

/// 设置自定义配置，此方法只需调用一次
/// @param block 配置回调
- (void)setupCustomConfigure:(void (^)(GKNavigationBarConfigure *configure))block;

/// 更新配置
/// @param block 配置回调
- (void)updateConfigure:(void (^)(GKNavigationBarConfigure *configure))block;

/// 获取APP当前最顶层的可见viewController
- (UIViewController *)visibleViewController;

/// 获取当前APP是否是有缺口的屏幕（刘海屏）
- (BOOL)gk_isNotchedScreen;

/// 安全区域
- (UIEdgeInsets)gk_safeAreaInsets;

/// 状态栏frame
- (CGRect)gk_statusBarFrame;

#pragma mark - 内部方法

/// 获取当前item修复间距
- (CGFloat)gk_fixedSpace;

@end

NS_ASSUME_NONNULL_END
