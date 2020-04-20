//
//  GKPopAnimatedTransition.m
//  GKNavigationBar
//
//  Created by gaokun on 2019/10/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKPopAnimatedTransition.h"

@implementation GKPopAnimatedTransition

- (void)animateTransition {
    [self.containerView insertSubview:self.toViewController.view belowSubview:self.fromViewController.view];
    
    // 是否隐藏tabBar
    BOOL isHideTabBar = self.toViewController.tabBarController && self.fromViewController.hidesBottomBarWhenPushed && self.toViewController.gk_captureImage;
    
    __block UIView *toView = nil;
    if (isHideTabBar) {
        UIImageView *captureView = [[UIImageView alloc] initWithImage:self.toViewController.gk_captureImage];
        captureView.frame = CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
        [self.containerView insertSubview:captureView belowSubview:self.fromViewController.view];
        toView = captureView;
        self.toViewController.view.hidden = YES;
        self.toViewController.tabBarController.tabBar.hidden = YES;
    }else {
        toView = self.toViewController.view;
    }
    
    if (self.isScale) {
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        [toView addSubview:self.shadowView];
        
        if (@available(iOS 11.0, *)) {
            CGRect frame = toView.frame;
            frame.origin.x = GKConfigure.gk_translationX;
            frame.origin.y = GKConfigure.gk_translationY;
            frame.size.height -= 2 * GKConfigure.gk_translationY;
            toView.frame = frame;
        }else {
            toView.transform = CGAffineTransformMakeScale(GKConfigure.gk_scaleX, GKConfigure.gk_scaleY);
        }
    }else {
        self.fromViewController.view.frame = CGRectMake(- (0.3 * GK_SCREEN_WIDTH), 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
    }
    
    self.fromViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.fromViewController.view.layer.shadowOpacity = 0.2f;
    self.fromViewController.view.layer.shadowRadius = 4.0f;
    
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
        self.fromViewController.view.frame = CGRectMake(GK_SCREEN_WIDTH, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
        if (self.isScale) {
            self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        }
        if (@available(iOS 11.0, *)) {
            toView.frame = CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
        }else {
            toView.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        [self completeTransition];
        if (isHideTabBar) {
            [toView removeFromSuperview];
            toView = nil;
            
            self.toViewController.view.hidden = NO;
            if (self.toViewController.navigationController.childViewControllers.count == 1) {
                self.toViewController.tabBarController.tabBar.hidden = NO;
            }
        }
        if (self.isScale) {
            [self.shadowView removeFromSuperview];
        }
    }];
}

@end
