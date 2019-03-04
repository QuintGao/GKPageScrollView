//
//  GKTestListView.h
//  GKPageScrollViewDemo
//
//  Created by gaokun on 2018/12/6.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPageScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GKTestListViewDelegate <NSObject>

- (void)bottomHide;
- (void)bottomShow;

- (void)listLoadData;

@end

@interface GKTestListView : UIView<GKPageListViewDelegate>

@property (nonatomic, weak) id<GKTestListViewDelegate> delegate;

- (void)setCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
