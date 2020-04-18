//
//  UINavigationController+GKCategory.m
//  GKNavigationBar
//
//  Created by gaokun on 2019/10/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "UINavigationController+GKCategory.h"
#import "GKNavigationBarConfigure.h"
#import "UIViewController+GKCategory.h"
#import "GKTransitionDelegateHandler.h"

@implementation UINavigationController (GKCategory)

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
        gk_swizzled_instanceMethod(self, @"viewDidLoad", self);
    });
}

- (void)gk_viewDidLoad {
    if (self.gk_openGestureHandle) {
        // 处理特殊控制器
        if ([self isKindOfClass:[UIImagePickerController class]]) return;
        if ([self isKindOfClass:[UIVideoEditorController class]]) return;
        
        // 设置背景色
        self.view.backgroundColor = [UIColor blackColor];
        
        // 设置代理
        self.delegate = self.navigationHandler;
        
        // 注册控制器属性改变通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(propertyChangeNotification:) name:GKViewControllerPropertyChangedNotification object:nil];
    }
    [self gk_viewDidLoad];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GKViewControllerPropertyChangedNotification object:nil];
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
    
    BOOL isRootVC = (vc == self.viewControllers.firstObject);
    
    // 手势处理
    if (vc.gk_interactivePopDisabled) { // 禁止滑动
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.screenPanGesture];
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.panGesture];
    }else if (vc.gk_fullScreenPopDisabled) { // 禁止全屏滑动，支持边缘滑动
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.panGesture];
        
        if (self.gk_transitionScale) {
            self.interactivePopGestureRecognizer.delegate = nil;
            self.interactivePopGestureRecognizer.enabled = NO;
            
            if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.screenPanGesture]) {
                [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.screenPanGesture];
                self.screenPanGesture.delegate = self.gestureHandler;
            }
        }else {
            self.interactivePopGestureRecognizer.delaysTouchesBegan = YES;
            self.interactivePopGestureRecognizer.delegate = self.gestureHandler;
            self.interactivePopGestureRecognizer.enabled = !isRootVC;
        }
    }else { // 支持全屏滑动
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
        [self.interactivePopGestureRecognizer.view removeGestureRecognizer:self.screenPanGesture];
        
        // 给self.interactivePopGestureRecognizer.view 添加全屏滑动手势
        if (!isRootVC && ![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.panGesture]) {
            [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.panGesture];
            self.panGesture.delegate = self.gestureHandler;
        }
        
        // 手势处理
        if (self.gk_transitionScale || self.gk_openScrollLeftPush) {
            [self.panGesture addTarget:self.navigationHandler action:@selector(panGestureAction:)];
        }else {
            SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
            [self.panGesture addTarget:self.systemTarget action:internalAction];
        }
    }
}

#pragma mark - getter
static char kAssociatedObjectKey_screenPanGesture;
- (UIScreenEdgePanGestureRecognizer *)screenPanGesture {
    UIScreenEdgePanGestureRecognizer *panGesture = objc_getAssociatedObject(self, &kAssociatedObjectKey_screenPanGesture);
    if (!panGesture) {
        panGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.navigationHandler action:@selector(panGestureAction:)];
        panGesture.edges = UIRectEdgeLeft;
        
        objc_setAssociatedObject(self, &kAssociatedObjectKey_screenPanGesture, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGesture;
}

static char kAssociatedObjectKey_panGesture;
- (UIPanGestureRecognizer *)panGesture {
    UIPanGestureRecognizer *panGesture = objc_getAssociatedObject(self, &kAssociatedObjectKey_panGesture);
    if (!panGesture) {
        panGesture = [[UIPanGestureRecognizer alloc] init];
        panGesture.maximumNumberOfTouches = 1;
        
        objc_setAssociatedObject(self, &kAssociatedObjectKey_panGesture, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGesture;
}

static char kAssociatedObjectKey_navigationHandler;
- (GKNavigationControllerDelegateHandler *)navigationHandler {
    GKNavigationControllerDelegateHandler *handler = objc_getAssociatedObject(self, &kAssociatedObjectKey_navigationHandler);
    if (!handler) {
        handler = [GKNavigationControllerDelegateHandler new];
        handler.navigationController = self;
    
        objc_setAssociatedObject(self, &kAssociatedObjectKey_navigationHandler, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return handler;
}

static char kAssociatedObjectKey_gestureHandler;
- (GKGestureRecognizerDelegateHandler *)gestureHandler {
    GKGestureRecognizerDelegateHandler *handler = objc_getAssociatedObject(self, &kAssociatedObjectKey_gestureHandler);
    if (!handler) {
        handler = [GKGestureRecognizerDelegateHandler new];
        handler.navigationController = self;
        handler.systemTarget = self.systemTarget;
        handler.customTarget = self.navigationHandler;
        
        objc_setAssociatedObject(self, &kAssociatedObjectKey_gestureHandler, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return handler;
}

- (id)systemTarget {
    NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
    id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
    return internalTarget;
}

@end
