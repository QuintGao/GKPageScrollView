//
//  UIScrollView+GKCategory.h
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/11.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (GKCategory)

// 禁止手势处理，默认为NO，设置为YES表示不对手势冲突进行处理
@property (nonatomic, assign) BOOL  gk_disableGestureHandle;

@end
