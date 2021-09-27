//
//  GKPageTableView.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/26.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKPageTableView.h"

@implementation GKPageTableView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.gestureDelegate respondsToSelector:@selector(pageTableView:gestureRecognizerShouldBegin:)]) {
        return [self.gestureDelegate pageTableView:self gestureRecognizerShouldBegin:gestureRecognizer];
    }
    
    return YES;
}

// 允许多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.gestureDelegate respondsToSelector:@selector(pageTableView:gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [self.gestureDelegate pageTableView:self gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    
    if (self.horizontalScrollViewList) {
        __block BOOL exist = NO;
        [self.horizontalScrollViewList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([gestureRecognizer.view isEqual:obj]) {
                exist = YES;
                *stop = YES;
            }
            if ([otherGestureRecognizer.view isEqual:obj]) {
                exist = YES;
                *stop = YES;
            }
        }];
        if (exist) return NO;
    }
    
    return [gestureRecognizer.view isKindOfClass:[UIScrollView class]] && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]];
}

@end
