//
//  GKNavigationBarConfigure.m
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKNavigationBarConfigure.h"
#import "GKNavigationBarDefine.h"
#import <sys/utsname.h>

/// 设备宽度，跟横竖屏无关
#define GK_DEVICE_WIDTH MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)

/// 设备高度，跟横竖屏无关
#define GK_DEVICE_HEIGHT MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)

@interface GKNavigationBarConfigure()

@property (nonatomic, assign) CGFloat navItemLeftSpace;
@property (nonatomic, assign) CGFloat navItemRightSpace;

@end

@implementation GKNavigationBarConfigure

+ (instancetype)sharedInstance {
    static GKNavigationBarConfigure *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GKNavigationBarConfigure new];
    });
    return instance;
}

- (void)setupDefaultConfigure {
    self.backgroundColor = [UIColor whiteColor];
    self.lineHidden = NO;
    
    self.titleColor = [UIColor blackColor];
    self.titleFont = [UIFont boldSystemFontOfSize:17.0f];
    
    self.blackBackImage = [UIImage gk_imageNamed:@"btn_back_black"];
    self.whiteBackImage = [UIImage gk_imageNamed:@"btn_back_white"];
    self.backStyle = GKNavigationBarBackStyleBlack;
    self.gk_disableFixSpace = NO;
    self.gk_navItemLeftSpace = 0;
    self.gk_navItemRightSpace = 0;
    self.navItemLeftSpace = 0;
    self.navItemRightSpace = 0;
    
    self.statusBarHidden = NO;
    self.statusBarStyle = UIStatusBarStyleDefault;
}

- (void)setupCustomConfigure:(void (^)(GKNavigationBarConfigure * _Nonnull))block {
    [self setupDefaultConfigure];
    
    !block ? : block(self);
    
    self.navItemLeftSpace  = self.gk_navItemLeftSpace;
    self.navItemRightSpace = self.gk_navItemRightSpace;
}

- (void)updateConfigure:(void (^)(GKNavigationBarConfigure * _Nonnull))block {
    !block ? : block(self);
}

- (UIViewController *)visibleViewController {
    return [[GKNavigationBarConfigure keyWindow].rootViewController gk_findCurrentViewControllerIsRoot:YES];
}

- (CGFloat)gk_fixedSpace {
    // 经测试发现iPhone 12和iPhone 12 Pro，默认导航栏间距是16，需要单独处理
    if ([GKNavigationBarConfigure is61InchScreenAndiPhone12]) return 16;
    return GK_DEVICE_WIDTH > 375.0f ? 20 : 16;
}

- (NSBundle *)gk_libraryBundle {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSURL *bundleURL = [bundle URLForResource:@"GKNavigationBar" withExtension:@"bundle"];
    if (!bundleURL) return nil;
    return [NSBundle bundleWithURL:bundleURL];
}

@end

@implementation GKNavigationBarConfigure (UIDevice)

