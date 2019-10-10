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
    [self.containerView addSubview:self.toViewController.view];
    
    // 设置转场前的frame
    self.toViewController.view.frame = CGRectMake(GK_SCREEN_WIDTH, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
    
    if (self.scale) {
        // 初始化阴影并添加
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [self.fromViewController.view addSubview:self.shadowView];
    }
    
    self.toViewController.view.layer.shadowColor   = [[UIColor blackColor] CGColor];
    self.toViewController.view.layer.shadowOpacity = 0.6;
    self.toViewController.view.layer.shadowRadius  = 8;
    
    // 执行动画
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        if (self.scale) {
            if (GKDeviceVersion >= 11.0) {
                CGRect frame = self.fromViewController.view.frame;
                frame.origin.x     = GKConfigure.gk_translationX;
                frame.origin.y     = GKConfigure.gk_translationY;
                frame.size.height -= 2 * GKConfigure.gk_translationY;
                
                self.fromViewController.view.frame = frame;
            }else {
                self.fromViewController.view.transform = CGAffineTransformMakeScale(GKConfigure.gk_scaleX, GKConfigure.gk_scaleY);
            }
        }else {
            self.fromViewController.view.frame = CGRectMake(- (0.3 * GK_SCREEN_WIDTH), 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
        }
        
        self.toViewController.view.frame = CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
    }completion:^(BOOL finished) {
        [self completeTransition];
        [self.shadowView removeFromSuperview];
    }];
}

@end
