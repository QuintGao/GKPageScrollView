//
//  UIViewController+GKNavigationBar.m
//  GKNavigationBarExample
//
//  Created by gaokun on 2020/10/29.
//  Copyright © 2020 QuintGao. All rights reserved.
//

#import "UIViewController+GKNavigationBar.h"
#import "GKNavigationBarDefine.h"

#if __has_include(<GKNavigationBar/GKGestureHandleDefine.h>)
#import <GKNavigationBar/GKGestureHandleDefine.h>
#elif __has_include("GKGestureHandleDefine.h")
#import "GKGestureHandleDefine.h"
#endif

#define HasGestureHandle (__has_include(<GKNavigationBar/GKGestureHandleDefine.h>) || __has_include("GKGestureHandleDefine.h"))

@interface UIViewController (GKNavigationBar)

/// 导航栏是否添加过
@property (nonatomic, assign) BOOL gk_navBarAdded;

@end

@implementation UIViewController (GKNavigationBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray <NSString *> *oriSels = @[@"viewDidLoad",
                                          @"viewWillAppear:",
                                          @"viewDidAppear:",
                                          @"viewWillLayoutSubviews",
                                          @"prefersStatusBarHidden",
                                          @"preferredStatusBarStyle",
                                          @"traitCollectionDidChange:"];
        
        [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
            gk_navigationBar_swizzled_instanceMethod(@"gk", self, oriSel, self);
        }];
    });
}

- (void)gk_viewDidLoad {
    // 设置默认状态
    self.gk_disableFixNavItemSpace = YES;
    
    if ([self shouldHandleNavBar]) {
        // 设置默认导航栏间距
        self.gk_navItemLeftSpace  = GKNavigationBarItemSpace;
        self.gk_navItemRightSpace = GKNavigationBarItemSpace;
    }
    
    // 如果是根控制器，取消返回按钮
    if (self.navigationController && self.navigationController.childViewControllers.count <= 1) {
        if (!self.gk_NavBarInit) return;
        self.gk_navLeftBarButtonItem = nil;
    }
    [self gk_viewDidLoad];
}

- (void)gk_viewWillAppear:(BOOL)animated {
    if ([self isKindOfClass:[UINavigationController class]]) return;
    if ([self isKindOfClass:[UITabBarController class]]) return;
    if ([self isKindOfClass:[UIImagePickerController class]]) return;
    if ([self isKindOfClass:[UIVideoEditorController class]]) return;
    if ([NSStringFromClass(self.class) isEqualToString:@"PUPhotoPickerHostViewController"]) return;
    if (!self.navigationController) return;
    
    if (self.gk_NavBarInit) {
        self.gk_disableFixNavItemSpace = self.gk_disableFixNavItemSpace;
        self.gk_openFixNavItemSpace = self.gk_openFixNavItemSpace;
        // 隐藏系统导航栏
        if (!self.navigationController.gk_openSystemNavHandle) {
            [self hiddenSystemNavBar];
        }
        
        // 将自定义导航栏放置顶层
        if (self.gk_navigationBar && !self.gk_navigationBar.hidden) {
            [self.view bringSubviewToFront:self.gk_navigationBar];
        }
    }else {
        if (self.navigationController && !self.navigationController.isNavigationBarHidden && ![self isNonFullScreen]) {
            self.gk_disableFixNavItemSpace = self.gk_disableFixNavItemSpace;
            self.gk_openFixNavItemSpace = self.gk_openFixNavItemSpace;
        }
        [self restoreSystemNavBar];
    }
    
    // bug fix #76，修改添加了子控制器后调整导航栏间距无效的bug
    // 当创建了gk_navigationBar或者父控制器是导航控制器的时候才去调整导航栏间距
    if ([self shouldFixItemSpace]) {
        // 每次控制器出现的时候重置导航栏间距
        if (self.gk_navItemLeftSpace == GKNavigationBarItemSpace) {
            self.gk_navItemLeftSpace = GKConfigure.navItemLeftSpace;
        }else {
            [GKConfigure updateConfigure:^(GKNavigationBarConfigure * _Nonnull configure) {
                configure.gk_navItemLeftSpace = self.gk_navItemLeftSpace;
            }];
        }
        
        if (self.gk_navItemRightSpace == GKNavigationBarItemSpace) {
            self.gk_navItemRightSpace = GKConfigure.navItemRightSpace;
        }else {
            [GKConfigure updateConfigure:^(GKNavigationBarConfigure * _Nonnull configure) {
                configure.gk_navItemRightSpace = self.gk_navItemRightSpace;
            }];
        }
    }
    
    [self gk_viewWillAppear:animated];
}

