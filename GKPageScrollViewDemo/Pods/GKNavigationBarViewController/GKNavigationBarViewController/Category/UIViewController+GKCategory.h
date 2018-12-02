//
//  UIViewController+GKCategory.h
//  GKCustomNavigationBar
//
//  Created by QuintGao on 2017/7/7.
//  Copyright © 2017年 高坤. All rights reserved.
//  使用运行时为UIViewController添加分类

#import <UIKit/UIKit.h>
#import "GKNavigationBarConfigure.h"

extern NSString *const GKViewControllerPropertyChangedNotification;

// 交给单独控制器处理
@protocol GKViewControllerPushDelegate <NSObject>

@optional
- (void)pushToNextViewController;

@end

@interface UIViewController (GKCategory)

/** 是否禁止当前控制器的滑动返回(包括全屏返回和边缘返回) */
@property (nonatomic, assign) BOOL gk_interactivePopDisabled;

/** 是否禁止当前控制器的全屏滑动返回 */
@property (nonatomic, assign) BOOL gk_fullScreenPopDisabled;

/** 全屏滑动时，滑动区域距离屏幕左边的最大位置，默认是0：表示全屏都可滑动 */
@property (nonatomic, assign) CGFloat gk_popMaxAllowedDistanceToLeftEdge;

/** 设置导航栏的透明度 */
@property (nonatomic, assign) CGFloat gk_navBarAlpha;

/** 设置状态栏类型 */
@property (nonatomic, assign) UIStatusBarStyle gk_statusBarStyle;

/** 设置状态栏是否显示(default is NO 即不隐藏) */
@property (nonatomic, assign) BOOL gk_statusBarHidden;

/** 设置返回按钮的类型 */
@property (nonatomic, assign) GKNavigationBarBackStyle gk_backStyle;

/** push代理 */
@property (nonatomic, weak) id<GKViewControllerPushDelegate> gk_pushDelegate;

/**
 返回显示的控制器
 */
- (UIViewController *)gk_visibleViewControllerIfExist;

/**
 返回按钮点击
 */
- (void)backItemClick:(id)sender;

@end
