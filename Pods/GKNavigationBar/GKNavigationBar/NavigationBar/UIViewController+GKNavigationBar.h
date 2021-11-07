//
//  UIViewController+GKNavigationBar.h
//  GKNavigationBarExample
//
//  Created by gaokun on 2020/10/29.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKCustomNavigationBar.h"

// 返回按钮样式
typedef NS_ENUM(NSUInteger, GKNavigationBarBackStyle) {
    GKNavigationBarBackStyleNone,   // 无返回按钮
    GKNavigationBarBackStyleBlack,  // 黑色返回按钮
    GKNavigationBarBackStyleWhite   // 白色返回按钮
};

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (GKNavigationBar)

/// 自定义导航栏
@property (nonatomic, strong, readonly) GKCustomNavigationBar *gk_navigationBar;

/// 导航栏item
@property (nonatomic, strong, readonly) UINavigationItem      *gk_navigationItem;

/// 是否创建了gk_navigationBar
/// 返回YES表明当前控制器使用了自定义的gk_navigationBar，默认为NO
@property (nonatomic, assign, readonly) BOOL        gk_NavBarInit;

/// 设置状态栏是否隐藏，默认NO：不隐藏
@property (nonatomic, assign) BOOL                  gk_statusBarHidden;

/// 设置状态栏类型
@property (nonatomic, assign) UIStatusBarStyle      gk_statusBarStyle;

#pragma mark - 常用属性快速设置
/// 设置导航栏透明度
@property (nonatomic, assign) CGFloat               gk_navBarAlpha;

/// 设置返回按钮图片（优先级高于gk_backStyle）
@property (nonatomic, strong) UIImage               *gk_backImage;

/// gk_backStyle为GKNavigationBarBackStyleBlack时的图片
@property (nonatomic, strong) UIImage               *gk_blackBackImage;

/// gk_backStyle为GKNavigationBarBackStyleWhite时的图片
@property (nonatomic, strong) UIImage               *gk_whiteBackImage;

/// 设置返回按钮类型
@property (nonatomic, assign) GKNavigationBarBackStyle gk_backStyle;

/// 导航栏背景，gk_navBackgroundImage优先级较高
@property (nonatomic, strong) UIImage               *gk_navBackgroundImage;
@property (nonatomic, strong) UIColor               *gk_navBackgroundColor;

/// 导航栏分割线
@property (nonatomic, strong) UIColor               *gk_navShadowColor;
@property (nonatomic, strong) UIImage               *gk_navShadowImage;
@property (nonatomic, assign) BOOL                  gk_navLineHidden;

/// 导航栏标题
@property (nullable, nonatomic, strong) NSString    *gk_navTitle;
@property (nullable, nonatomic, strong) UIView      *gk_navTitleView;
@property (nonatomic, strong) UIColor               *gk_navTitleColor;
@property (nonatomic, strong) UIFont                *gk_navTitleFont;

/// 导航栏左右item
@property (nullable, nonatomic, strong) UIBarButtonItem       *gk_navLeftBarButtonItem;
@property (nullable, nonatomic, strong) NSArray<UIBarButtonItem *> *gk_navLeftBarButtonItems;
@property (nullable, nonatomic, strong) UIBarButtonItem       *gk_navRightBarButtonItem;
@property (nullable, nonatomic, strong) NSArray<UIBarButtonItem *> *gk_navRightBarButtonItems;

/// 是否禁止调整当前控制器导航栏间距，默认GKConfigure.gk_disableFixSpace
@property (nonatomic, assign) BOOL                  gk_disableFixNavItemSpace;

/// 导航栏左右按钮距离屏幕边缘的距离，需在设置左右item之前设置此属性
@property (nonatomic, assign) CGFloat               gk_navItemLeftSpace;
@property (nonatomic, assign) CGFloat               gk_navItemRightSpace;

/// 显示导航栏分割线
- (void)showNavLine;

/// 隐藏导航栏分割线
- (void)hideNavLine;

/// 刷新导航栏frame
- (void)refreshNavBarFrame;

/// 返回按钮点击方法
/// @param sender sender
- (void)backItemClick:(id)sender;

/// 查找当前显示的控制器
/// @param isRoot 是否是根控制器
- (UIViewController *)gk_findCurrentViewControllerIsRoot:(BOOL)isRoot;

@end

NS_ASSUME_NONNULL_END
