//
//  GKPopTransitionAnimation.m
//  GKNavigationBarViewControllerDemo
//
//  Created by QuintGao on 2017/7/10.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKPopTransitionAnimation.h"
#import "GKCommon.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

@interface GKPopTransitionAnimation()

@property (nonatomic, assign) BOOL scale;

@property (nonatomic, strong) UIView *shadowView;

@end

@implementation GKPopTransitionAnimation

+ (instancetype)transitionWithScale:(BOOL)scale {
    return [[self alloc] initWithScale:scale];
}

- (instancetype)initWithScale:(BOOL)scale {
    if (self = [super init]) {
        self.scale = scale;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return UINavigationControllerHideShowBarDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 获取转场容器
    UIView *containerView = [transitionContext containerView];
    
    // 获取转场前后的控制器
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    
    if (self.scale) {
        // 初始化阴影图层
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        [toVC.view addSubview:self.shadowView];
        
        if (GKDeviceVersion >= 11.0) {
            CGRect frame = toVC.view.frame;
            frame.origin.x     = 5;
            frame.origin.y     = 5;
            frame.size.height -= 10;
            
            toVC.view.frame = frame;
        }else {
            toVC.view.transform = CGAffineTransformMakeScale(0.95, 0.97);
        }

    }else {
        fromVC.view.frame = CGRectMake(- (0.3 * kScreenW), 0, kScreenW, kScreenH);
    }
    
    // 添加阴影
    fromVC.view.layer.shadowColor   = [[UIColor blackColor] CGColor];
    fromVC.view.layer.shadowOpacity = 0.5;
    fromVC.view.layer.shadowRadius  = 8;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        
        fromVC.view.frame = CGRectMake(kScreenW, 0, kScreenW, kScreenH);
        
        if (GKDeviceVersion >= 11.0) {
            toVC.view.frame = CGRectMake(0, 0, kScreenW, kScreenH);
        }else {
            toVC.view.transform = CGAffineTransformIdentity;
        }
    }completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [self.shadowView removeFromSuperview];
    }];
}

@end
