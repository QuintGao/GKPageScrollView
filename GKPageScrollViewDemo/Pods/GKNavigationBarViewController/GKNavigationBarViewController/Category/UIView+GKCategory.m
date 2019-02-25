//
//  UIView+GKCategory.m
//  GKNavigationBarViewControllerDemo
//
//  Created by gaokun on 2019/1/15.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "UIView+GKCategory.h"

@implementation UIView (GKCategory)

- (UIImage *)gk_captureCurrentView {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
