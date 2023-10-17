//
//  UINavigationController+GKGestureHandle.h
//  GKNavigationBarExample
//
//  Created by gaokun on 2020/10/29.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (GKGestureHandle)<UINavigationBarDelegate>

/// 创建导航控制器并开启手势控制（无缩放）
/// @param rootVC 根控制器
+ (instancetype)rootVC:(UIViewController *)rootVC;

/// 创建导航控制器并开启手势控制
/// @param rootVC 根控制器
/// @param transitionScale 是否缩放
+ (instancetype)rootVC:(UIViewController *)rootVC transitionScale:(BOOL)transitionScale;

/// 导航栏转场时是否缩放，此属性只能在初始化导航栏时有效
@property (nonatomic, assign, readonly) IBInspectable BOOL gk_transitionScale;

/// 是否开启左滑push操作，默认是NO，此时不可禁用控制器的滑动返回手势
@property (nonatomic, assign) IBInspectable BOOL gk_openScrollLeftPush;

/// 是否开启GKNavigationBar的手势处理，默认为NO
/// 只能通过上面的两个初始化方法开启
@property (nonatomic, assign, readonly) IBInspectable BOOL gk_openGestureHandle;

@end

NS_ASSUME_NONNULL_END
