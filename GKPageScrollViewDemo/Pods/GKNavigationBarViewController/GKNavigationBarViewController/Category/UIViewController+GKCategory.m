//
//  UIViewController+GKCategory.m
//  GKCustomNavigationBar
//
//  Created by QuintGao on 2017/7/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "UIViewController+GKCategory.h"
#import "GKNavigationBarViewController.h"
#import <objc/runtime.h>

NSString *const GKViewControllerPropertyChangedNotification = @"GKViewControllerPropertyChangedNotification";

static const void* GKInteractivePopKey  = @"GKInteractivePopKey";
static const void* GKFullScreenPopKey   = @"GKFullScreenPopKey";
static const void* GKPopMaxDistanceKey  = @"GKPopMaxDistanceKey";
static const void* GKNavBarAlphaKey     = @"GKNavBarAlphaKey";
static const void* GKStatusBarStyleKey  = @"GKStatusBarStyleKey";
static const void* GKStatusBarHiddenKey = @"GKStatusBarHiddenKey";
static const void* GKBackStyleKey       = @"GKBackStyleKey";
static const void* GKPushDelegateKey    = @"GKPushDelegateKey";
static const void* GKPopDelegateKey     = @"GKPopDelegateKey";

@implementation UIViewController (GKCategory)

// 方法交换
+ (void)load {
    // 保证其只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        gk_swizzled_method(class, @selector(viewDidAppear:) ,@selector(gk_viewDidAppear:));
    });
}

- (void)gk_viewDidAppear:(BOOL)animated {
    
    // 在每次视图出现的时候重新设置当前控制器的手势
    [[NSNotificationCenter defaultCenter] postNotificationName:GKViewControllerPropertyChangedNotification object:@{@"viewController": self}];
    
    [self gk_viewDidAppear:animated];
}

#pragma mark - StatusBar
- (BOOL)prefersStatusBarHidden {
    return self.gk_statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.gk_statusBarStyle;
}

#pragma mark - Added Property
- (BOOL)gk_interactivePopDisabled {
    return [objc_getAssociatedObject(self, GKInteractivePopKey) boolValue];
}

