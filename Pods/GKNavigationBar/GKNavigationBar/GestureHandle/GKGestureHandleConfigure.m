//
//  GKGestureHandleConfigure.m
//  GKNavigationBarExample
//
//  Created by gaokun on 2020/10/29.
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
    
    self.gk_translationX = 5.0f;
    self.gk_translationY = 5.0f;
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

@end