- (void)gk_viewDidAppear:(BOOL)animated {
    if (self.gk_NavBarInit) {
        [self hiddenSystemNavBar];
    }else {
        [self restoreSystemNavBar];
    }
    [self gk_viewDidAppear:animated];
}

- (void)gk_viewWillLayoutSubviews {
    if (self.gk_NavBarInit) {
        [self setupNavBarFrame];
    }
    [self gk_viewWillLayoutSubviews];
}

- (BOOL)gk_prefersStatusBarHidden {
    return self.gk_statusBarHidden;
}

- (UIStatusBarStyle)gk_preferredStatusBarStyle {
    return self.gk_statusBarStyle;
}

- (void)gk_traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if ([self isKindOfClass:[UINavigationController class]]) return;
            if ([self isKindOfClass:[UITabBarController class]]) return;
            if (!self.gk_NavBarInit) return;
            
            // 非根控制器重新设置返回按钮
            BOOL isRootVC = self == self.navigationController.childViewControllers.firstObject;
            if (!isRootVC && self.gk_backImage && !self.gk_navLeftBarButtonItem && !self.gk_navLeftBarButtonItems) {
                [self setBackItemImage:self.gk_backImage];
            }
            
            // 重新设置导航栏背景颜色
            if (self.gk_navBackgroundImage) {
                [self setNavBackgroundImage:self.gk_navBackgroundImage];
            }else {
                [self setNavBackgroundColor:self.gk_navBackgroundColor];
            }
            
            // 重新设置分割线颜色
            if (self.gk_navShadowImage) {
                [self setNavShadowImage:self.gk_navShadowImage];
            }else {
                [self setNavShadowColor:self.gk_navShadowColor];
            }
        }
    }
    [self gk_traitCollectionDidChange:previousTraitCollection];
}

#pragma mark - 状态栏
static char kAssociatedObjectKey_statusBarHidden;
- (void)setGk_statusBarHidden:(BOOL)gk_statusBarHidden {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_statusBarHidden, @(gk_statusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)gk_statusBarHidden {
    id hidden = objc_getAssociatedObject(self, &kAssociatedObjectKey_statusBarHidden);
    return (hidden != nil) ? [hidden boolValue] : GKConfigure.statusBarHidden;
}

static char kAssociatedObjectKey_statusBarStyle;
- (void)setGk_statusBarStyle:(UIStatusBarStyle)gk_statusBarStyle {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_statusBarStyle, @(gk_statusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)gk_statusBarStyle {
    id style = objc_getAssociatedObject(self, &kAssociatedObjectKey_statusBarStyle);
    return (style != nil) ? [style integerValue] : GKConfigure.statusBarStyle;
}

#pragma mark - 添加自定义导航栏
static char kAssociatedObjectKey_navigationBar;
- (GKCustomNavigationBar *)gk_navigationBar {
    GKCustomNavigationBar *navigationBar = objc_getAssociatedObject(self, &kAssociatedObjectKey_navigationBar);
    if (!navigationBar) {
        navigationBar = [[GKCustomNavigationBar alloc] init];
        objc_setAssociatedObject(self, &kAssociatedObjectKey_navigationBar, navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        self.gk_NavBarInit = YES;
        self.gk_disableFixNavItemSpace = GKConfigure.disableFixSpace;
        self.gk_openFixNavItemSpace = YES;
        [self setupNavBarAppearance];
        [self setupNavBarFrame];
    }
    if (self.isViewLoaded && !self.gk_navBarAdded) {
        [self.view addSubview:navigationBar];
        self.gk_navBarAdded = YES;
    }
    return navigationBar;
}

static char kAssociatedObjectKey_navigationItem;
- (UINavigationItem *)gk_navigationItem {
    UINavigationItem *navigationItem = objc_getAssociatedObject(self, &kAssociatedObjectKey_navigationItem);
    if (!navigationItem) {
        navigationItem = [[UINavigationItem alloc] init];
        objc_setAssociatedObject(self, &kAssociatedObjectKey_navigationItem, navigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        self.gk_navigationBar.items = @[navigationItem];
    }
    return navigationItem;
}

static char kAssociatedObjectKey_navBarInit;
- (void)setGk_NavBarInit:(BOOL)gk_NavBarInit {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navBarInit, @(gk_NavBarInit), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_NavBarInit {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_navBarInit) boolValue];
}

static char kAssociatedObjectKey_navBarAdded;
- (void)setGk_navBarAdded:(BOOL)gk_navBarAdded {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navBarAdded, @(gk_navBarAdded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_navBarAdded {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_navBarAdded) boolValue];
}

#pragma mark - 常用属性快速设置
static char kAssociatedObjectKey_navBarAlpha;
- (void)setGk_navBarAlpha:(CGFloat)gk_navBarAlpha {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navBarAlpha, @(gk_navBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    self.gk_navigationBar.gk_navBarBackgroundAlpha = gk_navBarAlpha;
}

- (CGFloat)gk_navBarAlpha {
    id obj = objc_getAssociatedObject(self, &kAssociatedObjectKey_navBarAlpha);
    return obj ? [obj floatValue] : 1.0f;
}

static char kAssociatedObjectKey_backImage;
- (void)setGk_backImage:(UIImage *)gk_backImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_backImage, gk_backImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setBackItemImage:gk_backImage];
}

- (UIImage *)gk_backImage {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_backImage);
}

static char kAssociatedObjectKey_darkBackImage;
- (void)setGk_darkBackImage:(UIImage *)gk_darkBackImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_darkBackImage, gk_darkBackImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            [self setBackItemImage:gk_darkBackImage];
        }
    }
}

