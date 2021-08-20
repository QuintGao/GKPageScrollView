//
//  UIImage+GKNavigationBar.m
//  GKNavigationBar
//
//  Created by gaokun on 2019/11/1.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "UIImage+GKNavigationBar.h"
#import "GKNavigationBarDefine.h"

@implementation UIImage (GKNavigationBar)

+ (UIImage *)gk_imageNamed:(NSString *)name {
    if (![GKConfigure gk_libraryBundle]) return [UIImage imageNamed:name];
    UIImage *image = [UIImage imageNamed:name inBundle:[GKConfigure gk_libraryBundle] compatibleWithTraitCollection:nil];
    if (!image) image = [UIImage imageNamed:name];
    return image;
}

+ (UIImage *)gk_imageWithColor:(UIColor *)color {
    return [self gk_imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)gk_imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)gk_changeImage:(UIImage *)image color:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
