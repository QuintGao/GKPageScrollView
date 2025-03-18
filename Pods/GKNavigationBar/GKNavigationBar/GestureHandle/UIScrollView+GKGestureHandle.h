//
//  UIScrollView+GKGestureHandle.h
//  GKNavigationBar
//
//  Created by QuintGao on 2020/10/29.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (GKGestureHandle)

/// 是否开启UIScrollView左滑返回手势处理，默认NO
@property (nonatomic, assign) BOOL gk_openGestureHandle;

@end

NS_ASSUME_NONNULL_END