- (UIImage *)gk_darkBackImage {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_darkBackImage);
}

static char kAssociatedObjectKey_blackBackImage;
- (void)setGk_blackBackImage:(UIImage *)gk_blackBackImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_blackBackImage, gk_blackBackImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setBackItemImage:gk_blackBackImage];
}

- (UIImage *)gk_blackBackImage {
    id object = objc_getAssociatedObject(self, &kAssociatedObjectKey_blackBackImage);
    return object ?: GKConfigure.blackBackImage;
}

static char kAssociatedObjectKey_whiteBackImage;
- (void)setGk_whiteBackImage:(UIImage *)gk_whiteBackImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_whiteBackImage, gk_whiteBackImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setBackItemImage:gk_whiteBackImage];
}

- (UIImage *)gk_whiteBackImage {
    id object = objc_getAssociatedObject(self, &kAssociatedObjectKey_whiteBackImage);
    return object ?: GKConfigure.whiteBackImage;
}

static char kAssociatedObjectKey_backStyle;
- (void)setGk_backStyle:(GKNavigationBarBackStyle)gk_backStyle {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_backStyle, @(gk_backStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setBackItemImage:self.gk_backImage];
}

- (GKNavigationBarBackStyle)gk_backStyle {
    id style = objc_getAssociatedObject(self, &kAssociatedObjectKey_backStyle);
    return (style != nil) ? [style integerValue] : GKNavigationBarBackStyleNone;
}

static char kAssociatedObjectKey_navBackgroundColor;
- (void)setGk_navBackgroundColor:(UIColor *)gk_navBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navBackgroundColor, gk_navBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self setNavBackgroundColor:gk_navBackgroundColor];
}

- (UIColor *)gk_navBackgroundColor {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navBackgroundColor);
}

static char kAssociatedObjectKey_navBackgroundImage;
- (void)setGk_navBackgroundImage:(UIImage *)gk_navBackgroundImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navBackgroundImage, gk_navBackgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNavBackgroundImage:gk_navBackgroundImage];
}

- (UIImage *)gk_navBackgroundImage {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navBackgroundImage);
}

static char kAssociatedObjectKey_darkNavBackgroundImage;
- (void)setGk_darkNavBackgroundImage:(UIImage *)gk_darkNavBackgroundImage{
    objc_setAssociatedObject(self, &kAssociatedObjectKey_darkNavBackgroundImage, gk_darkNavBackgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            [self setNavBackgroundImage:gk_darkNavBackgroundImage];
        }
    }
}

