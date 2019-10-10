//
//  GKPushTransitionAnimation.m
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/10.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKPushTransitionAnimation.h"
#import "GKCommon.h"

@implementation GKPushTransitionAnimation

- (void)animateTransition {
    // 解决UITabBarController左滑push时的显示问题
    BOOL isHideTabBar = self.fromViewController.tabBarController && self.toViewController.hidesBottomBarWhenPushed;
    
    __block UIView *fromView = nil;
    
    if (isHideTabBar) {
        // 获取fromVC的截图
        UIImage *captureImage = [self getCaptureWithView:self.fromViewController.view.window];
        UIImageView *captureView = [[UIImageView alloc] initWithImage:captureImage];
        captureView.frame = CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
        [self.containerView addSubview:captureView];
        fromView = captureView;
        self.fromViewController.gk_captureImage = captureImage;
        self.fromViewController.view.hidden = YES;
        self.fromViewController.tabBarController.tabBar.hidden = YES;
    }else {
        fromView = self.fromViewController.view;
    }
    
    [self.containerView addSubview:self.toViewController.view];
    
    // 设置转场前的frame
    self.toViewController.view.frame = CGRectMake(GK_SCREEN_WIDTH, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
    
    if (self.scale) {
        // 初始化阴影并添加
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [fromView addSubview:self.shadowView];
    }
    
    self.toViewController.view.layer.shadowColor   = [[UIColor blackColor] CGColor];
    self.toViewController.view.layer.shadowOpacity = 0.6;
    self.toViewController.view.layer.shadowRadius  = 8;
    
    // 执行动画
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        if (self.scale) {
            if (GKDeviceVersion >= 11.0) {
                CGRect frame = fromView.frame;
                frame.origin.x     = GKConfigure.gk_translationX;
                frame.origin.y     = GKConfigure.gk_translationY;
                frame.size.height -= 2 * GKConfigure.gk_translationY;
                
                fromView.frame = frame;
            }else {
                fromView.transform = CGAffineTransformMakeScale(GKConfigure.gk_scaleX, GKConfigure.gk_scaleY);
            }
        }else {
            fromView.frame = CGRectMake(- (0.3 * GK_SCREEN_WIDTH), 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
        }
        
        self.toViewController.view.frame = CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
    }completion:^(BOOL finished) {
        [self completeTransition];
        if (isHideTabBar) {
            [fromView removeFromSuperview];
            fromView = nil;
            
            self.fromViewController.view.hidden = NO;
            
            if (self.fromViewController.navigationController.childViewControllers.count == 1) {
                
                self.fromViewController.tabBarController.tabBar.hidden = NO;
            }
        }
        [self.shadowView removeFromSuperview];
    }];
}

@end
