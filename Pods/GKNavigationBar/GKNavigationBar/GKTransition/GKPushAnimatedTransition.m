//
//  GKPushAnimatedTransition.m
//  GKNavigationBar
//
//  Created by gaokun on 2019/10/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKPushAnimatedTransition.h"

@implementation GKPushAnimatedTransition

- (void)animateTransition {
    // 解决UITabbarController左滑push时的显示问题
    BOOL isHideTabBar = self.fromViewController.tabBarController && self.toViewController.hidesBottomBarWhenPushed;
    
    __block UIView *fromView = nil;
    if (isHideTabBar) {
        // 获取fromViewController的截图
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
    
    if (self.isScale) {
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [fromView addSubview:self.shadowView];
    }
    
    // 设置toViewController
    self.toViewController.view.frame = CGRectMake(GK_SCREEN_WIDTH, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
    self.toViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.toViewController.view.layer.shadowOpacity = 0.2f;
    self.toViewController.view.layer.shadowRadius = 4.0f;
    
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
        if (self.isScale) {
            self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
            if (@available(iOS 11.0, *)) {
                CGRect frame = fromView.frame;
                frame.origin.x = GKConfigure.gk_translationX;
                frame.origin.y = GKConfigure.gk_translationY;
                frame.size.height -= 2 * GKConfigure.gk_translationY;
                fromView.frame = frame;
            }else {
                fromView.transform = CGAffineTransformMakeScale(GKConfigure.gk_scaleX, GKConfigure.gk_scaleY);
            }
        }else {
            fromView.frame = CGRectMake(- (0.3 * GK_SCREEN_WIDTH), 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
        }
        
        self.toViewController.view.frame = CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        [self completeTransition];
        if (isHideTabBar) {
            [fromView removeFromSuperview];
            fromView = nil;
            
            self.fromViewController.view.hidden = NO;
            if (self.fromViewController.navigationController.childViewControllers.count == 1) {
                self.fromViewController.tabBarController.tabBar.hidden = NO;
            }
        }
        if (self.isScale) {
            [self.shadowView removeFromSuperview];
        }
    }];
}

@end