+ (NSString *)deviceModel {
    if ([self isSimulator]) {
        // Simulator doesn't return the identifier for the actual physical model, but returns it as an environment variable
        // 模拟器不返回物理机器信息，但会通过环境变量的方式返回
        return [NSString stringWithFormat:@"%s", getenv("SIMULATOR_MODEL_IDENTIFIER")];
    }
    
    // See https://www.theiphonewiki.com/wiki/Models for identifiers
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (BOOL)isZoomedMode {
    if (![self isIPhone]) return NO;
    
    CGFloat nativeScale = UIScreen.mainScreen.nativeScale;
    CGFloat scale = UIScreen.mainScreen.scale;
    
    // 对于所有的 Plus 系列 iPhone，屏幕物理像素低于软件层面的渲染像素，不管标准模式还是放大模式，nativeScale 均小于 scale，所以需要特殊处理才能准确区分放大模式
    // https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
    BOOL shouldBeDownsampledDevice = CGSizeEqualToSize(UIScreen.mainScreen.nativeBounds.size, CGSizeMake(1080, 1920));
    if (shouldBeDownsampledDevice) {
        scale /= 1.15;
    }
    
    return nativeScale > scale;
}

static NSInteger isIPad = -1;
+ (BOOL)isIPad {
    if (isIPad < 0) {
        // [[[UIDevice currentDevice] model] isEqualToString:@"iPad"] 无法判断模拟器 iPad，所以改为以下方式
        isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1 : 0;
    }
    return isIPad > 0;
}

static NSInteger isIPod = -1;
+ (BOOL)isIPod {
    if (isIPod < 0) {
        NSString *string = [[UIDevice currentDevice] model];
        isIPod = [string rangeOfString:@"iPod touch"].location != NSNotFound ? 1 : 0;
    }
    return isIPod > 0;
}

static NSInteger isIPhone = -1;
+ (BOOL)isIPhone {
    if (isIPhone < 0) {
        NSString *string = [[UIDevice currentDevice] model];
        isIPhone = [string rangeOfString:@"iPhone"].location != NSNotFound ? 1 : 0;
    }
    return isIPhone > 0;
}

static NSInteger isSimulator = -1;
+ (BOOL)isSimulator {
    if (isSimulator < 0) {
#if TARGET_OS_SIMULATOR
        isSimulator = 1;
#else
        isSimulator = 0;
#endif
    }
    return isSimulator > 0;
}

+ (BOOL)isMac {
#ifdef IOS14_SDK_ALLOWED
    if (@available(iOS 14.0, *)) {
        return [NSProcessInfo processInfo].isiOSAppOnMac || [NSProcessInfo processInfo].isMacCatalystApp;
    }
#endif
    if (@available(iOS 13.0, *)) {
        return [NSProcessInfo processInfo].isMacCatalystApp;
    }
    return NO;
}

static NSInteger isNotchedScreen = -1;
+ (BOOL)isNotchedScreen {
    if (@available(iOS 11, *)) {
        if (isNotchedScreen < 0) {
            if (@available(iOS 12.0, *)) {
                /*
                 检测方式解释/测试要点：
                 1. iOS 11 与 iOS 12 可能行为不同，所以要分别测试。
                 2. 与触发 [QMUIHelper isNotchedScreen] 方法时的进程有关，例如 https://github.com/Tencent/QMUI_iOS/issues/482#issuecomment-456051738 里提到的 [NSObject performSelectorOnMainThread:withObject:waitUntilDone:NO] 就会导致较多的异常。
                 3. iOS 12 下，在非第2点里提到的情况下，iPhone、iPad 均可通过 UIScreen -_peripheryInsets 方法的返回值区分，但如果满足了第2点，则 iPad 无法使用这个方法，这种情况下要依赖第4点。
                 4. iOS 12 下，不管是否满足第2点，不管是什么设备类型，均可以通过一个满屏的 UIWindow 的 rootViewController.view.frame.origin.y 的值来区分，如果是非全面屏，这个值必定为20，如果是全面屏，则可能是24或44等不同的值。但由于创建 UIWindow、UIViewController 等均属于较大消耗，所以只在前面的步骤无法区分的情况下才会使用第4点。
                 5. 对于第4点，经测试与当前设备的方向、是否有勾选 project 里的 General - Hide status bar、当前是否处于来电模式的状态栏这些都没关系。
                 */
                SEL peripheryInsetsSelector = NSSelectorFromString([NSString stringWithFormat:@"_%@%@", @"periphery", @"Insets"]);
                UIEdgeInsets peripheryInsets = UIEdgeInsetsZero;
                [self object:[UIScreen mainScreen] performSelector:peripheryInsetsSelector returnValue:&peripheryInsets];
                if (peripheryInsets.bottom <= 0) {
                    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
                    peripheryInsets = window.safeAreaInsets;
                    if (peripheryInsets.bottom <= 0) {
                        UIViewController *viewController = [UIViewController new];
                        window.rootViewController = viewController;
                        if (CGRectGetMinY(viewController.view.frame) > 20) {
                            peripheryInsets.bottom = 1;
                        }
                    }
                }
                isNotchedScreen = peripheryInsets.bottom > 0 ? 1 : 0;
            } else {
                isNotchedScreen = [self is58InchScreen] ? 1 : 0;
            }
        }
    } else {
        isNotchedScreen = 0;
    }
    return isNotchedScreen > 0;
}

+ (void)object:(NSObject *)object performSelector:(SEL)selector returnValue:(void *)returnValue {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:selector]];
    [invocation setTarget:object];
    [invocation setSelector:selector];
    [invocation invoke];
    if (returnValue) {
        [invocation getReturnValue:returnValue];
    }
}

+ (BOOL)isRegularScreen {
    return [self isIPad] || (![self isZoomedMode] && ([self is67InchScreen] || [self is65InchScreen] || [self is61InchScreen] || [self is55InchScreen]));
}

static NSInteger is67InchScreen = -1;
+ (BOOL)is67InchScreen {
    if (is67InchScreen < 0) {
        is67InchScreen = (GK_DEVICE_WIDTH == self.screenSizeFor67Inch.width && GK_DEVICE_HEIGHT == self.screenSizeFor67Inch.height) ? 1 : 0;
    }
    return is67InchScreen > 0;
}

