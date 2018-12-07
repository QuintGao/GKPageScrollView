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
        
        gk_swizzled_method(class, @selector(setLeftBarButtonItem:animated:), @selector(gk_setLeftBarButtonItem:animated:));
        
        gk_swizzled_method(class, @selector(setLeftBarButtonItems:animated:), @selector(gk_setLeftBarButtonItems:animated:));

        gk_swizzled_method(class, @selector(setRightBarButtonItem:), @selector(gk_setRightBarButtonItem:));

        gk_swizzled_method(class, @selector(setRightBarButtonItems:), @selector(gk_setRightBarButtonItems:));
        
        gk_swizzled_method(class, @selector(setRightBarButtonItem:animated:), @selector(gk_setRightBarButtonItem:animated:));
        
        gk_swizzled_method(class, @selector(setRightBarButtonItems:animated:), @selector(gk_setRightBarButtonItems:animated:));
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
    if (GKDeviceVersion >= 11.0) {
        [self gk_setLeftBarButtonItems:leftBarButtonItems];
    }else {
        if (leftBarButtonItems.count) {
            UIBarButtonItem *firstItem = leftBarButtonItems.firstObject;
            if (firstItem != nil && firstItem.image == nil && firstItem.title == nil && firstItem.customView == nil) { // 第一个item为space
                [self gk_setLeftBarButtonItems:leftBarButtonItems];
            }else {
                NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:GKConfigure.gk_navItemLeftSpace - 20]]; // 修复iOS11之前的偏移
                
                [items addObjectsFromArray:leftBarButtonItems];
                
                [self gk_setLeftBarButtonItems:items];
            }
        }else {
            [self gk_setLeftBarButtonItems:leftBarButtonItems];
        }
    }
}

- (void)gk_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem animated:(BOOL)animated {
    if (GKDeviceVersion >= 11.0) {
        [self gk_setLeftBarButtonItem:leftBarButtonItem animated:animated];
    }else {
        if (!GKConfigure.gk_disableFixSpace && leftBarButtonItem) {
            [self setLeftBarButtonItems:@[leftBarButtonItem] animated:animated];
        }else {
            [self gk_setLeftBarButtonItem:leftBarButtonItem animated:animated];
        }
    }
}

- (void)gk_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems animated:(BOOL)animated {
    if (GKDeviceVersion >= 11.0) {
        [self gk_setLeftBarButtonItems:leftBarButtonItems animated:animated];
    }else {
        if (leftBarButtonItems.count) {
            UIBarButtonItem *firstItem = leftBarButtonItems.firstObject;
            if (firstItem != nil && firstItem.image == nil && firstItem.title == nil && firstItem.customView == nil) {
                [self gk_setLeftBarButtonItems:leftBarButtonItems animated:animated];
            }else {
                NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:GKConfigure.gk_navItemLeftSpace - 20]];
                [items addObjectsFromArray:leftBarButtonItems];
                [self gk_setLeftBarButtonItems:items animated:animated];
            }
        }else {
            [self gk_setLeftBarButtonItems:leftBarButtonItems animated:animated];
        }
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
    if (GKDeviceVersion >= 11.0) {
        [self gk_setRightBarButtonItems:rightBarButtonItems];
    }else {
        if (rightBarButtonItems.count) {
            UIBarButtonItem *firstItem = rightBarButtonItems.firstObject;
            if (firstItem != nil && firstItem.image == nil && firstItem.title == nil && firstItem.customView == nil) {
                [self gk_setRightBarButtonItems:rightBarButtonItems];
            }else {
                NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:GKConfigure.gk_navItemRightSpace - 20]]; // 可修正iOS11之前的偏移
                [items addObjectsFromArray:rightBarButtonItems];
                [self gk_setRightBarButtonItems:items];
            }
        }else {
            [self gk_setRightBarButtonItems:rightBarButtonItems];
        }
    }
}

- (void)gk_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem animated:(BOOL)animated {
    if (GKDeviceVersion >= 11.0) {
        [self gk_setRightBarButtonItem:rightBarButtonItem animated:animated];
    }else {
        if (!GKConfigure.gk_disableFixSpace && rightBarButtonItem) {
            [self setRightBarButtonItems:@[rightBarButtonItem] animated:animated];
        }else {
            [self gk_setRightBarButtonItem:rightBarButtonItem animated:animated];
        }
    }
}

- (void)gk_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems animated:(BOOL)animated {
    if (GKDeviceVersion >= 11.0) {
        [self gk_setRightBarButtonItems:rightBarButtonItems animated:animated];
    }else {
        if (rightBarButtonItems.count) {
            UIBarButtonItem *firstItem = rightBarButtonItems.firstObject;
            if (firstItem != nil && firstItem.image == nil && firstItem.title == nil && firstItem.customView == nil) {
                [self gk_setRightBarButtonItems:rightBarButtonItems animated:animated];
            }else {
                NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:GKConfigure.gk_navItemRightSpace - 20]]; // 可修正iOS11之前的偏移
                [items addObjectsFromArray:rightBarButtonItems];
                [self gk_setRightBarButtonItems:items animated:animated];
            }
        }else {
            [self gk_setRightBarButtonItems:rightBarButtonItems animated:animated];
        }
    }
}

- (UIBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width {
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = width;
    return fixedSpace;
}

@end
