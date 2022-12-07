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

/// 导航栏背景色，默认nil，优先级高于backgroundColor
@property (nonatomic, strong) UIImage   *backgroundImage;

/// 暗黑模式下的背景图，优先级高于backgroundColor
@property (nonatomic, strong) UIImage   *darkBackgroundImage;

/// 导航栏分割线背景色，默认nil，使用系统颜色
@property (nonatomic, strong) UIColor   *lineColor;

/// 导航栏分割线图片，默认nil，优先级高于lineColor
@property (nonatomic, strong) UIImage   *lineImage;

/// 暗黑模式下的分割线图片，优先级高于lineColor
@property (nonatomic, strong) UIImage   *darkLineImage;

/// 导航栏分割线是否隐藏，默认NO
@property (nonatomic, assign) BOOL      lineHidden;

/// 导航栏标题颜色，默认黑色
@property (nonatomic, strong) UIColor   *titleColor;

/// 导航栏标题字体，默认系统字体17
@property (nonatomic, strong) UIFont    *titleFont;

/// 返回按钮图片(默认nil，优先级高于backStyle)
@property (nonatomic, strong) UIImage   *backImage;

/// 暗黑模式下的返回图片，优先级高于backStyle
@property (nonatomic, strong) UIImage   *darkBackImage;

/// backStyle为GKNavigationBarBackStyleBlack时对应的图片，默认btn_back_black
@property (nonatomic, strong) UIImage   *blackBackImage;

/// backStyle为GKNavigationBarBackStyleWhite时对应的图片，默认btn_back_white
@property (nonatomic, strong) UIImage   *whiteBackImage;

/// 返回按钮样式，默认GKNavigationBarBackStyleBlack
@property (nonatomic, assign) GKNavigationBarBackStyle backStyle;

/// 是否禁止导航栏左右item间距调整，默认是NO
/// 1.7.0版本之后 只对带有GKCustomNavigationBar的控制器有效
@property (nonatomic, assign) BOOL      gk_disableFixSpace;

/// 开启普通控制器的导航栏item间距调整，只能在对应的控制器中开启
@property (nonatomic, assign) BOOL      openSystemFixSpace;

/// 导航栏左侧按钮距屏幕左边间距，默认是0，可自行调整
@property (nonatomic, assign) CGFloat   gk_navItemLeftSpace;

/// 导航栏右侧按钮距屏幕右边间距，默认是0，可自行调整
@property (nonatomic, assign) CGFloat   gk_navItemRightSpace;

/// 是否隐藏状态栏，默认NO
@property (nonatomic, assign) BOOL      statusBarHidden;

/// 状态栏类型，默认UIStatusBarStyleDefault
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/// 导航栏左右间距，内部使用
@property (nonatomic, assign, readonly) BOOL    disableFixSpace;
@property (nonatomic, assign, readonly) CGFloat navItemLeftSpace;
@property (nonatomic, assign, readonly) CGFloat navItemRightSpace;

/// 用于恢复系统导航栏的显示，默认NO
@property (nonatomic, assign) BOOL gk_restoreSystemNavBar;

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

#pragma mark - 内部方法

/// 获取当前item修复间距
- (CGFloat)gk_fixedSpace;

/// 获取bundle
- (NSBundle *)gk_libraryBundle;

/// 是否禁止调整导航栏item间距
- (BOOL)fixNavItemSpaceDisabled;

@end

// from QMUI
@interface GKNavigationBarConfigure (UIDevice)

@property (class, nonatomic, readonly) BOOL isIPad;
@property (class, nonatomic, readonly) BOOL isIPod;
@property (class, nonatomic, readonly) BOOL isIPhone;
@property (class, nonatomic, readonly) BOOL isSimulator;
@property (class, nonatomic, readonly) BOOL isMac;

// 带物理凹槽的刘海屏或者使用 Home Indicator 类型的设备
@property (class, nonatomic, readonly) BOOL isNotchedScreen;

// 将屏幕分为普通和紧凑两种，这个方法用于判断普通屏幕（也即大屏幕）
@property (class, nonatomic, readonly) BOOL isRegularScreen;

