//
//  GKNavigationBarConfigure.h
//  GKNavigationBarViewControllerDemo
//
//  Created by QuintGao on 2017/7/10.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKCommon.h"

@interface GKNavigationBarConfigure : NSObject

/** 导航栏背景色 */
@property (nonatomic, strong) UIColor *backgroundColor;

/** 导航栏标题颜色 */
@property (nonatomic, strong) UIColor *titleColor;

/** 导航栏标题字体 */
@property (nonatomic, strong) UIFont *titleFont;

/** 状态栏是否隐藏 */
@property (nonatomic, assign) BOOL statusBarHidden;

/** 状态栏类型 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/** 返回按钮类型(此方法只可全局配置，在控制器中修改无效) */
@property (nonatomic, assign) GKNavigationBarBackStyle backStyle;

/** 导航栏左右按钮距屏幕左右的间距，默认是0，可自行调整 */
@property (nonatomic, assign) CGFloat   gk_navItemLeftSpace;

@property (nonatomic, assign) CGFloat   gk_navItemRightSpace;

/** 是否禁止调整间距，默认NO */
@property (nonatomic, assign) BOOL      gk_disableFixSpace;

+ (instancetype)sharedInstance;

// 统一配置导航栏外观，最好在AppDelegate中配置
- (void)setupDefaultConfigure;

// 自定义
- (void)setupCustomConfigure:(void (^)(GKNavigationBarConfigure *configure))block;

// 更新配置
- (void)updateConfigure:(void (^)(GKNavigationBarConfigure *configure))block;

// 获取当前显示的控制器
- (UIViewController *)visibleController;

@end
