//
//  GKWBListViewController.h
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/27.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDemoBaseViewController.h"
#import "GKPageScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKWBListViewController : GKDemoBaseViewController<GKPageListViewDelegate>

@property (nonatomic, assign) BOOL  isCanScroll;

@end

NS_ASSUME_NONNULL_END