/// iPhone 14 Pro Max
@property (class, nonatomic, readonly) BOOL is67InchScreenAndiPhone14ProMax;

/// iPhone 12,13 Pro Max / iPhone 14 Plus
@property (class, nonatomic, readonly) BOOL is67InchScreen;

/// iPhone XS Max / 11 Pro Max
@property (class, nonatomic, readonly) BOOL is65InchScreen;

/// iPhone 14 Pro
@property (class, nonatomic, readonly) BOOL is61InchScreenAndiPhone14Pro;

/// iPhone 12,13 / 12,13 Pro
@property (class, nonatomic, readonly) BOOL is61InchScreenAndiPhone12Later;

/// iPhone XR / 11
@property (class, nonatomic, readonly) BOOL is61InchScreen;

/// iPhone X / XS / 11Pro
@property (class, nonatomic, readonly) BOOL is58InchScreen;

/// iPhone 6，6s，7，8 Plus
@property (class, nonatomic, readonly) BOOL is55InchScreen;

/// iPhone 12 mini
@property (class, nonatomic, readonly) BOOL is54InchScreen;

/// iPhone 6，6s，7，8，SE2
@property (class, nonatomic, readonly) BOOL is47InchScreen;

/// iPhone 5，5s，5c，SE
@property (class, nonatomic, readonly) BOOL is40InchScreen;

/// iPhone 4
@property (class, nonatomic, readonly) BOOL is35InchScreen;

@property (class, nonatomic, readonly) CGSize screenSizeFor67InchAndiPhone14ProMax;
@property (class, nonatomic, readonly) CGSize screenSizeFor67Inch;
@property (class, nonatomic, readonly) CGSize screenSizeFor65Inch;
@property (class, nonatomic, readonly) CGSize screenSizeFor61InchAndiPhone14Pro;
@property (class, nonatomic, readonly) CGSize screenSizeFor61InchAndiPhone12Later;
@property (class, nonatomic, readonly) CGSize screenSizeFor61Inch;
@property (class, nonatomic, readonly) CGSize screenSizeFor58Inch;
@property (class, nonatomic, readonly) CGSize screenSizeFor55Inch;
@property (class, nonatomic, readonly) CGSize screenSizeFor54Inch;
@property (class, nonatomic, readonly) CGSize screenSizeFor47Inch;
@property (class, nonatomic, readonly) CGSize screenSizeFor40Inch;
@property (class, nonatomic, readonly) CGSize screenSizeFor35Inch;

// 导航栏高度，包括竖屏，横屏，放大模式，非全屏模式
// 机型\高度         尺寸        竖屏       横屏      放大模式    非全屏模式
// 5,5s,5c,SE       4.0        44        32         不支持       56
// 6,6s,7,8,SE2     4.7        44        32          32         56
// 6,6s,7,8plus     5.5        44        44          32         56
// X,XS,11Pro       5.8        44        32          32         56
// XR,11            6.1        44        44          32         56
// XS MAX,11Pro Max 6.5        44        44          32         56
// 12mini           5.4        44        32          32         56
// 12,12Pro         6.1        44        32          32         56
// 12,13 Pro Max    6.7        44        44          32         56
// 14 Pro Max       6.7        44        44          32         56
// iPad iOS12之前是44，之后是50                                    56
@property (class, nonatomic, readonly) CGFloat      navBarHeight;
@property (class, nonatomic, readonly) CGFloat      navBarHeight_nonFullScreen;
@property (class, nonatomic, readonly) CGFloat      tabBarHeight;
@property (class, nonatomic, readonly) UIEdgeInsets safeAreaInsets;
@property (class, nonatomic, readonly) CGRect       statusBarFrame;
@property (class, nonatomic, readonly) UIWindow     *keyWindow;

/// 用于获取 isNotchedScreen 设备的 insets，注意对于无 Home 键的新款 iPad 而言，它不一定有物理凹槽，但因为使用了 Home Indicator，所以它的 safeAreaInsets 也是非0。
+ (UIEdgeInsets)safeAreaInsetsForDeviceWithNotch;

@end

NS_ASSUME_NONNULL_END
