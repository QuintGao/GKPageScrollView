//
//  UINavigationItem+GKNavigationBar.m
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/29.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "UINavigationItem+GKNavigationBar.h"
#import "GKNavigationBarDefine.h"
#import "GKNavigationBarConfigure.h"

@implementation UINavigationItem (GKNavigationBar)

// iOS 11之前，通过添加空UIBarButtonItem调整间距
+ (void)load{
    if (@available(iOS 11.0, *)) {} else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSArray <NSString *> *oriSels = @[@"setLeftBarButtonItem:",
                                              @"setLeftBarButtonItem:animated:",
                                              @"setLeftBarButtonItems:",
                                              @"setLeftBarButtonItems:animated:",
                                              @"setRightBarButtonItem:",
                                              @"setRightBarButtonItem:animated:",
                                              @"setRightBarButtonItems:",
                                              @"setRightBarButtonItems:animated:"];
            
            [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
                gk_navigationBar_swizzled_instanceMethod(@"gk", self, oriSel, self);
            }];
        });
    }
}

- (void)gk_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    [self setLeftBarButtonItem:leftBarButtonItem animated:NO];
}

- (void)gk_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem animated:(BOOL)animated {
    if (!GKConfigure.fixNavItemSpaceDisabled && leftBarButtonItem) {//存在按钮且需要调节
        [self setLeftBarButtonItems:@[leftBarButtonItem] animated:animated];
    } else {//不存在按钮,或者不需要调节
        [self setLeftBarButtonItems:nil];
        [self gk_setLeftBarButtonItem:leftBarButtonItem animated:animated];
    }
}

- (void)gk_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    [self setLeftBarButtonItems:leftBarButtonItems animated:NO];
}

- (void)gk_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems animated:(BOOL)animated {
    if (!GKConfigure.fixNavItemSpaceDisabled && leftBarButtonItems.count) {//存在按钮且需要调节
        UIBarButtonItem *firstItem = leftBarButtonItems.firstObject;
        CGFloat width = GKConfigure.gk_navItemLeftSpace - GKConfigure.gk_fixedSpace;
        if (firstItem.width == width) {//已经存在space
            [self gk_setLeftBarButtonItems:leftBarButtonItems animated:animated];
        } else {
            NSMutableArray *items = [NSMutableArray arrayWithArray:leftBarButtonItems];
            [items insertObject:[self fixedSpaceWithWidth:width] atIndex:0];
            [self gk_setLeftBarButtonItems:items animated:animated];
        }
    } else {//不存在按钮,或者不需要调节
        [self gk_setLeftBarButtonItems:leftBarButtonItems animated:animated];
    }
}

- (void)gk_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem{
    [self setRightBarButtonItem:rightBarButtonItem animated:NO];
}

- (void)gk_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem animated:(BOOL)animated {
    if (!GKConfigure.fixNavItemSpaceDisabled && rightBarButtonItem) {//存在按钮且需要调节
        [self setRightBarButtonItems:@[rightBarButtonItem] animated:animated];
    } else {//不存在按钮,或者不需要调节
        [self setRightBarButtonItems:nil];
        [self gk_setRightBarButtonItem:rightBarButtonItem animated:animated];
    }
}

- (void)gk_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems{
    [self setRightBarButtonItems:rightBarButtonItems animated:NO];
}

- (void)gk_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems animated:(BOOL)animated {
    if (!GKConfigure.fixNavItemSpaceDisabled && rightBarButtonItems.count) {//存在按钮且需要调节
        UIBarButtonItem *firstItem = rightBarButtonItems.firstObject;
        CGFloat width = GKConfigure.gk_navItemRightSpace - GKConfigure.gk_fixedSpace;
        if (firstItem.width == width) {//已经存在space
            [self gk_setRightBarButtonItems:rightBarButtonItems animated:animated];
        } else {
            NSMutableArray *items = [NSMutableArray arrayWithArray:rightBarButtonItems];
            [items insertObject:[self fixedSpaceWithWidth:width] atIndex:0];
            [self gk_setRightBarButtonItems:items animated:animated];
        }
    } else {//不存在按钮,或者不需要调节
        [self gk_setRightBarButtonItems:rightBarButtonItems animated:animated];
    }
}

- (UIBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width {
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = width;
    return fixedSpace;
}

@end

@implementation NSObject (GKNavigationBar)

// iOS11之后，通过修改约束跳转导航栏item的间距
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            NSDictionary *oriSels = @{@"_UINavigationBarContentView": @"layoutSubviews",
                                      @"_UINavigationBarContentViewLayout": @"_updateMarginConstraints"};
            [oriSels enumerateKeysAndObjectsUsingBlock:^(NSString *cls, NSString *oriSel, BOOL * _Nonnull stop) {
                gk_navigationBar_swizzled_instanceMethod(@"gk", NSClassFromString(cls), oriSel, NSObject.class);
            }];
        }
    });
}

- (void)gk_layoutSubviews {
    [self gk_layoutSubviews];
    if (GKConfigure.fixNavItemSpaceDisabled) return;
    if (![self isMemberOfClass:NSClassFromString(@"_UINavigationBarContentView")]) return;
    id layout = [self valueForKey:@"_layout"];
    if (!layout) return;
    SEL selector = NSSelectorFromString(@"_updateMarginConstraints");
    IMP imp = [layout methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(layout, selector);
}

- (void)gk__updateMarginConstraints {
    [self gk__updateMarginConstraints];
    if (GKConfigure.fixNavItemSpaceDisabled) return;
    if (![self isMemberOfClass:NSClassFromString(@"_UINavigationBarContentViewLayout")]) return;
    [self gk_adjustLeadingBarConstraints];
    [self gk_adjustTrailingBarConstraints];
}

- (void)gk_adjustLeadingBarConstraints {
    if (GKConfigure.fixNavItemSpaceDisabled) return;
    NSArray<NSLayoutConstraint *> *leadingBarConstraints = [self valueForKey:@"_leadingBarConstraints"];
    if (!leadingBarConstraints) return;
    CGFloat constant = GKConfigure.gk_navItemLeftSpace - GKConfigure.gk_fixedSpace;
    for (NSLayoutConstraint *constraint in leadingBarConstraints) {
        if (constraint.firstAttribute == NSLayoutAttributeLeading && constraint.secondAttribute == NSLayoutAttributeLeading) {
            constraint.constant = constant;
        }
    }
}

- (void)gk_adjustTrailingBarConstraints {
    if (GKConfigure.fixNavItemSpaceDisabled) return;
    NSArray<NSLayoutConstraint *> *trailingBarConstraints = [self valueForKey:@"_trailingBarConstraints"];
    if (!trailingBarConstraints) return;
    CGFloat constant = GKConfigure.gk_fixedSpace - GKConfigure.gk_navItemRightSpace;
    for (NSLayoutConstraint *constraint in trailingBarConstraints) {
        if (constraint.firstAttribute == NSLayoutAttributeTrailing && constraint.secondAttribute == NSLayoutAttributeTrailing) {
            constraint.constant = constant;
        }
    }
}

@end
