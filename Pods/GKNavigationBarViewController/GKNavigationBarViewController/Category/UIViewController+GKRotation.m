//
//  UIViewController+GKRotation.m
//  GKNavigationBarViewControllerTest
//
//  Created by QuintGao on 2017/10/15.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "UIViewController+GKRotation.h"

@implementation UIViewController (GKRotation)

@end

@implementation UINavigationController (GKRotation)

#pragma mark - 控制屏幕旋转的方法
- (BOOL)shouldAutorotate {
    return self.visibleViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.visibleViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.visibleViewController.preferredInterfaceOrientationForPresentation;
}

@end

@implementation UITabBarController (GKRotation)

#pragma mark - 控制屏幕旋转
- (BOOL)shouldAutorotate {
    UIViewController *vc = self.selectedViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc shouldAutorotate];
    }
    return vc.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *vc = self.selectedViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc supportedInterfaceOrientations];
    }
    return vc.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = self.selectedViewController;
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)vc preferredInterfaceOrientationForPresentation];
    }
    return vc.preferredInterfaceOrientationForPresentation;
}

@end
