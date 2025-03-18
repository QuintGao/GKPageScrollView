//
//  UINavigationController+GKGestureHandle.m
//  GKNavigationBar
//
//  Created by QuintGao on 2020/10/29.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "UINavigationController+GKGestureHandle.h"
#import "UIViewController+GKGestureHandle.h"
#import "GKNavigationInteractiveTransition.h"
#import "GKGestureHandleDefine.h"

@implementation UINavigationController (GKGestureHandle)

+ (instancetype)rootVC:(UIViewController *)rootVC {
    return [self rootVC:rootVC transitionScale:NO];
}

+ (instancetype)rootVC:(UIViewController *)rootVC transitionScale:(BOOL)transitionScale {
    return [[self alloc] initWithRootVC:rootVC transitionScale:transitionScale];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithRootVC:(UIViewController *)rootVC transitionScale:(BOOL)transitionScale {
    if (self = [super init]) {
        self.gk_openGestureHandle = YES;
        self.gk_transitionScale = transitionScale;
        [self pushViewController:rootVC animated:YES];
    }
    return self;
}
#pragma clang diagnostic pop

static char kAssociatedObjectKey_transitionScale;
- (void)setGk_transitionScale:(BOOL)gk_transitionScale {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_transitionScale, @(gk_transitionScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_transitionScale {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_transitionScale) boolValue];
}

static char kAssociatedObjectKey_openScrollLeftPush;
- (void)setGk_openScrollLeftPush:(BOOL)gk_openScrollLeftPush {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_openScrollLeftPush, @(gk_openScrollLeftPush), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_openScrollLeftPush {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_openScrollLeftPush) boolValue];
}

static char kAssociatedObjectKey_openGestureHandle;
- (void)setGk_openGestureHandle:(BOOL)gk_openGestureHandle {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_openGestureHandle, @(gk_openGestureHandle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_openGestureHandle {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_openGestureHandle) boolValue];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray <NSString *> *oriSels = @[@"viewDidLoad",
                                          @"pushViewController:animated:",
                                          @"navigationBar:shouldPopItem:",
                                          @"dealloc"];
        [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
            gk_gestureHandle_swizzled_instanceMethod(@"gkGesture", self, oriSel, self);
        }];
    });
}

- (void)gkGesture_viewDidLoad {
    if (self.gk_openGestureHandle) {
        // 处理特殊控制器
        if ([self isKindOfClass:[UIImagePickerController class]]) return;
        if ([self isKindOfClass:[UIVideoEditorController class]]) return;
        
        // 设置背景色
        self.view.backgroundColor = [UIColor blackColor];
        
        // 设置代理
        self.delegate = self.interactiveTransition;
        self.interactivePopGestureRecognizer.enabled = NO;
        
        // 注册控制器属性改变通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(propertyChangeNotification:) name:GKViewControllerPropertyChangedNotification object:nil];
    }
    [self gkGesture_viewDidLoad];
}

- (void)gkGesture_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        UIViewController *rootVC = self.childViewControllers.firstObject;
        // 获取tabbar截图
        if (viewController.gk_systemGestureHandleDisabled && !rootVC.gk_captureImage) {
            rootVC.gk_captureImage = [GKGestureConfigure getCaptureWithView:rootVC.view.window];
        }
        // 设置push时是否隐藏tabbar
        if (GKGestureConfigure.gk_hidesBottomBarWhenPushed && rootVC != viewController) {
            viewController.hidesBottomBarWhenPushed = YES;
        }
    }
    [self gkGesture_pushViewController:viewController animated:animated];
}

