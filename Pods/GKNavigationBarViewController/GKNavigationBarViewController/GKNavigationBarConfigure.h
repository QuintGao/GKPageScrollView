//
//  GKNavigationBarConfigure.h
//  GKNavigationBarViewController
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
@property (nonatomic, assign, readonly) BOOL gk_lastDisableFixSpace;

/** 左滑push过渡临界值，默认0.3，大于此值完成push操作 */
@property (nonatomic, assign) CGFloat   gk_pushTransitionCriticalValue;

/** 右滑pop过渡临界值，默认0.5，大于此值完成pop操作 */
@property (nonatomic, assign) CGFloat   gk_popTransitionCriticalValue;

// 以下属性需要设置导航栏转场缩放为YES
// 手机系统大于等于11.0，使用下面的值控制x、y轴的位移距离，默认（5，5）
@property (nonatomic, assign) CGFloat   gk_translationX;
@property (nonatomic, assign) CGFloat   gk_translationY;

// 手机系统小于11.0，使用下面的值控制x、y轴的缩放程度，默认（0.95，0.97）
@property (nonatomic, assign) CGFloat   gk_scaleX;
@property (nonatomic, assign) CGFloat   gk_scaleY;

+ (instancetype)sharedInstance;

// 统一配置导航栏外观，最好在AppDelegate中配置
- (void)setupDefaultConfigure;

// 自定义
- (void)setupCustomConfigure:(void (^)(GKNavigationBarConfigure *configure))block;

// 更新配置
- (void)updateConfigure:(void (^)(GKNavigationBarConfigure *configure))block;

// 获取当前显示的控制器
- (UIViewController *)visibleController;

// 间距调整
- (CGFloat)gk_fixedSpace;

@end
