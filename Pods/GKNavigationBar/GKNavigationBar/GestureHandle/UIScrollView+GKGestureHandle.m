//
//  UIScrollView+GKGestureHandle.m
//  GKNavigationBar
//
//  Created by QuintGao on 2020/10/29.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "UIScrollView+GKGestureHandle.h"
#import <objc/runtime.h>
#import "GKGestureHandleDefine.h"

@implementation UIScrollView (GKGestureHandle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray <NSString *> *oriSels = @[@"willMoveToSuperview:"];
        
        [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
            gk_gestureHandle_swizzled_instanceMethod(@"gkGesture", self, oriSel, self);
        }];
    });
}

- (void)gkGesture_willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview && GKGestureConfigure.gk_openScrollViewGestureHandle) {
        self.gk_openGestureHandle = YES;
    }
    [self gkGesture_willMoveToSuperview:newSuperview];
}

static char kAssociatedObjectKey_openGestureHandle;
- (void)setGk_openGestureHandle:(BOOL)gk_openGestureHandle {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_openGestureHandle, @(gk_openGestureHandle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_openGestureHandle {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_openGestureHandle) boolValue];
}

#pragma mark - 解决全屏滑动返回时的手势冲突
// 当UIScrollView在水平方向滑动到第一个时，默认是不能全屏滑动返回的，通过下面的方法可实现其滑动返回。

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.gk_openGestureHandle) return YES;

    if ([self panBack:gestureRecognizer]) return NO;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (!self.gk_openGestureHandle) return NO;
    
    if ([self panBack:gestureRecognizer]) return YES;
    
    return NO;
}

- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint point = [self.panGestureRecognizer translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        
        // 设置手势滑动的位置距屏幕左边的区域
        CGFloat locationDistance = [UIScreen mainScreen].bounds.size.width;
        
        if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStatePossible) {
            CGPoint location = [gestureRecognizer locationInView:self];
            if (point.x > 0 && location.x < locationDistance && self.contentOffset.x <= 0) {
                return YES;
            }
        }
    }
    return NO;
}

@end
