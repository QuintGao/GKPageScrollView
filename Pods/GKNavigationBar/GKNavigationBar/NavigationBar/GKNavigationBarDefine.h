//
//  GKNavigationBarDefine.h
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#ifndef GKNavigationBarDefine_h
#define GKNavigationBarDefine_h

#import <objc/runtime.h>
#import "GKNavigationBarConfigure.h"

// 配置类宏定义
#define GKConfigure                 [GKNavigationBarConfigure sharedInstance]

// 屏幕相关
#define GK_SCREEN_WIDTH             [UIScreen mainScreen].bounds.size.width
#define GK_SCREEN_HEIGHT            [UIScreen mainScreen].bounds.size.height

// 判断是否是刘海屏
#define GK_NOTCHED_SCREEN           [GKConfigure gk_isNotchedScreen]

// 判断是否是iPad
#define GK_IS_iPad                  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

// 顶部安全区域高度
#define GK_SAFEAREA_TOP             [GKConfigure gk_safeAreaInsets].top
// 底部安全区域高度
#define GK_SAFEAREA_BTM             [GKConfigure gk_safeAreaInsets].bottom
// 状态栏高度
#define GK_STATUSBAR_HEIGHT         [GKConfigure gk_statusBarFrame].size.height
// 导航栏高度
#define GK_NAVBAR_HEIGHT            44.0f
// 状态栏+导航栏高度
#define GK_STATUSBAR_NAVBAR_HEIGHT  (GK_STATUSBAR_HEIGHT + GK_NAVBAR_HEIGHT)
// tabbar高度
#define GK_TABBAR_HEIGHT            (GK_SAFEAREA_BTM + 49.0f)

// 导航栏间距，用于不同控制器之间的间距
static const CGFloat GKNavigationBarItemSpace = -1;

/// iOS runtime交换方法
/// @param prefix 交换方法的前缀
/// @param oldClass 原始类
/// @param oldSelector 原始方法
/// @param newClass 新类
static inline void gk_navigationBar_swizzled_instanceMethod(NSString *prefix, Class oldClass, NSString *oldSelector, Class newClass) {
    NSString *newSelector = [NSString stringWithFormat:@"%@_%@", prefix, oldSelector];
    
    SEL originalSelector = NSSelectorFromString(oldSelector);
    SEL swizzledSelector = NSSelectorFromString(newSelector);
    
    Method originalMethod = class_getInstanceMethod(oldClass, NSSelectorFromString(oldSelector));
    Method swizzledMethod = class_getInstanceMethod(newClass, NSSelectorFromString(newSelector));
    
    BOOL isAdd = class_addMethod(oldClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (isAdd) {
        class_replaceMethod(newClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#endif /* GKNavigationBarDefine_h */
