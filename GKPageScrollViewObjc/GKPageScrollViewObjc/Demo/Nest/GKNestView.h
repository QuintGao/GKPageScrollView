//
//  GKNestView.h
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/9/30.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPageScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GKNestViewDelegate <NSObject>

- (void)nestViewWillScroll;
- (void)nestViewEndScroll;

@end

@interface GKNestView : UIView<GKPageListViewDelegate>

@property (nonatomic, weak) id<GKNestViewDelegate> delegate;

@property (nonatomic, strong) UIScrollView  *contentScrollView;

@end

NS_ASSUME_NONNULL_END