// source：https://github.com/onegray/UIViewController-BackButtonHandler
- (BOOL)gkGesture_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if ([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
    
    BOOL shouldPop = [self.topViewController navigationShouldPop];
    if ([self.topViewController respondsToSelector:@selector(navigationShouldPopOnClick)]) {
        shouldPop = [self.topViewController navigationShouldPopOnClick];
    }
    
    if(shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    } else {
        // Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        for (UIView *subview in [navigationBar subviews]) {
            if(0. < subview.alpha && subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
    }
    return NO;
}

- (void)gkGesture_dealloc {
    if (self.gk_openGestureHandle) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GKViewControllerPropertyChangedNotification object:nil];
    }
    [self gkGesture_dealloc];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

#pragma mark - Notifiaction
- (void)propertyChangeNotification:(NSNotification *)notification {
    UIViewController *vc = (UIViewController *)notification.object[@"viewController"];
    
    // 不处理导航控制器和tabbar控制器
    if ([vc isKindOfClass:[UINavigationController class]]) return;
    if ([vc isKindOfClass:[UITabBarController class]]) return;
    if (!vc.navigationController) return;
    if (vc.navigationController != self) return;
    // 修复非导航控制器子类时出现的问题
    if (vc.parentViewController != self) return;
    
    __block BOOL exist = NO;
    [GKGestureConfigure.shiledGuestureVCs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj class] isSubclassOfClass:[UIViewController class]]) {
            if ([vc isKindOfClass:[obj class]]) {
                exist = YES;
                *stop = YES;
            }
        }else if ([obj isKindOfClass:[NSString class]]) {
            if ([NSStringFromClass(vc.class) isEqualToString:obj]) {
                exist = YES;
                *stop = YES;
            }else if ([NSStringFromClass(vc.class) containsString:obj]) {
                exist = YES;
                *stop = YES;
            }
        }
    }];
    if (exist) return;
    
    if (vc.gk_interactivePopDisabled) {
        [self.view removeGestureRecognizer:self.screenPanGesture];
        [self.view removeGestureRecognizer:self.panGesture];
    }else if (vc.gk_fullScreenPopDisabled) {
        [self.view removeGestureRecognizer:self.panGesture];
        [self.view addGestureRecognizer:self.screenPanGesture];
        if (vc.gk_systemGestureHandleDisabled) {
            [self.screenPanGesture removeTarget:self.systemTarget action:self.systemAction];
        }else {
            [self.screenPanGesture addTarget:self.systemTarget action:self.systemAction];
        }
    }else {
        [self.view removeGestureRecognizer:self.screenPanGesture];
        [self.view addGestureRecognizer:self.panGesture];
        if (vc.gk_systemGestureHandleDisabled) {
            [self.panGesture removeTarget:self.systemTarget action:self.systemAction];
        }else {
            [self.panGesture addTarget:self.systemTarget action:self.systemAction];
        }
    }
}

#pragma mark - getter
static char kAssociatedObjectKey_screenPanGesture;
- (UIScreenEdgePanGestureRecognizer *)screenPanGesture {
    UIScreenEdgePanGestureRecognizer *panGesture = objc_getAssociatedObject(self, &kAssociatedObjectKey_screenPanGesture);
    if (!panGesture) {
        panGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.interactiveTransition action:@selector(panGestureAction:)];
        panGesture.edges = UIRectEdgeLeft;
        panGesture.delegate = self.interactiveTransition;
        
        objc_setAssociatedObject(self, &kAssociatedObjectKey_screenPanGesture, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGesture;
}

static char kAssociatedObjectKey_panGesture;
- (UIPanGestureRecognizer *)panGesture {
    UIPanGestureRecognizer *panGesture = objc_getAssociatedObject(self, &kAssociatedObjectKey_panGesture);
    if (!panGesture) {
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.interactiveTransition action:@selector(panGestureAction:)];
        panGesture.maximumNumberOfTouches = 1;
        panGesture.delegate = self.interactiveTransition;
        
        objc_setAssociatedObject(self, &kAssociatedObjectKey_panGesture, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGesture;
}

static char kAssociatedObjectKey_interactiveTransition;
- (GKNavigationInteractiveTransition *)interactiveTransition {
    GKNavigationInteractiveTransition *transition = objc_getAssociatedObject(self, &kAssociatedObjectKey_interactiveTransition);
    if (!transition) {
        transition = [[GKNavigationInteractiveTransition alloc] init];
        transition.navigationController = self;
        transition.systemTarget = self.systemTarget;
        transition.systemAction = self.systemAction;
        
        objc_setAssociatedObject(self, &kAssociatedObjectKey_interactiveTransition, transition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return transition;
}

- (id)systemTarget {
    NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
    id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
    return internalTarget;
}

- (SEL)systemAction {
    return NSSelectorFromString(@"handleNavigationTransition:");
}

@end
