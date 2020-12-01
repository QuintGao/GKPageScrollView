//
//  GKPushAnimatedTransition.m
//  GKNavigationBar
//
//  Created by gaokun on 2019/10/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKPushAnimatedTransition.h"
#import "GKGestureHandleDefine.h"

@implementation GKPushAnimatedTransition

- (void)animateTransition {
    // 解决UITabbarController左滑push时的显示问题
    self.isHideTabBar = self.fromViewController.tabBarController && self.toViewController.hidesBottomBarWhenPushed;

    CGFloat screenW = self.containerView.bounds.size.width;
    CGFloat screenH = self.containerView.bounds.size.height;

    __block UIView *fromView = nil;
    if (self.isHideTabBar) {
        // 获取fromViewController的截图
        UIImage *captureImage = [self getCaptureWithView:self.fromViewController.view.window];
        UIImageView *captureView = [[UIImageView alloc] initWithImage:captureImage];
        captureView.frame = CGRectMake(0, 0, screenW, screenH);
        [self.containerView addSubview:captureView];
        fromView = captureView;
        self.fromViewController.gk_captureImage = captureImage;
        self.fromViewController.view.hidden = YES;
        self.fromViewController.tabBarController.tabBar.hidden = YES;
    }else {
        fromView = self.fromViewController.view;
    }
    self.contentView = fromView;

    if (self.isScale) {
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [fromView addSubview:self.shadowView];
    }

    // 设置toViewController
    self.toViewController.view.frame = CGRectMake(screenW, 0, screenW, screenH);
    self.toViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.toViewController.view.layer.shadowOpacity = 0.15f;
    self.toViewController.view.layer.shadowRadius = 3.0f;
    [self.containerView addSubview:self.toViewController.view];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.isScale) {
            self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
            if (@available(iOS 11.0, *)) {
                CGRect frame = fromView.frame;
                frame.origin.x = GKGestureConfigure.gk_translationX;
                frame.origin.y = GKGestureConfigure.gk_translationY;
                frame.size.height -= 2 * GKGestureConfigure.gk_translationY;
                fromView.frame = frame;
            }else {
                fromView.transform = CGAffineTransformMakeScale(GKGestureConfigure.gk_scaleX, GKGestureConfigure.gk_scaleY);
            }
        }else {
            fromView.frame = CGRectMake(- (0.3 * screenW), 0, screenW, screenH);
        }

        self.toViewController.view.frame = CGRectMake(0, 0, screenW, screenH);
    } completion:^(BOOL finished) {
        [self completeTransition];
        if (self.isHideTabBar) {
            [self.contentView removeFromSuperview];
            self.contentView = nil;

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
