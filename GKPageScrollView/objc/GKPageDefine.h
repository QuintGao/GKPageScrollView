//
//  GKPageDefine.h
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2020/10/22.
//  Copyright © 2020 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 是否是iPhone X系列
#define GKPAGE_IS_iPhoneX       [GKPageDefine gk_isNotchedScreen]

// 导航栏+状态栏高度
#define GKPAGE_NAVBAR_HEIGHT    (GKPAGE_IS_iPhoneX ? 88.0f : 64.0f)

// 屏幕宽高
#define GKPAGE_SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define GKPAGE_SCREEN_HEIGHT    [UIScreen mainScreen].bounds.size.height

@interface GKPageDefine : NSObject

/// 判断是否是刘海屏
+ (BOOL)gk_isNotchedScreen;

@end

NS_ASSUME_NONNULL_END
