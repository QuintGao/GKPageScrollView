//
//  GKCustomNavigationBar.h
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKCustomNavigationBar : UINavigationBar

// 当前所在的控制器是否隐藏状态栏
@property (nonatomic, assign) BOOL  gk_statusBarHidden;

// 导航栏透明度
@property (nonatomic, assign) CGFloat gk_navBarBackgroundAlpha;

// 导航栏分割线是否隐藏
@property (nonatomic, assign) BOOL      gk_navLineHidden;

@end

NS_ASSUME_NONNULL_END