- (UIImage *)gk_darkNavBackgroundImage {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_darkNavBackgroundImage);
}

static char kAssociatedObjectKey_navShadowColor;
- (void)setGk_navShadowColor:(UIColor *)gk_navShadowColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navShadowColor, gk_navShadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNavShadowColor:gk_navShadowColor];
}

- (UIColor *)gk_navShadowColor {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navShadowColor);
}

static char kAssociatedObjectKey_navShadowImage;
- (void)setGk_navShadowImage:(UIImage *)gk_navShadowImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navShadowImage, gk_navShadowImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNavShadowImage:gk_navShadowImage];
}

- (UIImage *)gk_navShadowImage {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navShadowImage);
}

static char kAssociatedObjectKey_darkNavShadowImage;
- (void)setGk_darkNavShadowImage:(UIImage *)gk_darkNavShadowImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_darkNavShadowImage, gk_darkNavShadowImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            [self setNavShadowImage:gk_darkNavShadowImage];
        }
    }
}

- (UIImage *)gk_darkNavShadowImage {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_darkNavShadowImage);
}

static char kAssociatedObjectKey_navLineHidden;
- (void)setGk_navLineHidden:(BOOL)gk_navLineHidden {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navLineHidden, @(gk_navLineHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationBar.gk_navLineHidden = gk_navLineHidden;
    
    if (@available(iOS 11.0, *)) {
        UIImage *shadowImage = nil;
        if (gk_navLineHidden) {
            shadowImage = [UIImage new];
        }else if (self.gk_navShadowImage) {
            shadowImage = self.gk_navShadowImage;
        }else if (self.gk_navShadowColor) {
            shadowImage = [UIImage gk_changeImage:[UIImage gk_imageNamed:@"nav_line"] color:self.gk_navShadowColor];
        }
        [self setNavShadowImage:shadowImage color:nil];
    }
    [self.gk_navigationBar layoutSubviews];
}

- (BOOL)gk_navLineHidden {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_navLineHidden) boolValue];
}

static char kAssociatedObjectKey_navTitle;
- (void)setGk_navTitle:(NSString *)gk_navTitle {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navTitle, gk_navTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationItem.title = gk_navTitle;
}

- (NSString *)gk_navTitle {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navTitle);
}

static char kAssociatedObjectKey_navTitleView;
- (void)setGk_navTitleView:(UIView *)gk_navTitleView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navTitleView, gk_navTitleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationItem.titleView = gk_navTitleView;
}

- (UIView *)gk_navTitleView {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navTitleView);
}

static char kAssociatedObjectKey_navTitleColor;
- (void)setGk_navTitleColor:(UIColor *)gk_navTitleColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navTitleColor, gk_navTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNavTitleColor:gk_navTitleColor];
}

- (UIColor *)gk_navTitleColor {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navTitleColor);
}

static char kAssociatedObjectKey_navTitleFont;
- (void)setGk_navTitleFont:(UIFont *)gk_navTitleFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navTitleFont, gk_navTitleFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNavTitleFont:self.gk_navTitleFont];
}

- (UIFont *)gk_navTitleFont {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navTitleFont);
}

static char kAssociatedObjectKey_navLeftBarButtonItem;
- (void)setGk_navLeftBarButtonItem:(UIBarButtonItem *)gk_navLeftBarButtonItem {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navLeftBarButtonItem, gk_navLeftBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationItem.leftBarButtonItem = gk_navLeftBarButtonItem;
}

- (UIBarButtonItem *)gk_navLeftBarButtonItem {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navLeftBarButtonItem);
}

static char kAssociatedObjectKey_navLeftBarButtonItems;
- (void)setGk_navLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)gk_navLeftBarButtonItems {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navLeftBarButtonItems, gk_navLeftBarButtonItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationItem.leftBarButtonItems = gk_navLeftBarButtonItems;
}

- (NSArray<UIBarButtonItem *> *)gk_navLeftBarButtonItems {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navLeftBarButtonItems);
}

