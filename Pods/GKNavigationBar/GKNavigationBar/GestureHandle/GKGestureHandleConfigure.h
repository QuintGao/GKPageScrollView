//
//  GKGestureHandleConfigure.h
//  GKNavigationBar
//
//  Created by QuintGao on 2020/10/29.
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

/// 控制x、y轴的缩放程度，默认（0.95，0.97）
@property (nonatomic, assign) CGFloat gk_scaleX;
@property (nonatomic, assign) CGFloat gk_scaleY;

// 需要屏蔽手势处理的VC（默认nil），支持Class或NSString，NSString支持部分匹配如前缀
@property (nonatomic, strong) NSArray *shiledGuestureVCs;

// 全局开启UIScrollView手势处理，默认NO
// 如果设置为YES，可在单个UIScrollView中通过设置gk_openGestureHandle关闭
@property (nonatomic, assign) BOOL gk_openScrollViewGestureHandle;

// 设置push时是否隐藏tabbar，默认NO
@property (nonatomic, assign) BOOL gk_hidesBottomBarWhenPushed;

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

/// 获取某个view的截图
/// @param view view
- (UIImage *)getCaptureWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
