//
//  UINavigationController+GKNavigationBar.h
//  GKNavigationBarExample
//
//  Created by gaokun on 2020/11/23.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (GKNavigationBar)

/// 开启系统导航与GKNavigationBar过渡处理，需要在显示系统导航栏的控制器中调用显示导航栏方法
@property (nonatomic, assign) BOOL gk_openSystemNavHandle;

@end

NS_ASSUME_NONNULL_END
