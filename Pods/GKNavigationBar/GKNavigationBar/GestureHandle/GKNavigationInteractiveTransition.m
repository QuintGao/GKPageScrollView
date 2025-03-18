//
//  GKNavigationInteractiveTransition.m
//  GKNavigationBar
//
//  Created by QuintGao on 2020/11/24.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKNavigationInteractiveTransition.h"
#import "GKPushAnimatedTransition.h"
#import "GKPopAnimatedTransition.h"
#import "GKGestureHandleDefine.h"

@interface GKNavigationInteractiveTransition()

/// 当前正在处理的vc
@property (nonatomic, weak) UIViewController *visibleVC;

/// 是否是push操作
@property (nonatomic, assign) BOOL isGesturePush;

/// push动画
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *pushTransition;

/// pop动画
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *popTransition;

@end

@implementation GKNavigationInteractiveTransition

- (void)panGestureAction:(UIPanGestureRecognizer *)gesture {
    // 进度
    CGFloat progress = [gesture translationInView:gesture.view].x / gesture.view.bounds.size.width;
    CGPoint velocity = [gesture velocityInView:gesture.view];
    
    // 在手势开始的时候判断是push操作还是pop操作，并获取visibleVC
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.isGesturePush = velocity.x < 0 ? YES : NO;
        self.visibleVC = self.navigationController.visibleViewController;
    }
    
    // push时progress < 0 需要做处理
    if (self.isGesturePush) {
        progress = -progress;
    }
    
    progress = MIN(1.0f, MAX(0.0f, progress));
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.isGesturePush) { // push操作
            if (self.navigationController.gk_openScrollLeftPush) {
                if (self.visibleVC.gk_pushDelegate && [self.visibleVC.gk_pushDelegate respondsToSelector:@selector(pushToNextViewController)]) {
                    self.pushTransition = [UIPercentDrivenInteractiveTransition new];
                    [self.visibleVC.gk_pushDelegate pushToNextViewController];
                }
            }
            [self pushScrollBegan];
        }else { // pop操作
            if (self.navigationController.gk_transitionScale) {
                self.popTransition = [UIPercentDrivenInteractiveTransition new];
                [self.navigationController popViewControllerAnimated:YES];
            }else if (self.visibleVC.gk_systemGestureHandleDisabled) {
                BOOL shouldPop = [self.visibleVC navigationShouldPop];
                if ([self.visibleVC respondsToSelector:@selector(navigationShouldPopOnGesture)]) {
                    shouldPop = [self.visibleVC navigationShouldPopOnGesture];
                }
                if (shouldPop) {
                    self.popTransition = [UIPercentDrivenInteractiveTransition new];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            [self popScrollBegan];
        }
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (self.isGesturePush) { // push操作
            if (self.pushTransition) {
                [self.pushTransition updateInteractiveTransition:progress];
            }
            [self pushScrollUpdate:progress];
        }else {
            if (self.popTransition) {
                [self.popTransition updateInteractiveTransition:progress];
            }
            [self popScrollUpdate:progress];
        }
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (self.isGesturePush) {
            BOOL pushFinished = progress > 0.5;
            if (self.pushTransition) {
                if ([GKGestureConfigure isVelocityInSensitivity:velocity.x] && velocity.x < 0) {
                    pushFinished = YES;
                    [self.pushTransition finishInteractiveTransition];
                }else {
                    if (progress > GKGestureConfigure.gk_pushTransitionCriticalValue) {
                        pushFinished = YES;
                        [self.pushTransition finishInteractiveTransition];
                    }else {
                        pushFinished = NO;
                        [self.pushTransition cancelInteractiveTransition];
                    }
                }
            }
            [self pushScrollEnded:pushFinished];
        }else {
            BOOL popFinished = progress > 0.5;
            if (self.popTransition) {
                if ([GKGestureConfigure isVelocityInSensitivity:velocity.x] && velocity.x > 0) {
                    popFinished = YES;
                    [self.popTransition finishInteractiveTransition];
                }else {
                    if (progress > GKGestureConfigure.gk_popTransitionCriticalValue) {
                        popFinished = YES;
                        [self.popTransition finishInteractiveTransition];
                    }else {
                        popFinished = NO;
                        [self.popTransition cancelInteractiveTransition];
                    }
                }
            }else if ([GKGestureConfigure isVelocityInSensitivity:velocity.x] && velocity.x > 0) {
                popFinished = YES;
            }
            [self popScrollEnded:popFinished];
        }
        self.pushTransition = nil;
        self.popTransition  = nil;
        self.visibleVC      = nil;
        self.isGesturePush  = NO;
    }
}

- (void)pushScrollBegan {
    if (self.visibleVC.gk_pushDelegate && [self.visibleVC.gk_pushDelegate respondsToSelector:@selector(viewControllerPushScrollBegan)]) {
        [self.visibleVC.gk_pushDelegate viewControllerPushScrollBegan];
    }
}

