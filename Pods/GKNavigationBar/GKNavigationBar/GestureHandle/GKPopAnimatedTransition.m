//
//  GKPopAnimatedTransition.m
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKPopAnimatedTransition.h"
#import "GKGestureHandleDefine.h"

@implementation GKPopAnimatedTransition

- (void)animateTransition {
    // 是否隐藏tabBar
    self.isHideTabBar = self.toViewController.tabBarController && self.fromViewController.hidesBottomBarWhenPushed && self.toViewController.gk_captureImage;
    if (self.toViewController.navigationController.childViewControllers.firstObject != self.toViewController) {
        self.isHideTabBar = NO;
    }
    UITabBar *tabBar = self.toViewController.tabBarController.tabBar;
    
    CGFloat screenW = self.containerView.bounds.size.width;
    CGFloat screenH = self.containerView.bounds.size.height;
    
    __block UIView *toView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    __block UIView *captureView = nil;
    
    [toView addSubview:self.toViewController.view];
    
    if (self.isHideTabBar) {
        captureView = [[UIImageView alloc] initWithImage:self.toViewController.gk_captureImage];
        CGRect frame = tabBar.frame;
        frame.origin.x = 0;
        captureView.frame = frame;
        [toView addSubview:captureView];
        tabBar.hidden = YES;
    }
    
    if (self.isScale) {
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        [toView addSubview:self.shadowView];
        toView.transform = CGAffineTransformMakeScale(GKGestureConfigure.gk_scaleX, GKGestureConfigure.gk_scaleY);
    }else {
        CGRect frame = toView.frame;
        frame.origin.x = -0.3 * frame.size.width;
        toView.frame = frame;
    }
    
    [self.containerView insertSubview:toView belowSubview:self.fromViewController.view];
    
    self.fromViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.fromViewController.view.layer.shadowOpacity = 0.15f;
    self.fromViewController.view.layer.shadowRadius = 3.0f;
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.fromViewController.view.frame = CGRectMake(screenW, 0, screenW, screenH);
        if (self.isScale) {
            self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
            toView.transform = CGAffineTransformIdentity;
        }else {
            CGRect frame = toView.frame;
            frame.origin.x = 0;
            toView.frame = frame;
        }
    } completion:^(BOOL finished) {
        if (self.isHideTabBar) {
            if (self.toViewController.navigationController.childViewControllers.count == 1) {
                tabBar.hidden = NO;
            }
        }
        
        if (self.transitionContext.transitionWasCancelled) {
            [self.toViewController.view removeFromSuperview];
        }else {//transition 完成: 将之前的 tab 截屏清空
            self.toViewController.gk_captureImage = nil;
            [self.containerView addSubview:self.toViewController.view];
        }
        
        toView.transform = CGAffineTransformIdentity;
        if (toView) {
            [toView removeFromSuperview];
            toView = nil;
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
