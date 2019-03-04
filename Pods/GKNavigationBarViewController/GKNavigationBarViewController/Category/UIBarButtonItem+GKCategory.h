//
//  UIBarButtonItem+GKCategory.h
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (GKCategory)

+ (instancetype)itemWithTitle:(NSString *)title imageName:(NSString *)imageName target:(id)target action:(SEL)action;

+ (instancetype)itemWithTitle:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action;

+ (instancetype)itemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action;

+ (instancetype)itemWithImageName:(NSString *)imageName highLightImageName:(NSString *)highLightImageName target:(id)target action:(SEL)action;

+ (instancetype)itemWithTitle:(NSString *)title target:(id)target action:(SEL)action;

@end
