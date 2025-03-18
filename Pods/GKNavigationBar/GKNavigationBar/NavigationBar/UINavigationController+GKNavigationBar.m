//
//  UINavigationController+GKNavigationBar.m
//  GKNavigationBar
//
//  Created by QuintGao on 2020/11/23.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "UINavigationController+GKNavigationBar.h"
#import "GKNavigationBarDefine.h"

@implementation UINavigationController (GKNavigationBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray <NSString *> *oriSels = @[@"pushViewController:animated:"];
        
        [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
            gk_navigationBar_swizzled_instanceMethod(@"gkNav", self, oriSel, self);
        }];
    });
}

- (void)gkNav_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.gk_openSystemNavHandle) {
        self.navigationBarHidden = YES;
    }
    [self gkNav_pushViewController:viewController animated:animated];
}

static char kAssociatedObjectKey_openSystemNavHandle;
- (void)setGk_openSystemNavHandle:(BOOL)gk_openSystemNavHandle {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_openSystemNavHandle, @(gk_openSystemNavHandle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_openSystemNavHandle {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_openSystemNavHandle) boolValue];
}

static char kAssociatedObjectKey_hideNavigationBar;
- (void)setGk_hideNavigationBar:(BOOL)gk_hideNavigationBar {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_hideNavigationBar, @(gk_hideNavigationBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_hideNavigationBar {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_hideNavigationBar) boolValue];
}

@end
