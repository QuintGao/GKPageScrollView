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

// 屏幕相关
#define GK_SCREEN_WIDTH         [UIScreen mainScreen].bounds.size.width
#define GK_SCREEN_HEIGHT        [UIScreen mainScreen].bounds.size.height

// 判断是否是刘海屏
#define GK_NOTCHED_SCREEN      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?\
(\
CGSizeEqualToSize(CGSizeMake(375, 812),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(812, 375),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(414, 896),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(896, 414),[UIScreen mainScreen].bounds.size))\
:\
NO)

// 判断是否是iPad
#define GK_IS_iPad                  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

// 顶部安全区域高度
#define GK_SAFEAREA_TOP             (GK_NOTCHED_SCREEN ? 24.0f : 0.0f)
// 底部安全区域高度
#define GK_SAFEAREA_BTM             (GK_NOTCHED_SCREEN ? 34.0f : 0.0f)
// 状态栏高度
#define GK_STATUSBAR_HEIGHT         (GK_NOTCHED_SCREEN ? 44.0f : 20.0f)
// 导航栏高度
#define GK_NAVBAR_HEIGHT            44.0f
// 状态栏+导航栏高度
#define GK_STATUSBAR_NAVBAR_HEIGHT  (GK_STATUSBAR_HEIGHT + GK_NAVBAR_HEIGHT)
// tabbar高度
#define GK_TABBAR_HEIGHT            (GK_NOTCHED_SCREEN ? 83.0f : 49.0f)

// 导航栏间距，用于不同控制器之间的间距
static const CGFloat GKNavigationBarItemSpace = -1;

// 返回按钮样式
typedef NS_ENUM(NSUInteger, GKNavigationBarBackStyle) {
    GKNavigationBarBackStyleNone,   // 无返回按钮
    GKNavigationBarBackStyleBlack,  // 黑色返回按钮
    GKNavigationBarBackStyleWhite   // 白色返回按钮
};

/// iOS runtime交换方法
/// @param prefix 交换方法的前缀
/// @param oldClass 原始类
/// @param oldSelector 原始方法
/// @param newClass 新类
static inline void gk_swizzled_instanceMethod(NSString *prefix, Class oldClass, NSString *oldSelector, Class newClass) {
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
