//
//  UIImage+GKCategory.m
//  GKNavigationBar
//
//  Created by gaokun on 2019/11/1.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "UIImage+GKCategory.h"

@implementation UIImage (GKCategory)

+ (UIImage *)gk_imageNamed:(NSString *)name {
    NSString *bundleName = [@"GKNavigationBar.bundle" stringByAppendingPathComponent:name];
    NSString *frameWorkName = [@"Frameworks/GKNavigationBar.framework/GKNavigationBar.bundle" stringByAppendingPathComponent:name];

    return [UIImage imageNamed:bundleName] ? : [UIImage imageNamed:frameWorkName];
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
