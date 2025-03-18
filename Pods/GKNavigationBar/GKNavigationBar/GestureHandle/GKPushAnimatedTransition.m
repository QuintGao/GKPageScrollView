//
//  GKPushAnimatedTransition.m
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKPushAnimatedTransition.h"
#import "GKGestureHandleDefine.h"

@implementation GKPushAnimatedTransition

- (void)animateTransition {
    // 解决UITabbarController左滑push时的显示问题
    self.isHideTabBar = self.fromViewController.tabBarController && self.toViewController.hidesBottomBarWhenPushed;
    
    UITabBar *tabBar = self.fromViewController.tabBarController.tabBar;
    // tabBar位置不对或隐藏
    if (tabBar.frame.origin.x != 0 || tabBar.isHidden) {
        self.isHideTabBar = NO;
    }
    
    // 非根控制器
    if (self.fromViewController.navigationController.childViewControllers.firstObject != self.fromViewController) {
        self.isHideTabBar = NO;
    }

    CGFloat screenW = self.containerView.bounds.size.width;
    CGFloat screenH = self.containerView.bounds.size.height;

    __block UIView *fromView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    [fromView addSubview:self.fromViewController.view];
    
    __block UIView *captureView = nil;
    if (self.isHideTabBar) {
        // 截取tabBar
        UIImage *captureImage = [GKGestureConfigure getCaptureWithView:tabBar];
        
        self.fromViewController.gk_captureImage = captureImage;
        captureView = [[UIImageView alloc] initWithImage:captureImage];
        CGRect frame = tabBar.frame;
        frame.origin.x = 0;
        captureView.frame = frame;
        [fromView addSubview:captureView];
        tabBar.hidden = YES;
    }

    if (self.isScale) {
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [fromView addSubview:self.shadowView];
        fromView.transform = CGAffineTransformIdentity;
    }
    [self.containerView addSubview:fromView];

    // 设置toViewController
    self.toViewController.view.frame = CGRectMake(screenW, 0, screenW, screenH);
    self.toViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.toViewController.view.layer.shadowOpacity = 0.15f;
    self.toViewController.view.layer.shadowRadius = 3.0f;
    [self.containerView addSubview:self.toViewController.view];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.isScale) {
            self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
            fromView.transform = CGAffineTransformMakeScale(GKGestureConfigure.gk_scaleX, GKGestureConfigure.gk_scaleY);
        }else {
            CGRect frame = fromView.frame;
            frame.origin.x = -0.3 * frame.size.width;
            fromView.frame = frame;
        }
        self.toViewController.view.frame = CGRectMake(0, 0, screenW, screenH);
    } completion:^(BOOL finished) {
        if (self.transitionContext.transitionWasCancelled) {
            [self.containerView addSubview:self.fromViewController.view];
        }else {
            [self.fromViewController.view removeFromSuperview];
        }
        fromView.transform = CGAffineTransformIdentity;
        if (fromView) {
            [fromView removeFromSuperview];
            fromView = nil;
        }
        
        if (captureView) {
            [captureView removeFromSuperview];
            captureView = nil;
        }
        if (self.isScale) {
            [self.shadowView removeFromSuperview];
        }
        [self completeTransition];
    }];
}

@end