static char kAssociatedObjectKey_navRightBarButtonItem;
- (void)setGk_navRightBarButtonItem:(UIBarButtonItem *)gk_navRightBarButtonItem {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navRightBarButtonItem, gk_navRightBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationItem.rightBarButtonItem = gk_navRightBarButtonItem;
}

- (UIBarButtonItem *)gk_navRightBarButtonItem {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navRightBarButtonItem);
}

static char kAssociatedObjectKey_navRightBarButtonItems;
- (void)setGk_navRightBarButtonItems:(NSArray<UIBarButtonItem *> *)gk_navRightBarButtonItems {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navRightBarButtonItems, gk_navRightBarButtonItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationItem.rightBarButtonItems = gk_navRightBarButtonItems;
}

- (NSArray<UIBarButtonItem *> *)gk_navRightBarButtonItems {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navRightBarButtonItems);
}

static char kAssociatedObjectKey_disableFixNavItemSpace;
- (void)setGk_disableFixNavItemSpace:(BOOL)gk_disableFixNavItemSpace {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_disableFixNavItemSpace, @(gk_disableFixNavItemSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (GKConfigure.gk_disableFixSpace == gk_disableFixNavItemSpace) return;
    [GKConfigure updateConfigure:^(GKNavigationBarConfigure * _Nonnull configure) {
        configure.gk_disableFixSpace = gk_disableFixNavItemSpace;
    }];
}

- (BOOL)gk_disableFixNavItemSpace {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_disableFixNavItemSpace) boolValue];
}

static char kAssociatedObjectKey_openFixNavItemSpace;
- (void)setGk_openFixNavItemSpace:(BOOL)gk_openFixNavItemSpace {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_openFixNavItemSpace, @(gk_openFixNavItemSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (GKConfigure.openSystemFixSpace == gk_openFixNavItemSpace) return;
    [GKConfigure updateConfigure:^(GKNavigationBarConfigure * _Nonnull configure) {
        configure.openSystemFixSpace = gk_openFixNavItemSpace;
    }];
}

- (BOOL)gk_openFixNavItemSpace {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_openFixNavItemSpace) boolValue];
}

static char kAssociatedObjectKey_navItemLeftSpace;
- (void)setGk_navItemLeftSpace:(CGFloat)gk_navItemLeftSpace {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navItemLeftSpace, @(gk_navItemLeftSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (gk_navItemLeftSpace == GKNavigationBarItemSpace) return;
    
    [GKConfigure updateConfigure:^(GKNavigationBarConfigure * _Nonnull configure) {
        configure.gk_navItemLeftSpace = gk_navItemLeftSpace;
    }];
}

- (CGFloat)gk_navItemLeftSpace {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_navItemLeftSpace) floatValue];
}

static char kAssociatedObjectKey_navItemRightSpace;
- (void)setGk_navItemRightSpace:(CGFloat)gk_navItemRightSpace {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navItemRightSpace, @(gk_navItemRightSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (gk_navItemRightSpace == GKNavigationBarItemSpace) return;
    
    [GKConfigure updateConfigure:^(GKNavigationBarConfigure * _Nonnull configure) {
        configure.gk_navItemRightSpace = gk_navItemRightSpace;
    }];
}

- (CGFloat)gk_navItemRightSpace {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_navItemRightSpace) floatValue];
}

#pragma mark - Public Methods
- (void)showNavLine {
    self.gk_navLineHidden = NO;
}

- (void)hideNavLine {
    self.gk_navLineHidden = YES;
}

- (void)refreshNavBarFrame {
    [self setupNavBarFrame];
}

- (void)backItemClick:(id)sender {
#if HasGestureHandle
    BOOL shouldPop = [self navigationShouldPop];
    if ([self respondsToSelector:@selector(navigationShouldPopOnClick)]) {
        shouldPop = [self navigationShouldPopOnClick];
    }
    if (shouldPop) {
        [self.navigationController popViewControllerAnimated:YES];
    }
#else
    [self.navigationController popViewControllerAnimated:YES];
#endif
}

