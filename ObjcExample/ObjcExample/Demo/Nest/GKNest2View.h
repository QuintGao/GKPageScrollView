//
//  GKNest2View.h
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/10/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPageScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKNest2View : UIView<JXCategoryListContentViewDelegate>

@property (nonatomic, strong) GKPageScrollView  *pageScrollView;

@property (nonatomic, weak) UIScrollView        *mainScrollView;

@end

NS_ASSUME_NONNULL_END
