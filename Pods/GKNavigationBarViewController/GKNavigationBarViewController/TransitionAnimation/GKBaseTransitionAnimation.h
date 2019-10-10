//
//  GKBaseTransitionAnimation.h
//  GKNavigationBarViewController
//
//  Created by gaokun on 2019/1/15.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKNavigationBarConfigure.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKBaseTransitionAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL              scale;

@property (nonatomic, strong) UIView            *shadowView;

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, weak) UIView              *containerView;

@property (nonatomic, weak) UIViewController    *fromViewController;

@property (nonatomic, weak) UIViewController    *toViewController;


/**
 初始化方法

 @param scale 是否需要缩放，默认为NO
 @return 实例对象
 */
+ (instancetype)transitionWithScale:(BOOL)scale;

/**
 动画
 */
- (void)animateTransition;

// 完成动画
- (void)completeTransition;

@end

NS_ASSUME_NONNULL_END