- (UIViewController *)gk_findCurrentViewControllerIsRoot:(BOOL)isRoot {
    if ([self canFindPresentedViewController:self.presentedViewController]) {
        return [self.presentedViewController gk_findCurrentViewControllerIsRoot:NO];
    }
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [[(UITabBarController *)self selectedViewController] gk_findCurrentViewControllerIsRoot:NO];;
    }
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [[(UINavigationController *)self topViewController] gk_findCurrentViewControllerIsRoot:NO];
    }
    if (self.childViewControllers.count > 0) {
        if (self.childViewControllers.count == 1 && isRoot) {
            return [self.childViewControllers.firstObject gk_findCurrentViewControllerIsRoot:NO];
        }else {
            __block UIViewController *currentViewController = self;
            // 从最上层遍历（逆序），查找正在显示的UITabBarController 或 UINavigationController 类型的
            // 是否包含 UITabBarController 或 UINavigationController 类全屏显示的 controller
            [self.childViewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                // 判断obj.view 是否加载，如果尚未加载，调用 obj.view 会触发 viewDidLoad
                if (obj.isViewLoaded) {
                    CGPoint point = [obj.view convertPoint:CGPointZero toView:nil];
                    CGSize windowSize = obj.view.window.bounds.size;
                    // 正在全屏显示
                    BOOL isFullScreenShow = !obj.view.hidden && obj.view.alpha > 0.01 && CGPointEqualToPoint(point, CGPointZero) && CGSizeEqualToSize(obj.view.bounds.size, windowSize);
                    // 判断类型
                    BOOL isStopFindController = [obj isKindOfClass:UINavigationController.class] || [obj isKindOfClass:UITabBarController.class];
                    if (isFullScreenShow && isStopFindController) {
                        currentViewController = [obj gk_findCurrentViewControllerIsRoot:NO];
                        *stop = YES;
                    }
                }
            }];
            return currentViewController;
        }
    }else if ([self respondsToSelector:NSSelectorFromString(@"contentViewController")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UIViewController *tempViewController = [self performSelector:NSSelectorFromString(@"contentViewController")];
#pragma clang diagnostic pop
        if (tempViewController) {
            return [tempViewController gk_findCurrentViewControllerIsRoot:NO];
        }
    }
    return self;
}

- (BOOL)canFindPresentedViewController:(UIViewController *)viewController {
    if (!viewController) {
        return NO;
    }
    if ([viewController isKindOfClass:UIAlertController.class]) {
        return NO;
    }
    if ([@"_UIContextMenuActionsOnlyViewController" isEqualToString:NSStringFromClass(viewController.class)]) {
        return NO;
    }
    return YES;
}

#pragma mark - Private Methods
- (void)setupNavBarAppearance {
    // 设置默认背景
    if (self.gk_navBackgroundImage == nil) {
        self.gk_navBackgroundImage = GKConfigure.backgroundImage;
    }
    
    if (self.gk_darkNavBackgroundImage == nil) {
        self.gk_darkNavBackgroundImage = GKConfigure.darkBackgroundImage;
    }
    
    if (self.gk_navBackgroundColor == nil && self.gk_navBackgroundImage == nil) {
        self.gk_navBackgroundColor = GKConfigure.backgroundColor;
    }
    
    if (self.gk_navShadowImage == nil) {
        self.gk_navShadowImage = GKConfigure.lineImage;
    }
    
    if (self.gk_darkNavShadowImage == nil) {
        self.gk_darkNavShadowImage = GKConfigure.darkLineImage;
    }
    
    // 设置分割线颜色
    if (self.gk_navShadowColor == nil && self.gk_navShadowImage == nil) {
        self.gk_navShadowColor = GKConfigure.lineColor;
    }
    
    // 设置分割线是否隐藏
    if (self.gk_navLineHidden == NO && GKConfigure.lineHidden == YES) {
        self.gk_navLineHidden = GKConfigure.lineHidden;
    }
    
    // 设置默认标题字体
    if (self.gk_navTitleFont == nil) {
        self.gk_navTitleFont = GKConfigure.titleFont;
    }
    
    // 设置默认标题颜色
    if (self.gk_navTitleColor == nil) {
        self.gk_navTitleColor = GKConfigure.titleColor;
    }
    
    // 设置默认返回图片
    if (self.gk_backImage == nil) {
        self.gk_backImage = GKConfigure.backImage;
    }
    
    if (self.gk_darkBackImage == nil) {
        self.gk_darkBackImage = GKConfigure.darkBackImage;
    }
    
    // 设置默认返回样式
    if (self.gk_backStyle == GKNavigationBarBackStyleNone) {
        self.gk_backStyle = GKConfigure.backStyle;
    }
    
    self.gk_navTitle = nil;
}

