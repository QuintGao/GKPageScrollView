//
//  UINavigationItem+GKCategory.m
//  GKNavigationBarViewControllerTest
//
//  Created by QuintGao on 2017/10/13.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "UINavigationItem+GKCategory.h"
#import "GKCommon.h"
#import "GKNavigationBarConfigure.h"

@implementation UIImagePickerController (GKFixSpace)

+ (void)load {
    // 保证其只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        gk_swizzled_method(class, @selector(viewWillAppear:), @selector(gk_viewWillAppear:));
        
        gk_swizzled_method(class, @selector(viewWillDisappear:), @selector(gk_viewWillDisappear:));
    });
}

- (void)gk_viewWillAppear:(BOOL)animated {
    if (GKDeviceVersion >= 11.0) {
        GKConfigure.gk_disableFixSpace = YES;
    }
    [self gk_viewWillAppear:animated];
}

- (void)gk_viewWillDisappear:(BOOL)animated {
    GKConfigure.gk_disableFixSpace = NO;
    [self gk_viewWillDisappear:animated];
}

@end

@implementation UINavigationItem (GKCategory)

+ (void)load {
    // 保证其只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        gk_swizzled_method(class, @selector(setLeftBarButtonItem:), @selector(gk_setLeftBarButtonItem:));

        gk_swizzled_method(class, @selector(setLeftBarButtonItems:), @selector(gk_setLeftBarButtonItems:));

        gk_swizzled_method(class, @selector(setRightBarButtonItem:), @selector(gk_setRightBarButtonItem:));

        gk_swizzled_method(class, @selector(setRightBarButtonItems:), @selector(gk_setRightBarButtonItems:));
    });
}

- (void)gk_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    if (GKDeviceVersion >= 11.0) {
        [self gk_setLeftBarButtonItem:leftBarButtonItem];
    }else {
        if (!GKConfigure.gk_disableFixSpace && leftBarButtonItem) {
            [self setLeftBarButtonItems:@[leftBarButtonItem]];
        }else {
            [self gk_setLeftBarButtonItem:leftBarButtonItem];
        }
    }
}

- (void)gk_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    if (leftBarButtonItems.count) {
        NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:GKConfigure.gk_navItemLeftSpace - 20]]; // 修复iOS11之前的偏移
        
        [items addObjectsFromArray:leftBarButtonItems];
        
        [self gk_setLeftBarButtonItems:items];
    }else {
        [self gk_setLeftBarButtonItems:leftBarButtonItems];
    }
}

- (void)gk_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    if (GKDeviceVersion >= 11.0) {
        [self gk_setRightBarButtonItem:rightBarButtonItem];
    }else {
        if (!GKConfigure.gk_disableFixSpace && rightBarButtonItem) {
            [self setRightBarButtonItems:@[rightBarButtonItem]];
        }else {
            [self gk_setRightBarButtonItem:rightBarButtonItem];
        }
    }
}

- (void)gk_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems {
    if (rightBarButtonItems.count) {
        NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:GKConfigure.gk_navItemRightSpace - 20]]; // 可修正iOS11之前的偏移
        [items addObjectsFromArray:rightBarButtonItems];
        [self gk_setRightBarButtonItems:items];
    }else {
        [self gk_setLeftBarButtonItems:rightBarButtonItems];
    }
}

- (UIBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width {
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = width;
    return fixedSpace;
}

@end
