//
//  GKGestureHandleDefine.h
//  GKNavigationBar
//
//  Created by QuintGao on 2020/10/29.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#ifndef GKGestureHandleDefine_h
#define GKGestureHandleDefine_h

#import <objc/runtime.h>
#import "GKGestureHandleConfigure.h"

#define GKGestureConfigure [GKGestureHandleConfigure sharedInstance]

/// iOS runtime交换方法
/// @param prefix 交换方法的前缀
/// @param oldClass 原始类
/// @param oldSelector 原始方法
/// @param newClass 新类
static inline void gk_gestureHandle_swizzled_instanceMethod(NSString *prefix, Class oldClass, NSString *oldSelector, Class newClass) {
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

#endif /* GKGestureHandleDefine_h */
