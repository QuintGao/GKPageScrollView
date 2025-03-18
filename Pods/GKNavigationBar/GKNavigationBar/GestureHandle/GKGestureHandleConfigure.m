//
//  GKGestureHandleConfigure.m
//  GKNavigationBar
//
//  Created by QuintGao on 2020/10/29.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "GKGestureHandleConfigure.h"

@interface GKGestureHandleConfigure()

@end

@implementation GKGestureHandleConfigure

+ (instancetype)sharedInstance {
    static GKGestureHandleConfigure *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GKGestureHandleConfigure new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupDefaultConfigure];
    }
    return self;
}

- (void)setupDefaultConfigure {
    self.gk_snapMovementSensitivity = 0.7f;
    
    self.gk_pushTransitionCriticalValue = 0.3f;
    self.gk_popTransitionCriticalValue = 0.5f;
    
    self.gk_scaleX = 0.95f;
    self.gk_scaleY = 0.97f;
}

- (void)setupCustomConfigure:(void (^)(GKGestureHandleConfigure * _Nonnull))block {
    [self setupDefaultConfigure];
    
    !block ? : block(self);
}

- (void)updateConfigure:(void (^)(GKGestureHandleConfigure * _Nonnull))block {
    !block ? : block(self);
}

- (BOOL)isVelocityInSensitivity:(CGFloat)velocity {
    return (fabs(velocity) - (1000.0f * (1 - self.gk_snapMovementSensitivity))) > 0;
}

- (UIImage *)getCaptureWithView:(UIView *)view {
    if (!view) return nil;
    if (view.bounds.size.width <= 0 || view.bounds.size.height <= 0) return nil;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, UIScreen.mainScreen.scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
