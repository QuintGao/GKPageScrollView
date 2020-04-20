//
//  GKBaseAnimatedTransition.h
//  GKNavigationBar
//
//  Created by gaokun on 2019/10/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GKNavigationBarConfigure.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKBaseAnimatedTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isScale;

@property (nonatomic, strong) UIView *shadowView;

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, weak) UIViewController *fromViewController;
@property (nonatomic, weak) UIViewController *toViewController;


/// 默认初始化方法
/// @param isScale 是否需要缩放
+ (instancetype)transitionWithScale:(BOOL)isScale;

/// 动画
- (void)animateTransition;

/// 动画完成
- (void)completeTransition;


/// 获取某个view的截图
/// @param view 截图
- (UIImage *)getCaptureWithView:(UIView *)view;

@end

@interface UIViewController (GKCapture)

/// 当前控制器的view的截图
@property (nonatomic, strong) UIImage *gk_captureImage;

@end

NS_ASSUME_NONNULL_END