- (BOOL)isNonFullScreen {
    BOOL isNonFullScreen = NO;
    CGFloat viewW = GK_SCREEN_WIDTH;
    CGFloat viewH = GK_SCREEN_HEIGHT;
    if (self.isViewLoaded) {
        UIViewController *parentVC = self;
        // 找到最上层的父控制器
        while (parentVC.parentViewController) {
            parentVC = parentVC.parentViewController;
        }
        viewW = parentVC.view.frame.size.width;
        viewH = parentVC.view.frame.size.height;
        if (viewW == 0 || viewH == 0) return NO;
        
        // 如果是通过present方式弹出且高度小于屏幕高度，则认为是非全屏
        isNonFullScreen = self.presentingViewController && viewH < GK_SCREEN_HEIGHT;
    }
    return isNonFullScreen;
}

- (void)setupNavBarFrame {
    BOOL isNonFullScreen = [self isNonFullScreen];
    
    CGFloat navBarH = 0.0f;
    if (GK_IS_iPad) { // iPad
        if (isNonFullScreen) {
            navBarH = GK_NAVBAR_HEIGHT_NFS;
            self.gk_navigationBar.gk_nonFullScreen = YES;
        }else {
            navBarH = self.gk_statusBarHidden ? GK_NAVBAR_HEIGHT : GK_STATUSBAR_NAVBAR_HEIGHT;
        }
    }else if (GK_IS_LANDSCAPE) { // 横屏不显示状态栏，没有非全屏模式
        navBarH = GK_NAVBAR_HEIGHT;
    }else {
        if (isNonFullScreen) {
            navBarH = GK_NAVBAR_HEIGHT_NFS;
            self.gk_navigationBar.gk_nonFullScreen = YES;
        }else {
            if (GK_NOTCHED_SCREEN) { // 刘海屏手机
                // iOS 14 pro 状态栏高度与安全区域高度不一致，这里改为使用状态栏高度
                CGFloat topH = GK_STATUSBAR_HEIGHT;
                if (topH == 20) topH = GK_SAFEAREA_TOP;
                navBarH = topH + GK_NAVBAR_HEIGHT;
            }else {
                navBarH = self.gk_statusBarHidden ? GK_NAVBAR_HEIGHT : GK_STATUSBAR_NAVBAR_HEIGHT;
            }
        }
    }
    self.gk_navigationBar.frame = CGRectMake(0, 0, GK_SCREEN_WIDTH, navBarH);
    [self.gk_navigationBar layoutSubviews];
}

- (void)hiddenSystemNavBar {
    if (!self.navigationController.isNavigationBarHidden) {
        self.navigationController.gk_hideNavigationBar = YES;
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (void)restoreSystemNavBar {
    if (GKConfigure.gk_restoreSystemNavBar && [self shouldHandleNavBar]) {
        if (self.navigationController.isNavigationBarHidden && self.navigationController.gk_hideNavigationBar) {
            [self.navigationController setNavigationBarHidden:NO];
        }
    }
}

- (BOOL)shouldHandleNavBar {
    if (self.gk_NavBarInit) return YES;
    if ([self isKindOfClass:UITabBarController.class]) return NO;
    if ([self.parentViewController isKindOfClass:UINavigationController.class]) return YES;
    return NO;
}

- (BOOL)shouldFixItemSpace {
    if (self.gk_NavBarInit) {
        if ([self isKindOfClass:UINavigationController.class]) return NO;
        if ([self isKindOfClass:UITabBarController.class]) return NO;
        if (!self.navigationController) return NO;
        if (![self.parentViewController isKindOfClass:UINavigationController.class]) return NO;
        return YES;
    }
    return self.gk_openFixNavItemSpace;
}

- (void)setBackItemImage:(UIImage *)image {
    if (!self.gk_NavBarInit) return;
    // 根控制器不作处理
    if (self.navigationController && self.navigationController.childViewControllers.count <= 1) {
        self.gk_navLeftBarButtonItem = nil;
        return;
    }
    
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            image = self.gk_darkBackImage;
        }
    }
    
    if (!image) {
        if (self.gk_backStyle != GKNavigationBarBackStyleNone) {
            image = (self.gk_backStyle == GKNavigationBarBackStyleBlack) ? self.gk_blackBackImage : self.gk_whiteBackImage;
        }
    }else {
        if (self.gk_backStyle == GKNavigationBarBackStyleNone) {
            image = nil;
        }
    }
    
    // 没有image
    if (!image) return;
    
    self.gk_navigationItem.leftBarButtonItem = [UIBarButtonItem gk_itemWithImage:image target:self action:@selector(backItemClick:)];
}

