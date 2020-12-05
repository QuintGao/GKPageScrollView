//
//  GKPageDefine.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2020/10/22.
//  Copyright © 2020 gaokun. All rights reserved.
//

#import "GKPageDefine.h"

@implementation GKPageDefine

+ (BOOL)gk_isNotchedScreen {
    if (@available(iOS 11.0, *)) {
        UIWindow *keyWindow = [GKPageDefine getKeyWindow];
        if (keyWindow) {
            return keyWindow.safeAreaInsets.bottom > 0;
        }
    }
    
    // 当iOS11以下或获取不到keyWindow时用以下方案
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    return (CGSizeEqualToSize(screenSize, CGSizeMake(375, 812)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(812, 375)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(414, 896)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(896, 414)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(390, 844)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(844, 390)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(428, 926)) ||
            CGSizeEqualToSize(screenSize, CGSizeMake(926, 428)));
}

+ (UIWindow *)getKeyWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in windowScene.windows) {
                    if (window.isKeyWindow) {
                        window = w;
                        break;
                    }
                }
            }
        }
    }
    
    if (!window) {
        window = [UIApplication sharedApplication].windows.firstObject;
        if (!window.isKeyWindow) {
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            if (CGRectEqualToRect(keyWindow.bounds, UIScreen.mainScreen.bounds)) {
                window = keyWindow;
            }
        }
    }
    
    return window;
}

@end
