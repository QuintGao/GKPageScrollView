//
//  GKTransitionDelegateHandler.m
//  GKNavigationBar
//
//  Created by gaokun on 2019/10/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKTransitionDelegateHandler.h"
#import "UIViewController+GKCategory.h"
#import "UINavigationController+GKCategory.h"

@interface GKNavigationControllerDelegateHandler()

/// 是否是push操作
@property (nonatomic, assign) BOOL isGesturePush;

/// push动画
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *pushTransition;

/// pop动画
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *popTransition;

@end

@implementation GKNavigationControllerDelegateHandler

#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (self.navigationController.gk_transitionScale || (self.navigationController.gk_openScrollLeftPush && self.pushTransition)) {
        if (operation == UINavigationControllerOperationPush) {
            return [GKPushAnimatedTransition transitionWithScale:self.navigationController.gk_transitionScale];
        }else if (operation == UINavigationControllerOperationPop) {
            return [GKPopAnimatedTransition transitionWithScale:self.navigationController.gk_transitionScale];
        }
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if (self.navigationController.gk_transitionScale || (self.navigationController.gk_openScrollLeftPush && self.pushTransition)) {
        if ([animationController isKindOfClass:[GKPushAnimatedTransition class]]) {
            return self.pushTransition;
        }else if ([animationController isKindOfClass:[GKPopAnimatedTransition class]]) {
            return self.popTransition;
        }
    }
    return nil;
}

#pragma mark - 滑动手势处理
- (void)panGestureAction:(UIPanGestureRecognizer *)gesture {
    UIViewController *visibleVC = self.navigationController.visibleViewController;
    
    // 进度
    CGFloat progress = [gesture translationInView:gesture.view].x / gesture.view.bounds.size.width;
    CGPoint velocity = [gesture velocityInView:gesture.view];
    
    // 在手势开始的时候判断是push操作还是pop操作
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.isGesturePush = velocity.x < 0 ? YES : NO;
    }
    
    // push时progess < 0 需要做处理
    if (self.isGesturePush) {
        progress = -progress;
    }
    
    progress = MIN(1.0f, MAX(0.0f, progress));
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.isGesturePush) { // push
            if (self.navigationController.gk_openScrollLeftPush) {
                if (visibleVC.gk_pushDelegate && [visibleVC.gk_pushDelegate respondsToSelector:@selector(pushToNextViewController)]) {
                    self.pushTransition = [UIPercentDrivenInteractiveTransition new];
                    self.pushTransition.completionCurve = UIViewAnimationCurveEaseOut;
                    [self.pushTransition updateInteractiveTransition:0];
                    
                    [visibleVC.gk_pushDelegate pushToNextViewController];
                }
            }
        }else { // pop
            if (visibleVC.gk_popDelegate) {
                if ([visibleVC.gk_popDelegate respondsToSelector:@selector(viewControllerPopScrollBegan)]) {
                    [visibleVC.gk_popDelegate viewControllerPopScrollBegan];
                }
            }else {
                self.popTransition = [UIPercentDrivenInteractiveTransition new];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (self.isGesturePush) {
            if (self.pushTransition) {
                [self.pushTransition updateInteractiveTransition:progress];
            }
        }else {
            if (visibleVC.gk_popDelegate) {
                if ([visibleVC.gk_popDelegate respondsToSelector:@selector(viewControllerPopScrollUpdate:)]) {
                    [visibleVC.gk_popDelegate viewControllerPopScrollUpdate:progress];
                }
            }else {
                [self.popTransition updateInteractiveTransition:progress];
            }
        }
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (self.isGesturePush) {
            if (self.pushTransition) {
                if (progress > GKConfigure.gk_pushTransitionCriticalValue) {
                    [self.pushTransition finishInteractiveTransition];
                }else {
                    [self.pushTransition cancelInteractiveTransition];
                }
            }
        }else {
            if (visibleVC.gk_popDelegate) {
                if ([visibleVC.gk_popDelegate respondsToSelector:@selector(viewControllerPopScrollEnded)]) {
                    [visibleVC.gk_popDelegate viewControllerPopScrollEnded];
                }
            }else {
                if (progress > GKConfigure.gk_popTransitionCriticalValue) {
                    [self.popTransition finishInteractiveTransition];
                }else {
                    [self.popTransition cancelInteractiveTransition];
                }
            }
        }
        self.pushTransition = nil;
        self.popTransition  = nil;
        self.isGesturePush  = NO;
    }
}

@end

@implementation GKGestureRecognizerDelegateHandler

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    UIViewController *visibleVC = self.navigationController.visibleViewController;
    
    if (self.navigationController.gk_openScrollLeftPush) {
        // 开启了左滑push功能
    }else if (visibleVC.gk_popDelegate) {
        // 设置了gk_popDelegate
    }else {
        // 忽略根控制器
        if (self.navigationController.viewControllers.count <= 1) return NO;
    }
    
    // 忽略禁用手势
    if (visibleVC.gk_interactivePopDisabled) return NO;
    
    CGPoint transition = [gestureRecognizer translationInView:gestureRecognizer.view];
    
    SEL action = NSSelectorFromString(@"handleNavigationTransition:");
    
    if (transition.x < 0) { // 左滑处理
        // 开启了左滑push并设置了代理
        if (self.navigationController.gk_openScrollLeftPush && visibleVC.gk_pushDelegate) {
            [gestureRecognizer removeTarget:self.systemTarget action:action];
            [gestureRecognizer addTarget:self.customTarget action:@selector(panGestureAction:)];
        }else {
            return NO;
        }
    }else { // 右滑处理
        // 解决根控制器右滑时出现的卡死情况
        if (visibleVC.gk_popDelegate) {
            // 实现了gk_popDelegate，不作处理
        }else {
            if (self.navigationController.viewControllers.count <= 1) return NO;
        }
        
        // 全屏滑动时起作用
        if (!visibleVC.gk_fullScreenPopDisabled) {
            // 上下滑动
            if (transition.x == 0) return NO;
        }
        
        // 忽略超出手势区域
        CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
        CGFloat maxAllowDistance  = visibleVC.gk_maxPopDistance;
        
        if (maxAllowDistance > 0 && beginningLocation.x > maxAllowDistance) {
            return NO;
        }else if (visibleVC.gk_popDelegate) {
            [gestureRecognizer removeTarget:self.systemTarget action:action];
            [gestureRecognizer addTarget:self.customTarget action:@selector(panGestureAction:)];
        }else if(!self.navigationController.gk_transitionScale) { // 非缩放，系统处理
            [gestureRecognizer removeTarget:self.customTarget action:@selector(panGestureAction:)];
            [gestureRecognizer addTarget:self.systemTarget action:action];
        }else {
            [gestureRecognizer removeTarget:self.systemTarget action:action];
            [gestureRecognizer addTarget:self.customTarget action:@selector(panGestureAction:)];
        }
    }
    
    // 忽略导航控制器正在做转场动画
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) return NO;
    
    return YES;
}

@end
