//
//  GKCustomNavigationBar.m
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKCustomNavigationBar.h"
#import "GKNavigationBarDefine.h"

@implementation GKCustomNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.gk_navBarBackgroundAlpha = 1.0f;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 适配iOS11，遍历所有子控件，向下移动状态栏高度
    if (@available(iOS 11.0, *)) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
                CGRect frame = obj.frame;
                frame.size.height = self.frame.size.height;
                obj.frame = frame;
            }else {
                CGRect frame = obj.frame;
                frame.origin.y = self.frame.size.height - (self.gk_nonFullScreen ? GK_NAVBAR_HEIGHT_NFS : GK_NAVBAR_HEIGHT);
                obj.frame = frame;
            }
        }];
    }
    
    // 重新设置透明度
    self.gk_navBarBackgroundAlpha = self.gk_navBarBackgroundAlpha;
    
    // 分割线
    [self gk_navLineHideOrShow];
}

- (void)gk_navLineHideOrShow {
    UIView *backgroundView = self.subviews.firstObject;
    
    for (UIView *view in backgroundView.subviews) {
        if (view.frame.size.height > 0 && view.frame.size.height <= 1.0f) {
            view.hidden = self.gk_navLineHidden;
        }
    }
}

- (void)setGk_navBarBackgroundAlpha:(CGFloat)gk_navBarBackgroundAlpha {
    _gk_navBarBackgroundAlpha = gk_navBarBackgroundAlpha;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (@available(iOS 10.0, *)) {
            if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (obj.alpha != gk_navBarBackgroundAlpha) {
                        obj.alpha = gk_navBarBackgroundAlpha;
                    }
                });
            }
        }else if ([obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (obj.alpha != gk_navBarBackgroundAlpha) {
                    obj.alpha = gk_navBarBackgroundAlpha;
                }
            });
        }
    }];
    
    BOOL isClipsToBounds = (gk_navBarBackgroundAlpha == 0.0f);
    if (self.clipsToBounds != isClipsToBounds) {
        self.clipsToBounds = isClipsToBounds;
    }
}

@end
