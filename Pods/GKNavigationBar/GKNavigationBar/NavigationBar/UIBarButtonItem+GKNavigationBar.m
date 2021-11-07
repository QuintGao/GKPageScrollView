//
//  UIBarButtonItem+GKNavigationBar.m
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/28.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "UIBarButtonItem+GKNavigationBar.h"
#import "UIImage+GKNavigationBar.h"

@implementation UIBarButtonItem (GKNavigationBar)

+ (instancetype)gk_itemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    return [self gk_itemWithTitle:title color:nil target:target action:action];
}

+ (instancetype)gk_itemWithTitle:(NSString *)title font:(UIFont *)font target:(id)target action:(SEL)action {
    return [self gk_itemWithTitle:title color:nil font:font target:target action:action];
}

+ (instancetype)gk_itemWithTitle:(NSString *)title color:(UIColor *)color target:(id)target action:(SEL)action {
    return [self gk_itemWithTitle:title color:color font:nil target:target action:action];
}

+ (instancetype)gk_itemWithTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font target:(id)target action:(SEL)action {
    return [self gk_itemWithTitle:title titleColor:color font:font image:nil imageColor:nil highLightImage:nil target:target action:action];
}

+ (instancetype)gk_itemWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    return [self gk_itemWithImage:image color:nil target:target action:action];
}

+ (instancetype)gk_itemWithImage:(UIImage *)image color:(UIColor *)color target:(id)target action:(SEL)action {
    return [self gk_itemWithTitle:nil titleColor:nil font:nil image:image imageColor:color highLightImage:nil target:target action:action];
}

+ (instancetype)gk_itemWithImage:(UIImage *)image highLightImage:(UIImage *)highLightImage target:(id)target action:(SEL)action {
    return [self gk_itemWithTitle:nil titleColor:nil font:nil image:image imageColor:nil highLightImage:highLightImage target:target action:action];
}

+ (instancetype)gk_itemWithTitle:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action {
    return [self gk_itemWithTitle:title titleColor:nil font:nil image:image imageColor:nil highLightImage:nil target:target action:action];
}

+ (instancetype)gk_itemWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font image:(UIImage *)image imageColor:(UIColor *)imageColor highLightImage:(UIImage *)highLightImage target:(id)target action:(SEL)action {
    UIButton *button = [UIButton new];
    if (title) [button setTitle:title forState:UIControlStateNormal];
    if (titleColor) [button setTitleColor:titleColor forState:UIControlStateNormal];
    if (font) button.titleLabel.font = font;
    if (imageColor) image = [UIImage gk_changeImage:image color:imageColor];
    if (image) [button setImage:image forState:UIControlStateNormal];
    if (highLightImage) [button setImage:highLightImage forState:UIControlStateHighlighted];
    [button sizeToFit];
    if (button.bounds.size.width < 44.0f) button.bounds = CGRectMake(0, 0, 44.0f, 44.0f);
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[self alloc] initWithCustomView:button];
}

@end
