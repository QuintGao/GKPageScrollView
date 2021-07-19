//
//  GKSmoothListViewController.h
//  ObjcExample
//
//  Created by gaokun on 2021/4/19.
//

#import "GKDemoBaseViewController.h"
#import <GKPageSmoothView/GKPageSmoothView.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKSmoothListViewControllerDelegate <NSObject>

- (CGFloat)smoothViewHeaderContainerHeight;

@end

@interface GKSmoothListViewController : GKDemoBaseViewController<GKPageSmoothListViewDelegate>

@property (nonatomic, weak) id<GKSmoothListViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
