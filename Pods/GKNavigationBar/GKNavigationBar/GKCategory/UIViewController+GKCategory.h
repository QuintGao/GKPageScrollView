//
//  UIViewController+GKCategory.h
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKCustomNavigationBar.h"
#import "GKNavigationBarConfigure.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const GKViewControllerPropertyChangedNotification;

// 左滑push代理
@protocol GKViewControllerPushDelegate <NSObject>

- (void)pushToNextViewController;

@end

// 右滑pop代理
@protocol GKViewControllerPopDelegate <NSObject>

@optional
- (void)viewControllerPopScrollBegan;
- (void)viewControllerPopScrollUpdate:(float)progress;
- (void)viewControllerPopScrollEnded;

@end

@interface UIViewController (GKCategory)

/// 是否禁止当前控制器的滑动返回（包括全屏滑动返回和边缘滑动返回）
@property (nonatomic, assign) BOOL gk_interactivePopDisabled;

/// 是否禁止当前控制器的全屏滑动返回
@property (nonatomic, assign) BOOL gk_fullScreenPopDisabled;

/// 全屏滑动时，滑动区域距离屏幕左侧的最大位置，默认是0：表示全屏可滑动
@property (nonatomic, assign) CGFloat gk_maxPopDistance;

/// 设置状态栏是否隐藏，默认NO：不隐藏
@property (nonatomic, assign) BOOL gk_statusBarHidden;

/// 设置状态栏类型
@property (nonatomic, assign) UIStatusBarStyle gk_statusBarStyle;

/// 左滑push代理
@property (nonatomic, weak) id<GKViewControllerPushDelegate> gk_pushDelegate;

/// 右滑pop代理，如果设置了gk_popDelegate，原来的滑动返回手势将失效
@property (nonatomic, weak) id<GKViewControllerPopDelegate> gk_popDelegate;

@end

@interface UIViewController (GKNavigationBar)

@property (nonatomic, strong) GKCustomNavigationBar *gk_navigationBar;

@property (nonatomic, strong) UINavigationItem      *gk_navigationItem;

/// 是否创建了gk_navigationBar
/// 返回YES表明当前控制器使用了自定义的gk_navigationBar，默认为NO
@property (nonatomic, assign) BOOL                  gk_NavBarInit;

#pragma mark - 常用属性快速设置
/// 设置导航栏透明度
@property (nonatomic, assign) CGFloat               gk_navBarAlpha;

/// 设置返回按钮图片（优先级高于gk_backStyle）
@property (nonatomic, strong) UIImage *gk_backImage;

/// 设置返回按钮类型
@property (nonatomic, assign) GKNavigationBarBackStyle gk_backStyle;

/// 导航栏背景
@property (nonatomic, strong) UIColor               *gk_navBackgroundColor;
@property (nonatomic, strong) UIImage               *gk_navBackgroundImage;

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

@end

NS_ASSUME_NONNULL_END
