//
//  UIView+GKCategory.h
//  GKNavigationBarViewControllerDemo
//
//  Created by gaokun on 2019/1/15.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GKCategory)

/**
 获取当前视图的截图
 
 @return 当前视图对应的截图
 */
- (UIImage *)gk_captureCurrentView;

@end

NS_ASSUME_NONNULL_END
