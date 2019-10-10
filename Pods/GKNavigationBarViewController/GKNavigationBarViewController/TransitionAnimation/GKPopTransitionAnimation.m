//
//  GKPopTransitionAnimation.m
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/10.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKPopTransitionAnimation.h"
#import "GKCommon.h"

@implementation GKPopTransitionAnimation

- (void)animateTransition {
    [self.containerView insertSubview:self.toViewController.view belowSubview:self.fromViewController.view];
    
    if (self.scale) {
        // 初始化阴影图层
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        [self.toViewController.view addSubview:self.shadowView];
        
        if (GKDeviceVersion >= 11.0) {
            CGRect frame = self.toViewController.view.frame;
            frame.origin.x     = GKConfigure.gk_translationX;
            frame.origin.y     = GKConfigure.gk_translationY;
            frame.size.height -= 2 * GKConfigure.gk_translationY;
            
            self.toViewController.view.frame = frame;
        }else {
            self.toViewController.view.transform = CGAffineTransformMakeScale(GKConfigure.gk_scaleX, GKConfigure.gk_scaleY);
        }
    }else {
        self.fromViewController.view.frame = CGRectMake(- (0.3 * GK_SCREEN_WIDTH), 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
    }
    
    // 添加阴影
    self.fromViewController.view.layer.shadowColor   = [[UIColor blackColor] CGColor];
    self.fromViewController.view.layer.shadowOpacity = 0.5;
    self.fromViewController.view.layer.shadowRadius  = 8;
    
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        
        self.fromViewController.view.frame = CGRectMake(GK_SCREEN_WIDTH, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
        
        if (GKDeviceVersion >= 11.0) {
            self.toViewController.view.frame = CGRectMake(0, 0, GK_SCREEN_WIDTH, GK_SCREEN_HEIGHT);
        }else {
            self.toViewController.view.transform = CGAffineTransformIdentity;
        }
    }completion:^(BOOL finished) {
        [self completeTransition];
        [self.shadowView removeFromSuperview];
    }];
}

@end
