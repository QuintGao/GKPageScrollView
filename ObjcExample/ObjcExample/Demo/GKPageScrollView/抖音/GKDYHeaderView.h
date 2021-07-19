//
//  GKDYHeaderView.h
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kDYHeaderHeight (kScreenW * 375.0f / 345.0f)
#define kDYBgImgHeight  (kScreenW * 110.0f / 345.0f)

@interface GKDYHeaderView : UIView

- (void)scrollViewDidScroll:(CGFloat)offsetY;

@end

NS_ASSUME_NONNULL_END
