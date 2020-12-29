//
//  GKNestScrollView.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2019/10/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "GKNestScrollView.h"

@implementation GKNestScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.gestureDelegate respondsToSelector:@selector(nestScrollView:gestureRecognizerShouldBegin:)]) {
        return [self.gestureDelegate nestScrollView:self gestureRecognizerShouldBegin:gestureRecognizer];
    }
    return YES;
}

// 允许多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.gestureDelegate respondsToSelector:@selector(nestScrollView:gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [self.gestureDelegate nestScrollView:self gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    return NO;
}

@end