static NSInteger is65InchScreen = -1;
+ (BOOL)is65InchScreen {
    if (is65InchScreen < 0) {
        // Since iPhone XS Max、iPhone 11 Pro Max and iPhone XR share the same resolution, we have to distinguish them using the model identifiers
        // 由于 iPhone XS Max、iPhone 11 Pro Max 这两款机型和 iPhone XR 的屏幕宽高是一致的，我们通过机器 Identifier 加以区别
        is65InchScreen = (GK_DEVICE_WIDTH == self.screenSizeFor65Inch.width && GK_DEVICE_HEIGHT == self.screenSizeFor65Inch.height && ([[self deviceModel] isEqualToString:@"iPhone11,4"] || [[self deviceModel] isEqualToString:@"iPhone11,6"] || [[self deviceModel] isEqualToString:@"iPhone12,5"])) ? 1 : 0;
    }
    return is65InchScreen > 0;
}

static NSInteger is61InchScreenAndiPhone12 = -1;
+ (BOOL)is61InchScreenAndiPhone12 {
    if (is61InchScreenAndiPhone12 < 0) {
        is61InchScreenAndiPhone12 = (GK_DEVICE_WIDTH == self.screenSizeFor61InchAndiPhone12.width && GK_DEVICE_HEIGHT == self.screenSizeFor61InchAndiPhone12.height && ([[self deviceModel] isEqualToString:@"iPhone13,2"] || [[self deviceModel] isEqualToString:@"iPhone13,3"])) ? 1 : 0;
    }
    return is61InchScreenAndiPhone12 > 0;
}

static NSInteger is61InchScreen = -1;
+ (BOOL)is61InchScreen {
    if (is61InchScreen < 0) {
        is61InchScreen = (GK_DEVICE_WIDTH == self.screenSizeFor61Inch.width && GK_DEVICE_HEIGHT == self.screenSizeFor61Inch.height && ([[self deviceModel] isEqualToString:@"iPhone11,8"] || [[self deviceModel] isEqualToString:@"iPhone12,1"])) ? 1 : 0;
    }
    return is61InchScreen > 0;
}

static NSInteger is58InchScreen = -1;
+ (BOOL)is58InchScreen {
    if (is58InchScreen < 0) {
        // Both iPhone XS and iPhone X share the same actual screen sizes, so no need to compare identifiers
        // iPhone XS 和 iPhone X 的物理尺寸是一致的，因此无需比较机器 Identifier
        is58InchScreen = (GK_DEVICE_WIDTH == self.screenSizeFor58Inch.width && GK_DEVICE_HEIGHT == self.screenSizeFor58Inch.height) ? 1 : 0;
    }
    return is58InchScreen > 0;
}

static NSInteger is55InchScreen = -1;
+ (BOOL)is55InchScreen {
    if (is55InchScreen < 0) {
        is55InchScreen = (GK_DEVICE_WIDTH == self.screenSizeFor55Inch.width && GK_DEVICE_HEIGHT == self.screenSizeFor55Inch.height) ? 1 : 0;
    }
    return is55InchScreen > 0;
}



static NSInteger is54InchScreen = -1;
+ (BOOL)is54InchScreen {
    if (is54InchScreen < 0) {
        // iPhone XS 和 iPhone X 的物理尺寸是一致的，因此无需比较机器 Identifier
        is54InchScreen = (GK_DEVICE_WIDTH == self.screenSizeFor54Inch.width && GK_DEVICE_HEIGHT == self.screenSizeFor54Inch.height) ? 1 : 0;
    }
    return is54InchScreen > 0;
}

static NSInteger is47InchScreen = -1;
+ (BOOL)is47InchScreen {
    if (is47InchScreen < 0) {
        is47InchScreen = (GK_DEVICE_WIDTH == self.screenSizeFor47Inch.width && GK_DEVICE_HEIGHT == self.screenSizeFor47Inch.height) ? 1 : 0;
    }
    return is47InchScreen > 0;
}

static NSInteger is40InchScreen = -1;
+ (BOOL)is40InchScreen {
    if (is40InchScreen < 0) {
        is40InchScreen = (GK_DEVICE_WIDTH == self.screenSizeFor40Inch.width && GK_DEVICE_HEIGHT == self.screenSizeFor40Inch.height) ? 1 : 0;
    }
    return is40InchScreen > 0;
}

