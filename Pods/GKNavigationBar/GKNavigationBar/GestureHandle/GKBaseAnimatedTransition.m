//
//  GKBaseAnimatedTransition.m
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKBaseAnimatedTransition.h"
#import <objc/runtime.h>

@implementation GKBaseAnimatedTransition

- (instancetype)initWithScale:(BOOL)isScale {
    if (self = [super init]) {
        self.isScale = isScale;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning
// 转场动画需要的时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return UINavigationControllerHideShowBarDuration;
}

// 转场动画
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 获取容器
    UIView *containerView = [transitionContext containerView];
    
    // 获取转场前后的控制器
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    self.containerView = containerView;
    self.fromViewController = fromVC;
    self.toViewController = toVC;
    self.transitionContext = transitionContext;
    
    // 开始动画
    [self animateTransition];
}

- (NSTimeInterval)animationDuration {
    return [self transitionDuration:self.transitionContext];
}

// 子类实现
- (void)animateTransition {}

- (void)completeTransition {
    [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
}

@end

@implementation UIViewController (GKCapture)

static char kAssociatedObjectKey_captureImage;
- (void)setGk_captureImage:(UIImage *)gk_captureImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_captureImage, gk_captureImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)gk_captureImage {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_captureImage);
}

@end
