//
//  GKGestureHandleConfigure.h
//  GKNavigationBarExample
//
//  Created by gaokun on 2020/10/29.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIViewController+GKGestureHandle.h"
#import "UINavigationController+GKGestureHandle.h"
#import "UIScrollView+GKGestureHandle.h"
#import "GKBaseAnimatedTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKGestureHandleConfigure : NSObject

+ (instancetype)sharedInstance;

/// 快速滑动时的敏感度，默认0.7
@property (nonatomic, assign) CGFloat gk_snapMovementSensitivity;

/// 左滑push过渡临界值，默认0.3，大于此值完成push操作
@property (nonatomic, assign) CGFloat gk_pushTransitionCriticalValue;

/// 右滑pop过渡临界值，默认0.5，大于此值完成pop操作
@property (nonatomic, assign) CGFloat gk_popTransitionCriticalValue;

// 以下属性需要设置导航栏转场缩放为YES
/// 手机系统大于11.0，使用下面的值控制x、y轴的位移距离，默认（5，5）
@property (nonatomic, assign) CGFloat gk_translationX;
@property (nonatomic, assign) CGFloat gk_translationY;
/// 手机系统小于11.0，使用下面的值控制x、y周的缩放程度，默认（0.95，0.97）
@property (nonatomic, assign) CGFloat gk_scaleX;
@property (nonatomic, assign) CGFloat gk_scaleY;

// 需要屏蔽手势处理的VC（默认nil），支持Class或NSString，，NSString支持部分匹配如前缀
@property (nonatomic, strong) NSArray *shiledGuestureVCs;

/// 设置默认配置
- (void)setupDefaultConfigure;

/// 设置自定义配置，此方法只需调用一次
/// @param block 配置回调
- (void)setupCustomConfigure:(void (^)(GKGestureHandleConfigure *configure))block;

/// 更新配置
/// @param block 配置回调
- (void)updateConfigure:(void (^)(GKGestureHandleConfigure *configure))block;

// 内部方法
- (BOOL)isVelocityInSensitivity:(CGFloat)velocity;

@end

NS_ASSUME_NONNULL_END
