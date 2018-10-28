//
//  GKPushTransitionAnimation.m
//  GKNavigationBarViewControllerDemo
//
//  Created by QuintGao on 2017/7/10.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKPushTransitionAnimation.h"
#import "GKCommon.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

@interface GKPushTransitionAnimation()

@property (nonatomic, assign) BOOL scale;

@property (nonatomic, strong) UIView *shadowView;

@end

@implementation GKPushTransitionAnimation

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

// 转场动画的时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return UINavigationControllerHideShowBarDuration;
}

// 转场动画
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 获取转场容器
    UIView *containerView = [transitionContext containerView];
    
    // 获取转场前后的控制器
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [containerView insertSubview:toVC.view aboveSubview:fromVC.view];
    
    // 设置转场前的frame
    toVC.view.frame = CGRectMake(kScreenW, 0, kScreenW, kScreenH);
    
    if (self.scale) {
        // 初始化阴影并添加
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        [fromVC.view addSubview:self.shadowView];
    }
    
    toVC.view.layer.shadowColor   = [[UIColor blackColor] CGColor];
    toVC.view.layer.shadowOpacity = 0.6;
    toVC.view.layer.shadowRadius  = 8;
    
    // 执行动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        if (self.scale) {
            
            if (GKDeviceVersion >= 11.0) {
                CGRect frame = fromVC.view.frame;
                frame.origin.x     = 5;
                frame.origin.y     = 5;
                frame.size.height -= 10;
                
                fromVC.view.frame = frame;
            }else {
                fromVC.view.transform = CGAffineTransformMakeScale(0.95, 0.97);
            }
            
        }else {
            fromVC.view.frame = CGRectMake(- (0.3 * kScreenW), 0, kScreenW, kScreenH);
        }
        
        toVC.view.frame = CGRectMake(0, 0, kScreenW, kScreenH);
    }completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [self.shadowView removeFromSuperview];
    }];
}


@end
