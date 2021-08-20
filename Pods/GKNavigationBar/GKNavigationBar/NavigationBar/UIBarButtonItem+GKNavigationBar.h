//
//  UIBarButtonItem+GKNavigationBar.h
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/28.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (GKNavigationBar)

// 纯文字
+ (instancetype)gk_itemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (instancetype)gk_itemWithTitle:(NSString *)title font:(nullable UIFont *)font target:(id)target action:(SEL)action;
+ (instancetype)gk_itemWithTitle:(NSString *)title color:(nullable UIColor *)color target:(id)target action:(SEL)action;
+ (instancetype)gk_itemWithTitle:(NSString *)title color:(nullable UIColor *)color font:(nullable UIFont *)font target:(id)target action:(SEL)action;

// 纯图片
+ (instancetype)gk_itemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (instancetype)gk_itemWithImage:(UIImage *)image color:(nullable UIColor *)color target:(id)target action:(SEL)action;
+ (instancetype)gk_itemWithImage:(nullable UIImage *)image highLightImage:(nullable UIImage *)highLightImage target:(id)target action:(SEL)action;

// 文字+图片
+ (instancetype)gk_itemWithTitle:(nullable NSString *)title image:(nullable UIImage *)image target:(id)target action:(SEL)action;


/// 快速创建导航栏item
/// @param title 标题
/// @param titleColor 标题颜色
/// @param font 字体
/// @param image 图片
/// @param imageColor 图片颜色
/// @param highLightImage 高亮图片
/// @param target 点击方法实现目标类
/// @param action 点击方法
+ (instancetype)gk_itemWithTitle:(nullable NSString *)title
                      titleColor:(nullable UIColor *)titleColor
                            font:(nullable UIFont *)font
                           image:(nullable UIImage *)image
                      imageColor:(nullable UIColor *)imageColor
                  highLightImage:(nullable UIImage *)highLightImage
                          target:(id)target
                          action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
