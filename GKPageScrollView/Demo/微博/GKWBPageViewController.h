//
//  GKWBPageViewController.h
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/27.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <WMPageController/WMPageController.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKWBPageViewControllDelegate <NSObject>

- (void)pageScrollViewWillBeginScroll;
- (void)pageScrollViewDidEndedScroll;

@end

@interface GKWBPageViewController : WMPageController

@property (nonatomic, weak) id<GKWBPageViewControllDelegate> scrollDelegate;

@property (nonatomic, strong) UIView    *lineView;

@end

NS_ASSUME_NONNULL_END
