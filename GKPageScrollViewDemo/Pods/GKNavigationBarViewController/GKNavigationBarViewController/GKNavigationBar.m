//
//  GKNavigationBar.m
//  GKNavigationBarViewControllerTest
//
//  Created by QuintGao on 2017/9/20.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKNavigationBar.h"
#import "GKCommon.h"
#import "GKNavigationBarConfigure.h"

@implementation GKNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 设置默认透明度
        self.gk_navBarBackgroundAlpha = 1.0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 这里为了适配iOS11，需要遍历所有的子控件，并向下移动状态栏的高度
    CGFloat systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
    
    if (systemVersion >= 11.0) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
                CGRect frame = obj.frame;
                frame.size.height = self.frame.size.height;
                obj.frame = frame;
            }else {
                CGFloat width = [UIScreen mainScreen].bounds.size.width;
                CGFloat height = [UIScreen mainScreen].bounds.size.height;
                
                CGFloat y = 0;
                
                if (width > height) {   // 横屏
                    if (GK_IS_iPhoneX) {
                        y = 0;
                    }else {
                        y = self.gk_statusBarHidden ? 0 : GK_STATUSBAR_HEIGHT;
                    }
                }else {
                    y = self.gk_statusBarHidden ? GK_SAVEAREA_TOP : GK_STATUSBAR_HEIGHT;
                }
        
                CGRect frame   = obj.frame;
                frame.origin.y = y;
                obj.frame      = frame;
            }
        }];
    }
    
    // 重新设置透明度，解决iOS11的bug
    self.gk_navBarBackgroundAlpha = self.gk_navBarBackgroundAlpha;
    
    // 显隐分割线
    [self gk_navLineHideOrShow];
    
    // 设置导航item偏移量
    if (GKDeviceVersion >= 11.0 && !GKConfigure.gk_disableFixSpace) {
        self.layoutMargins = UIEdgeInsetsZero;
        
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass(subview.class) containsString:@"ContentView"]) {
                // 修复iOS11 之后的偏移
                subview.layoutMargins = UIEdgeInsetsMake(0, self.gk_navItemLeftSpace, 0, self.gk_navItemRightSpace);
                break;
            }
        }
    }
}

- (void)gk_navLineHideOrShow {
    UIView *backgroundView = self.subviews.firstObject;
    
    for (UIView *view in backgroundView.subviews) {
        if (view.frame.size.height <= 1.0 && view.frame.size.height > 0) {
            view.hidden = self.gk_navLineHidden;
        }
    }
}

- (void)setGk_navBarBackgroundAlpha:(CGFloat)gk_navBarBackgroundAlpha {
    _gk_navBarBackgroundAlpha = gk_navBarBackgroundAlpha;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (GKDeviceVersion >= 10.0f && [obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                obj.alpha = gk_navBarBackgroundAlpha;
            });
        }else if ([obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                obj.alpha = gk_navBarBackgroundAlpha;
            });
        }
    }];
    
    self.clipsToBounds = gk_navBarBackgroundAlpha == 0.0;
}

@end
