//
//  GKTransitionDelegateHandler.h
//  GKNavigationBar
//
//  Created by gaokun on 2019/10/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPushAnimatedTransition.h"
#import "GKPopAnimatedTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKNavigationControllerDelegateHandler : NSObject<UINavigationControllerDelegate>

/// 当前处理的导航控制器
@property (nonatomic, weak) UINavigationController *navigationController;

/// 手势处理
/// @param gesture 手势
- (void)panGestureAction:(UIPanGestureRecognizer *)gesture;

@end

@interface GKGestureRecognizerDelegateHandler : NSObject<UIGestureRecognizerDelegate>

/// 当前处理的导航控制器
@property (nonatomic, weak) UINavigationController *navigationController;

/// 系统返回手势的target
@property (nonatomic, weak) id systemTarget;

/// 自定义返回手势的target
@property (nonatomic, weak) GKNavigationControllerDelegateHandler *customTarget;

@end

NS_ASSUME_NONNULL_END
