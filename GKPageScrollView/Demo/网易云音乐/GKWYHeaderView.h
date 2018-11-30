//
//  GKWYHeaderView.h
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kWYHeaderHeight (kScreenW * 500.0f / 750.0f - kNavBarHeight)

@interface GKWYHeaderView : UIView

@property (nonatomic, strong) UILabel               *nameLabel;

@end

NS_ASSUME_NONNULL_END
