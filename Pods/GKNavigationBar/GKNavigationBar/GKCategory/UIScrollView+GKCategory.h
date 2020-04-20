//
//  UIScrollView+GKCategory.h
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (GKCategory)

/// 是否禁用UIScrollView左滑返回手势处理，默认NO
@property (nonatomic, assign) BOOL gk_gestureHandleDisabled;

@end

NS_ASSUME_NONNULL_END