- (void)pushScrollUpdate:(CGFloat)progress {
    if (self.visibleVC.gk_pushDelegate && [self.visibleVC.gk_pushDelegate respondsToSelector:@selector(viewControllerPushScrollUpdate:)]) {
        [self.visibleVC.gk_pushDelegate viewControllerPushScrollUpdate:progress];
    }
}

- (void)pushScrollEnded:(BOOL)finished {
    if (self.visibleVC.gk_pushDelegate && [self.visibleVC.gk_pushDelegate respondsToSelector:@selector(viewControllerPushScrollEnded:)]) {
        [self.visibleVC.gk_pushDelegate viewControllerPushScrollEnded:finished];
    }
}

- (void)popScrollBegan {
    if (self.visibleVC.gk_popDelegate && [self.visibleVC.gk_popDelegate respondsToSelector:@selector(viewControllerPopScrollBegan)]) {
        [self.visibleVC.gk_popDelegate viewControllerPopScrollBegan];
    }
}

- (void)popScrollUpdate:(CGFloat)progress {
    if (self.visibleVC.gk_popDelegate && [self.visibleVC.gk_popDelegate respondsToSelector:@selector(viewControllerPopScrollUpdate:)]) {
        [self.visibleVC.gk_popDelegate viewControllerPopScrollUpdate:progress];
    }
}

- (void)popScrollEnded:(CGFloat)finished {
    if (self.visibleVC.gk_popDelegate && [self.visibleVC.gk_popDelegate respondsToSelector:@selector(viewControllerPopScrollEnded:)]) {
        [self.visibleVC.gk_popDelegate viewControllerPopScrollEnded:finished];
    }
}

#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
   
    if (fromVC.gk_pushTransition && operation == UINavigationControllerOperationPush) {
        return fromVC.gk_pushTransition;
    }
    
    if (fromVC.gk_popTransition && operation == UINavigationControllerOperationPop) {
        return fromVC.gk_popTransition;
    }
    
    CGFloat isScale = self.navigationController.gk_transitionScale;
    if ((isScale || self.pushTransition) && operation == UINavigationControllerOperationPush) {
        return [[GKPushAnimatedTransition alloc] initWithScale:isScale];
    }
        
    if ((isScale || self.popTransition) && operation == UINavigationControllerOperationPop) {
        return [[GKPopAnimatedTransition alloc] initWithScale:isScale];
    }
    
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    
    if (self.pushTransition && [animationController isKindOfClass:[GKPushAnimatedTransition class]]) {
        return self.pushTransition;
    }
    
    if (self.popTransition && [animationController isKindOfClass:[GKPopAnimatedTransition class]]) {
        return self.popTransition;
    }
    
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // 获取当前显示的VC
    UIViewController *visibleVC = self.navigationController.visibleViewController;
    
    // 当前VC禁止滑动返回
    if (visibleVC.gk_interactivePopDisabled) return NO;
    
    // 根据transition判断是左滑还是右滑
    CGPoint transition = [gestureRecognizer translationInView:gestureRecognizer.view];
    
    // 如果开启缩放，则移除系统处理
    if (self.navigationController.gk_transitionScale) {
        [gestureRecognizer removeTarget:self.systemTarget action:self.systemAction];
    }
    
    if (transition.x < 0) { // 左滑
        // 开启了左滑push并设置了代理
        if (self.navigationController.gk_openScrollLeftPush && visibleVC.gk_pushDelegate) {
            [gestureRecognizer removeTarget:self.systemTarget action:self.systemAction];
        }else {
            return NO;
        }
    }else if (transition.x > 0) { // 右滑
        if (!visibleVC.gk_systemGestureHandleDisabled) {
            if (!self.navigationController.gk_transitionScale) {//没有开启缩放, 添加系统处理
                [gestureRecognizer addTarget:self.systemTarget action:self.systemAction];
            }
            BOOL shouldPop = [visibleVC navigationShouldPop];
            if ([visibleVC respondsToSelector:@selector(navigationShouldPopOnGesture)]) {
                shouldPop = [visibleVC navigationShouldPopOnGesture];
            }
            if (!shouldPop) return NO;
        }
        
        // 解决根控制器右滑时出现的卡死情况
        if (self.navigationController.viewControllers.count <= 1) return NO;
        
        // 忽略超出手势区域
        CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
        CGFloat maxAllowDistance  = visibleVC.gk_maxPopDistance;
        
        if (maxAllowDistance > 0 && beginningLocation.x > maxAllowDistance) return NO;
    }else {
        if (visibleVC.gk_fullScreenPopDisabled) {
            // 修复边缘侧滑返回失效的bug
            if (self.navigationController.viewControllers.count <= 1) return NO;
        }else {
            // 修复全屏返回手势上下滑动时可能导致的卡死情况
            return NO;
        }
    }
    
    // 忽略导航控制器正在做转场动画
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) return NO;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 获取当前显示的VC
    UIViewController *visibleVC = self.navigationController.visibleViewController;
    
    if ([visibleVC respondsToSelector:@selector(popGestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [visibleVC popGestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    
    return NO;
}

@end