static NSInteger is35InchScreen = -1;
+ (BOOL)is35InchScreen {
    if (is35InchScreen < 0) {
        is35InchScreen = (GK_DEVICE_WIDTH == self.screenSizeFor35Inch.width && GK_DEVICE_HEIGHT == self.screenSizeFor35Inch.height) ? 1 : 0;
    }
    return is35InchScreen > 0;
}

+ (CGSize)screenSizeFor67Inch {
    return CGSizeMake(428, 926);
}

+ (CGSize)screenSizeFor65Inch {
    return CGSizeMake(414, 896);
}

+ (CGSize)screenSizeFor61InchAndiPhone12 {
    return CGSizeMake(390, 844);
}

+ (CGSize)screenSizeFor61Inch {
    return CGSizeMake(414, 896);
}

+ (CGSize)screenSizeFor58Inch {
    return CGSizeMake(375, 812);
}

+ (CGSize)screenSizeFor55Inch {
    return CGSizeMake(414, 736);
}

+ (CGSize)screenSizeFor54Inch {
    return CGSizeMake(375, 812);
}

+ (CGSize)screenSizeFor47Inch {
    return CGSizeMake(375, 667);
}

+ (CGSize)screenSizeFor40Inch {
    return CGSizeMake(320, 568);
}

+ (CGSize)screenSizeFor35Inch {
    return CGSizeMake(320, 480);
}

+ (CGFloat)navBarHeight {
    if ([self isIPad]) {
        return GK_SYSTEM_VERSION >= 12.0 ? 50 : 44;
    }
    if (GK_IS_LANDSCAPE) {
        return [self isRegularScreen] ? 44 : 32;
    }else {
        return 44;
    }
}

+ (CGFloat)navBarHeight_nonFullScreen {
    return 56;
}

static CGFloat tabBarHeight = -1;
+ (CGFloat)tabBarHeight {
    if ([self isIPad]) {
        if ([self isNotchedScreen]) {
            tabBarHeight = 65;
        }else {
            if (GK_SYSTEM_VERSION >= 12.0) {
                tabBarHeight = 50;
            }else {
                tabBarHeight = 49;
            }
        }
    }else {
        if (GK_IS_LANDSCAPE) {
            if ([self isRegularScreen]) {
                tabBarHeight = 49;
            }else {
                tabBarHeight = 32;
            }
        }else {
            tabBarHeight = 49;
        }
        tabBarHeight += [self safeAreaInsetsForDeviceWithNotch].bottom;
    }
    return tabBarHeight;
}

+ (UIEdgeInsets)safeAreaInsets {
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [self keyWindow];
        if (!window) {
            // keyWindow还没创建时，通过创建临时window获取安全区域
            window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
            if (window.safeAreaInsets.bottom <= 0) {
                UIViewController *viewController = [UIViewController new];
                window.rootViewController = viewController;
            }
        }
        safeAreaInsets = window.safeAreaInsets;
    }
    return safeAreaInsets;
}

+ (CGRect)statusBarFrame {
    CGRect statusBarFrame = CGRectZero;
    if (@available(iOS 13.0, *)) {
        statusBarFrame = [self keyWindow].windowScene.statusBarManager.statusBarFrame;
    }
    
    if (CGRectEqualToRect(statusBarFrame, CGRectZero)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
#pragma clang diagnostic pop
    }
    
    if (CGRectEqualToRect(statusBarFrame, CGRectZero)) {
        CGFloat statusBarH = [self isNotchedScreen] ? 44 : 20;
        statusBarFrame = CGRectMake(0, 0, GK_SCREEN_WIDTH, statusBarH);
    }
    
    return statusBarFrame;
}

+ (UIWindow *)keyWindow {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in windowScene.windows) {
                    if (window.isKeyWindow) {
                        window = w;
                        break;
                    }
                }
            }
        }
    }
    
    if (!window) {
        window = [UIApplication sharedApplication].windows.firstObject;
        if (!window.isKeyWindow) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
            if (CGRectEqualToRect(keyWindow.bounds, UIScreen.mainScreen.bounds)) {
                window = keyWindow;
            }
        }
    }
    return window;
}

+ (UIEdgeInsets)safeAreaInsetsForDeviceWithNotch {
    if (![self isNotchedScreen]) {
        return UIEdgeInsetsZero;
    }
    
    if ([self isIPad]) {
        return UIEdgeInsetsMake(0, 0, 20, 0);
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return UIEdgeInsetsMake(44, 0, 34, 0);
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIEdgeInsetsMake(34, 0, 44, 0);
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return UIEdgeInsetsMake(0, 44, 21, 44);
            
        case UIInterfaceOrientationUnknown:
        default:
            return UIEdgeInsetsMake(44, 0, 34, 0);
    }
}

@end
