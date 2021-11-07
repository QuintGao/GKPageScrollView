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

// 导航栏透明度
@property (nonatomic, assign) CGFloat gk_navBarBackgroundAlpha;

// 导航栏分割线是否隐藏
@property (nonatomic, assign) BOOL    gk_navLineHidden;

// 在非全屏模式下显示
@property (nonatomic, assign) BOOL    gk_nonFullScreen;

@end

NS_ASSUME_NONNULL_END
