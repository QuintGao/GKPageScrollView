//
//  GKNestScrollView.h
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/10/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKNestScrollView;

@protocol GKNestScrollViewGestureDelegate <NSObject>

@optional

- (BOOL)nestScrollView:(GKNestScrollView *)scrollView gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

- (BOOL)nestScrollView:(GKNestScrollView *)scrollView gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

@end

@interface GKNestScrollView : UIScrollView

@property (nonatomic, weak) id<GKNestScrollViewGestureDelegate> gestureDelegate;

@end

NS_ASSUME_NONNULL_END
