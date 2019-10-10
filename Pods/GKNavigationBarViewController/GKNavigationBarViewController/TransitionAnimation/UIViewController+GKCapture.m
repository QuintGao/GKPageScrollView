//
//  UIViewController+GKCapture.m
//  GKNavigationBarViewControllerDemo
//
//  Created by QuintGao on 2019/10/9.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "UIViewController+GKCapture.h"
#import <objc/runtime.h>

static const void* GKCaptureImageKey         = @"GKCaptureImage";

@implementation UIViewController (GKCapture)

- (void)setGk_captureImage:(UIImage *)gk_captureImage {
    objc_setAssociatedObject(self, &GKCaptureImageKey, gk_captureImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)gk_captureImage{
    return objc_getAssociatedObject(self, &GKCaptureImageKey);
}

@end