- (void)setGk_interactivePopDisabled:(BOOL)gk_interactivePopDisabled {
    objc_setAssociatedObject(self, GKInteractivePopKey, @(gk_interactivePopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 当属性改变时，发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:GKViewControllerPropertyChangedNotification object:@{@"viewController": self}];
}

- (BOOL)gk_fullScreenPopDisabled {
    return [objc_getAssociatedObject(self, GKFullScreenPopKey) boolValue];
}

- (void)setGk_fullScreenPopDisabled:(BOOL)gk_fullScreenPopDisabled {
    objc_setAssociatedObject(self, GKFullScreenPopKey, @(gk_fullScreenPopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 当属性改变时，发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:GKViewControllerPropertyChangedNotification object:@{@"viewController": self}];
}

- (CGFloat)gk_popMaxAllowedDistanceToLeftEdge {
    return [objc_getAssociatedObject(self, GKPopMaxDistanceKey) floatValue];
}

- (void)setGk_popMaxAllowedDistanceToLeftEdge:(CGFloat)gk_popMaxAllowedDistanceToLeftEdge {
    objc_setAssociatedObject(self, GKPopMaxDistanceKey, @(gk_popMaxAllowedDistanceToLeftEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 当属性改变时，发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:GKViewControllerPropertyChangedNotification object:@{@"viewController": self}];
}

- (CGFloat)gk_navBarAlpha {
    return [objc_getAssociatedObject(self, GKNavBarAlphaKey) floatValue];
}

- (void)setGk_navBarAlpha:(CGFloat)gk_navBarAlpha {
    objc_setAssociatedObject(self, GKNavBarAlphaKey, @(gk_navBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNavBarAlpha:gk_navBarAlpha];
}

- (UIStatusBarStyle)gk_statusBarStyle {
    id style = objc_getAssociatedObject(self, GKStatusBarStyleKey);
    return (style != nil) ? [style integerValue] : UIStatusBarStyleDefault;
}

- (void)setGk_statusBarStyle:(UIStatusBarStyle)gk_statusBarStyle {
    objc_setAssociatedObject(self, GKStatusBarStyleKey, @(gk_statusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // 调用隐藏方法
        [self prefersStatusBarHidden];
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (BOOL)gk_statusBarHidden {
    return [objc_getAssociatedObject(self, GKStatusBarHiddenKey) boolValue];
}

- (void)setGk_statusBarHidden:(BOOL)gk_statusBarHidden {
    objc_setAssociatedObject(self, GKStatusBarHiddenKey, @(gk_statusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // 调用隐藏方法
        [self prefersStatusBarHidden];
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (GKNavigationBarBackStyle)gk_backStyle {
    id style = objc_getAssociatedObject(self, GKBackStyleKey);
    
    return (style != nil) ? [style integerValue] : GKNavigationBarBackStyleBlack;
}

- (void)setGk_backStyle:(GKNavigationBarBackStyle)gk_backStyle {
    objc_setAssociatedObject(self, GKBackStyleKey, @(gk_backStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.navigationController.childViewControllers.count <= 1) return;
    
    if (self.gk_backStyle != GKNavigationBarBackStyleNone) {
        UIImage *backImage = self.gk_backStyle == GKNavigationBarBackStyleBlack ? GKImage(@"btn_back_black") : GKImage(@"btn_back_white");
        
        if ([self isKindOfClass:[GKNavigationBarViewController class]]) {
            GKNavigationBarViewController *vc = (GKNavigationBarViewController *)self;
            vc.gk_navLeftBarButtonItem = [UIBarButtonItem itemWithTitle:nil image:backImage target:self action:@selector(backItemClick:)];
        }
    }
}

- (id<GKViewControllerPushDelegate>)gk_pushDelegate {
    return objc_getAssociatedObject(self, GKPushDelegateKey);
}

- (void)setGk_pushDelegate:(id<GKViewControllerPushDelegate>)gk_pushDelegate {
    objc_setAssociatedObject(self, GKPushDelegateKey, gk_pushDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<GKViewControllerPopDelegate>)gk_popDelegate {
    return objc_getAssociatedObject(self, GKPopDelegateKey);
}

- (void)setGk_popDelegate:(id<GKViewControllerPopDelegate>)gk_popDelegate {
    objc_setAssociatedObject(self, GKPopDelegateKey, gk_popDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 当属性改变时，发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:GKViewControllerPropertyChangedNotification object:@{@"viewController": self}];
}

- (void)setNavBarAlpha:(CGFloat)alpha {
    
    UINavigationBar *navBar = nil;
    
    if ([self isKindOfClass:[GKNavigationBarViewController class]]) {
        GKNavigationBarViewController *vc = (GKNavigationBarViewController *)self;
        
        vc.gk_navigationBar.gk_navBarBackgroundAlpha = alpha;
    }else {
        navBar = self.navigationController.navigationBar;
        
        UIView *barBackgroundView = [navBar.subviews objectAtIndex:0]; // _UIBarBackground
        UIImageView *backgroundImageView = [barBackgroundView.subviews objectAtIndex:0]; // UIImageView
        
        if (navBar.isTranslucent) {
            if (backgroundImageView != nil && backgroundImageView.image != nil) {
                barBackgroundView.alpha = alpha;
            }else {
                UIView *backgroundEffectView = [barBackgroundView.subviews objectAtIndex:1]; // UIVisualEffectView
                if (backgroundEffectView != nil) {
                    backgroundEffectView.alpha = alpha;
                }
            }
        }else {
            barBackgroundView.alpha = alpha;
        }
    }
    // 底部分割线
    navBar.clipsToBounds = alpha == 0.0;
}

- (UIViewController *)gk_visibleViewControllerIfExist {
    
    if (self.presentedViewController) {
        return [self.presentedViewController gk_visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).topViewController gk_visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController gk_visibleViewControllerIfExist];
    }
    
    if ([self isViewLoaded] && self.view.window) {
        return self;
    }else {
        NSLog(@"找不到可见的控制器，viewcontroller.self = %@, self.view.window = %@", self, self.view.window);
        return nil;
    }
}

- (void)backItemClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
