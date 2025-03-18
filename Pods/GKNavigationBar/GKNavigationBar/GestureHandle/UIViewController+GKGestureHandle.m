//
//  UIViewController+GKGestureHandle.m
//  GKNavigationBar
//
//  Created by QuintGao on 2020/10/29.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "UIViewController+GKGestureHandle.h"
#import "GKGestureHandleDefine.h"

NSString *const GKViewControllerPropertyChangedNotification = @"GKViewControllerPropertyChangedNotification";

@interface UIViewController (GKGestureHandlePrivate)<GKViewControllerPushDelegate, GKViewControllerPopDelegate>

@property (nonatomic, assign) BOOL hasPushDelegate;

@property (nonatomic, assign) BOOL hasPopDelegate;

@end

@implementation UIViewController (GKGestureHandlePrivate)

static char kAssociatedObjectKey_hasPushDelegate;
- (BOOL)hasPushDelegate {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_hasPushDelegate) boolValue];
}

- (void)setHasPushDelegate:(BOOL)hasPushDelegate {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_hasPushDelegate, @(hasPushDelegate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static char kAssociatedObjectKey_hasPopDelegate;
- (BOOL)hasPopDelegate {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_hasPopDelegate) boolValue];
}

- (void)setHasPopDelegate:(BOOL)hasPopDelegate {
    return objc_setAssociatedObject(self, &kAssociatedObjectKey_hasPopDelegate, @(hasPopDelegate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIViewController (GKGestureHandle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray <NSString *> *oriSels = @[@"viewWillAppear:",
                                          @"viewDidAppear:",
                                          @"viewDidDisappear:"];
        
        [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
            gk_gestureHandle_swizzled_instanceMethod(@"gkGesture", self, oriSel, self);
        }];
    });
}

- (void)gkGesture_viewWillAppear:(BOOL)animated {
    if (self.hasPushDelegate) {
        self.gk_pushDelegate = self;
        self.hasPushDelegate = NO;
    }
    
    if (self.hasPopDelegate) {
        self.gk_popDelegate = self;
        self.hasPopDelegate = NO;
    }
    [self gkGesture_viewWillAppear:animated];
}

- (void)gkGesture_viewDidAppear:(BOOL)animated {
    [self postPropertyChangeNotification];

    [self gkGesture_viewDidAppear:animated];
}

- (void)gkGesture_viewDidDisappear:(BOOL)animated {
    if (self.gk_pushDelegate == self) {
        self.hasPushDelegate = YES;
    }
    
    if (self.gk_popDelegate == self) {
        self.hasPopDelegate = YES;
    }
    
    // 这两个代理系统不会自动回收，所以要做下处理
    self.gk_pushDelegate = nil;
    self.gk_popDelegate = nil;

    [self gkGesture_viewDidDisappear:animated];
}

static char kAssociatedObjectKey_interactivePopDisabled;
- (void)setGk_interactivePopDisabled:(BOOL)gk_interactivePopDisabled {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_interactivePopDisabled, @(gk_interactivePopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self postPropertyChangeNotification];
}

- (BOOL)gk_interactivePopDisabled {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_interactivePopDisabled) boolValue];
}

static char kAssociatedObjectKey_fullScreenPopDisabled;
- (void)setGk_fullScreenPopDisabled:(BOOL)gk_fullScreenPopDisabled {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_fullScreenPopDisabled, @(gk_fullScreenPopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self postPropertyChangeNotification];
}

- (BOOL)gk_fullScreenPopDisabled {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_fullScreenPopDisabled) boolValue];
}

static char kAssociatedObjectKey_systemGestureHandleDisabled;
- (void)setGk_systemGestureHandleDisabled:(BOOL)gk_systemGestureHandleDisabled {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_systemGestureHandleDisabled, @(gk_systemGestureHandleDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self postPropertyChangeNotification];
}

- (BOOL)gk_systemGestureHandleDisabled {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_systemGestureHandleDisabled) boolValue];
}

static char kAssociatedObjectKey_maxPopDistance;
- (void)setGk_maxPopDistance:(CGFloat)gk_maxPopDistance {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_maxPopDistance, @(gk_maxPopDistance), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (CGFloat)gk_maxPopDistance {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_maxPopDistance) floatValue];
}

static char kAssociatedObjectKey_pushDelegate;
- (void)setGk_pushDelegate:(id<GKViewControllerPushDelegate>)gk_pushDelegate {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_pushDelegate, gk_pushDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<GKViewControllerPushDelegate>)gk_pushDelegate {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_pushDelegate);
}

static char kAssociatedObjectKey_popDelegate;
- (void)setGk_popDelegate:(id<GKViewControllerPopDelegate>)gk_popDelegate {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_popDelegate, gk_popDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<GKViewControllerPopDelegate>)gk_popDelegate {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_popDelegate);
}

static char kAssociatedObjectKey_pushTransition;
- (id<UIViewControllerAnimatedTransitioning>)gk_pushTransition {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_pushTransition);
}

- (void)setGk_pushTransition:(id<UIViewControllerAnimatedTransitioning>)gk_pushTransition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_pushTransition, gk_pushTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static char kAssociatedObjectKey_popTransition;
- (id<UIViewControllerAnimatedTransitioning>)gk_popTransition {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_popTransition);
}

- (void)setGk_popTransition:(id<UIViewControllerAnimatedTransitioning>)gk_popTransition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_popTransition, gk_popTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - GKGesturePopHandlerProtocol
- (BOOL)navigationShouldPop {
    return YES;
}

#pragma mark - Private Methods
// 发送属性改变通知
- (void)postPropertyChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:GKViewControllerPropertyChangedNotification object:@{@"viewController": self}];
}

@end
