//
//  UIBarButtonItem+GKCategory.m
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "UIBarButtonItem+GKCategory.h"

@implementation UIBarButtonItem (GKCategory)

+ (instancetype)itemWithTitle:(NSString *)title imageName:(NSString *)imageName target:(id)target action:(SEL)action {
    
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    if (!title || [title isEqualToString:@""]) {
        if (btn.bounds.size.width < 44) {
            CGFloat width = 44 / btn.bounds.size.height * btn.bounds.size.width;
            btn.bounds = CGRectMake(0, 0, width, 44);
        }
        
        if (btn.bounds.size.height > 44) {
            CGFloat height = 44 / btn.bounds.size.width * btn.bounds.size.height;
            btn.bounds = CGRectMake(0, 0, 44, height);
        }
    }
    
    return [[self alloc] initWithCustomView:btn];
}

+ (instancetype)itemWithTitle:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action {
    
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    if (!title || [title isEqualToString:@""]) {
        
        if (btn.bounds.size.width < 44) {
            btn.bounds = CGRectMake(0, 0, 44, 44);
        }
    }
    
    return [[self alloc] initWithCustomView:btn];
}

+ (instancetype)itemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action {
    
    NSString *highLightImageName = [imageName stringByAppendingString:@"_prs"];
    
    return [self itemWithImageName:imageName highLightImageName:highLightImageName target:target action:action];
}

+ (instancetype)itemWithImageName:(NSString *)imageName highLightImageName:(NSString *)highLightImageName target:(id)target action:(SEL)action {
    UIButton *btn = [UIButton new];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highLightImageName] forState:UIControlStateHighlighted];
    [btn sizeToFit];
        
    if (btn.bounds.size.width < 44) {
        CGFloat width = 44 / btn.bounds.size.height * btn.bounds.size.width;
        btn.bounds = CGRectMake(0, 0, width, 44);
    }
    
    if (btn.bounds.size.height > 44) {
        CGFloat height = 44 / btn.bounds.size.width * btn.bounds.size.height;
        btn.bounds = CGRectMake(0, 0, 44, height);
    }
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[self alloc] initWithCustomView:btn];
}

+ (instancetype)itemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn sizeToFit];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[self alloc] initWithCustomView:btn];
}

@end
