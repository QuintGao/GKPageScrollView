//
//  GKNestView.h
//  GKPageScrollViewObjc
//
//  Created by QuintGao on 2019/9/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPageScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKNestView : UIView<GKPageListViewDelegate>

@property (nonatomic, strong) UIScrollView  *contentScrollView;

@end

NS_ASSUME_NONNULL_END
