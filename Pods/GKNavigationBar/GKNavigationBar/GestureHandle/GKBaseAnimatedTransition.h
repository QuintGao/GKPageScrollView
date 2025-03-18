//
//  GKBaseAnimatedTransition.h
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKBaseAnimatedTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isScale;

@property (nonatomic, strong) UIView *shadowView;

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, weak) UIViewController *fromViewController;

@property (nonatomic, weak) UIViewController *toViewController;

@property (nonatomic, assign) BOOL isHideTabBar;

/// 初始化
/// @param isScale 是否需要缩放
- (instancetype)initWithScale:(BOOL)isScale;

/// 动画时间
- (NSTimeInterval)animationDuration;

/// 动画
- (void)animateTransition;

/// 动画完成
- (void)completeTransition;

@end

@interface UIViewController (GKCapture)

/// 当前控制器的view的截图
@property (nonatomic, strong, nullable) UIImage *gk_captureImage;

@end

NS_ASSUME_NONNULL_END