- (void)setNavBackgroundImage:(UIImage *)image {
    if (!image) return;
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            image = self.gk_darkNavBackgroundImage;
        }
    }
    
    if (!image) image = self.gk_navBackgroundImage;
    if (!image) return;
    [self setNavBackgroundImage:image color:nil];
}

- (void)setNavBackgroundColor:(UIColor *)color {
    if (!color) return;
    [self setNavBackgroundImage:nil color:color];
}

- (void)setNavShadowImage:(UIImage *)image {
    if (!image) return;
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            image = self.gk_darkNavShadowImage;
        }
    }
    
    if (!image) image = self.gk_navShadowImage;
    if (!image) return;
    [self setNavShadowImage:image color:nil];
}

- (void)setNavShadowColor:(UIColor *)color {
    if (!color) return;
    [self setNavShadowImage:nil color:color];
}

- (void)setNavTitleColor:(UIColor *)color {
    if (!color) return;
    
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    attr[NSForegroundColorAttributeName] = color;
    if (self.gk_navTitleFont) {
        attr[NSFontAttributeName] = self.gk_navTitleFont;
    }
    [self setNavTitleAttributes:attr];
}

- (void)setNavTitleFont:(UIFont *)font {
    if (!font) return;
    
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    if (self.gk_navTitleColor) {
        attr[NSForegroundColorAttributeName] = self.gk_navTitleColor;
    }
    attr[NSFontAttributeName] = font;
    [self setNavTitleAttributes:attr];
}

- (void)setNavBackgroundImage:(UIImage *)image color:(UIColor *)color {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = self.gk_navigationBar.standardAppearance;
        UIColor *shadowColor = appearance.shadowColor;
        UIImage *shadowImage = appearance.shadowImage;
        [appearance configureWithTransparentBackground];
        appearance.backgroundImage = image;
        appearance.backgroundColor = color;
        appearance.shadowColor = shadowColor;
        appearance.shadowImage = shadowImage;
        self.gk_navigationBar.standardAppearance = appearance;
        self.gk_navigationBar.scrollEdgeAppearance = appearance;
    }else {
        if (!image && color) {
            image = [UIImage gk_imageWithColor:color];
        }
        [self.gk_navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)setNavShadowImage:(UIImage *)image color:(UIColor *)color {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = self.gk_navigationBar.standardAppearance;
        UIColor *backgroundColor = appearance.backgroundColor;
        UIImage *backgroundImage = appearance.backgroundImage;
        [appearance configureWithTransparentBackground];
        appearance.shadowImage = image;
        appearance.shadowColor = color;
        appearance.backgroundColor = backgroundColor;
        appearance.backgroundImage = backgroundImage;
        self.gk_navigationBar.standardAppearance = appearance;
        self.gk_navigationBar.scrollEdgeAppearance = appearance;
    }else {
        if (!image && color) {
            image = [UIImage gk_changeImage:[UIImage gk_imageNamed:@"nav_line"] color:color];
        }
        self.gk_navigationBar.shadowImage = image;
    }
}

- (void)setNavTitleAttributes:(NSDictionary<NSAttributedStringKey, id> *)attr {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = self.gk_navigationBar.standardAppearance;
        appearance.titleTextAttributes = attr;
        self.gk_navigationBar.standardAppearance = appearance;
        self.gk_navigationBar.scrollEdgeAppearance = appearance;
    }else {
        self.gk_navigationBar.titleTextAttributes = attr;
    }
}

@end
