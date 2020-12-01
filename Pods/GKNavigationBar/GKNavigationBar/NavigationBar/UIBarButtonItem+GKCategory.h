//
//  UIBarButtonItem+GKCategory.h
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/28.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (GKCategory)

+ (instancetype)gk_itemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

+ (instancetype)gk_itemWithImage:(UIImage *)image target:(id)target action:(SEL)action;

+ (instancetype)gk_itemWithTitle:(nullable NSString *)title image:(nullable UIImage *)image target:(id)target action:(SEL)action;

+ (instancetype)gk_itemWithImage:(nullable UIImage *)image highLightImage:(nullable UIImage *)highLightImage target:(id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
