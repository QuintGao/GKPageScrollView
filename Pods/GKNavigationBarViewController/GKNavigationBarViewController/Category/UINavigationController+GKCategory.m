//
//  UINavigationController+GKCategory.m
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "UINavigationController+GKCategory.h"
#import "GKNavigationBarViewController.h"
#import <objc/runtime.h>

@implementation UINavigationController (GKCategory)

+ (instancetype)rootVC:(UIViewController *)rootVC translationScale:(BOOL)translationScale {
    return [[self alloc] initWithRootVC:rootVC translationScale:translationScale];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
 
- (instancetype)initWithRootVC:(UIViewController *)rootVC translationScale:(BOOL)translationScale {
    if (self = [super init]) {
        [self pushViewController:rootVC animated:YES];
        self.gk_translationScale = translationScale;
    }
    return self;
}

#pragma clang diagnostic pop

// 方法交换
+ (void)load {
    // 保证其只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gk_swizzled_method(self, @"viewDidLoad", self);
    });
}

- (void)gk_viewDidLoad {
    // 处理特殊控制器
    if ([self isKindOfClass:[UIImagePickerController class]]) return;
    if ([self isKindOfClass:[UIVideoEditorController class]]) return;
    
    // 设置代理和通知
    // 设置背景色
    self.view.backgroundColor = [UIColor blackColor];
    
    // 设置代理
    self.delegate = self.navDelegate;
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:GKViewControllerPropertyChangedNotification object:nil];
    
    [self gk_viewDidLoad];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GKViewControllerPropertyChangedNotification object:nil];
}

#pragma mark - Notification Handle
- (void)handleNotification:(NSNotification *)notify {
    
    UIViewController *vc = (UIViewController *)notify.object[@"viewController"];
    
    BOOL isRootVC = vc == self.viewControllers.firstObject;
    
    // 重新根据属性添加手势方法
    if (vc.gk_interactivePopDisabled) { // 禁止滑动
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
        
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.screenPanGesture];
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.panGesture];
    }else if (vc.gk_fullScreenPopDisabled) { // 禁止全屏滑动
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.panGesture];
        
        if (self.gk_translationScale) {
            self.interactivePopGestureRecognizer.delegate = nil;
            self.interactivePopGestureRecognizer.enabled = NO;
            
            if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.screenPanGesture]) {
                [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.screenPanGesture];
                self.screenPanGesture.delegate = self.popGestureDelegate;
            }
        }else {
            self.interactivePopGestureRecognizer.delaysTouchesBegan = YES;
            self.interactivePopGestureRecognizer.delegate = self.popGestureDelegate;
            self.interactivePopGestureRecognizer.enabled = !isRootVC;
        }
    }else {
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.screenPanGesture];
        
        // 给self.interactivePopGestureRecognizer.view 添加全屏滑动手势
        if (!isRootVC && ![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.panGesture]) {
            [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.panGesture];
            self.panGesture.delegate = self.popGestureDelegate;
        }
        
        // 添加手势处理
        if (self.gk_translationScale || self.gk_openScrollLeftPush || self.visibleViewController.gk_popDelegate) {
            [self.panGesture addTarget:self.navDelegate action:@selector(panGestureAction:)];
        }else {
            SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
            [self.panGesture addTarget:[self systemTarget] action:internalAction];
        }
    }
}

#pragma mark - StatusBar
- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.visibleViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.visibleViewController;
}

- (BOOL)prefersStatusBarHidden {
    return self.visibleViewController.gk_statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.visibleViewController.gk_statusBarStyle;
}

#pragma mark - getter
- (BOOL)gk_translationScale {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)gk_openScrollLeftPush {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (GKPopGestureRecognizerDelegate *)popGestureDelegate {
    GKPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [GKPopGestureRecognizerDelegate new];
        delegate.navigationController = self;
        delegate.systemTarget         = [self systemTarget];
        delegate.customTarget         = self.navDelegate;
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (GKNavigationControllerDelegate *)navDelegate {
    GKNavigationControllerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [GKNavigationControllerDelegate new];
        delegate.navigationController = self;
        delegate.pushDelegate         = self;
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIScreenEdgePanGestureRecognizer *)screenPanGesture {
    UIScreenEdgePanGestureRecognizer *panGesture = objc_getAssociatedObject(self, _cmd);
    if (!panGesture) {
        panGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.navDelegate action:@selector(panGestureAction:)];
        panGesture.edges = UIRectEdgeLeft;
        
        objc_setAssociatedObject(self, _cmd, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    UIPanGestureRecognizer *panGesture = objc_getAssociatedObject(self, _cmd);
    if (!panGesture) {
        panGesture = [[UIPanGestureRecognizer alloc] init];
        panGesture.maximumNumberOfTouches = 1;
        
        objc_setAssociatedObject(self, _cmd, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGesture;
}

- (id)systemTarget {
    NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
    id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
    
    return internalTarget;
}

#pragma mark - setter
- (void)setGk_translationScale:(BOOL)gk_translationScale {
    objc_setAssociatedObject(self, @selector(gk_translationScale), @(gk_translationScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setGk_openScrollLeftPush:(BOOL)gk_openScrollLeftPush {
    objc_setAssociatedObject(self, @selector(gk_openScrollLeftPush), @(gk_openScrollLeftPush), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - GKViewControllerScrollPushDelegate
- (void)pushNext {
    // 获取当前控制器
    UIViewController *currentVC = self.visibleViewController;
    
    if ([currentVC.gk_pushDelegate respondsToSelector:@selector(pushToNextViewController)]) {
        [currentVC.gk_pushDelegate pushToNextViewController];
    }
}

@end
