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

@property (nonatomic, assign) BOOL    disableFixSpace;
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
    self.disableFixSpace = NO;
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
    
    self.disableFixSpace   = self.gk_disableFixSpace;
    self.navItemLeftSpace  = self.gk_navItemLeftSpace;
    self.navItemRightSpace = self.gk_navItemRightSpace;
}

- (void)updateConfigure:(void (^)(GKNavigationBarConfigure * _Nonnull))block {
    !block ? : block(self);
}

- (UIViewController *)visibleViewController {
    return [[UIDevice keyWindow].rootViewController gk_findCurrentViewControllerIsRoot:YES];
}

- (CGFloat)gk_fixedSpace {
    // 经测试发现iPhone 12 和 12 Pro 到 16 和 16 Pro，默认导航栏间距都是16，所以做下处理
    // 12 / 13 / 14 / 12 Pro / 13 Pro
    if ([UIDevice is61InchScreenAndiPhone12Later]) {
        return 16;
    }
    // 14 Pro / 15 / 16 / 15 Pro
    if ([UIDevice is61InchScreenAndiPhone14ProLater]) {
        return 16;
    }
    // 16 Pro
    if ([UIDevice is63InchScreen]) {
        return 16;
    }
    return GK_DEVICE_WIDTH > 375.0f ? 20 : 16;
}

- (NSBundle *)gk_libraryBundle {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSURL *bundleURL = [bundle URLForResource:@"GKNavigationBar" withExtension:@"bundle"];
    if (!bundleURL) return nil;
    return [NSBundle bundleWithURL:bundleURL];
}

- (BOOL)fixNavItemSpaceDisabled {
    return self.gk_disableFixSpace && !self.openSystemFixSpace;
}

@end

@interface GKPortraitViewController : UIViewController
@end

@implementation GKPortraitViewController

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

@implementation UIDevice (GKNavigationBar)

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

+ (NSString *)deviceName {
    static dispatch_once_t onceToken;
    static NSString *name;
    dispatch_once(&onceToken, ^{
        NSString *model = [self deviceModel];
        if (!model) {
            name = @"Unknown Device";
            return;
        }
        
        NSDictionary *dict = @{
            // See https://gist.github.com/adamawolf/3048717
            @"iPhone1,1" : @"iPhone 1G",
            @"iPhone1,2" : @"iPhone 3G",
            @"iPhone2,1" : @"iPhone 3GS",
            @"iPhone3,1" : @"iPhone 4 (GSM)",
            @"iPhone3,2" : @"iPhone 4",
            @"iPhone3,3" : @"iPhone 4 (CDMA)",
            @"iPhone4,1" : @"iPhone 4S",
            @"iPhone5,1" : @"iPhone 5",
            @"iPhone5,2" : @"iPhone 5",
            @"iPhone5,3" : @"iPhone 5c",
            @"iPhone5,4" : @"iPhone 5c",
            @"iPhone6,1" : @"iPhone 5s",
            @"iPhone6,2" : @"iPhone 5s",
            @"iPhone7,1" : @"iPhone 6 Plus",
            @"iPhone7,2" : @"iPhone 6",
            @"iPhone8,1" : @"iPhone 6s",
            @"iPhone8,2" : @"iPhone 6s Plus",
            @"iPhone8,4" : @"iPhone SE",
            @"iPhone9,1" : @"iPhone 7",
            @"iPhone9,2" : @"iPhone 7 Plus",
            @"iPhone9,3" : @"iPhone 7",
            @"iPhone9,4" : @"iPhone 7 Plus",
            @"iPhone10,1" : @"iPhone 8",
            @"iPhone10,2" : @"iPhone 8 Plus",
            @"iPhone10,3" : @"iPhone X",
            @"iPhone10,4" : @"iPhone 8",
            @"iPhone10,5" : @"iPhone 8 Plus",
            @"iPhone10,6" : @"iPhone X",
            @"iPhone11,2" : @"iPhone XS",
            @"iPhone11,4" : @"iPhone XS Max",
            @"iPhone11,6" : @"iPhone XS Max CN",
            @"iPhone11,8" : @"iPhone XR",
            @"iPhone12,1" : @"iPhone 11",
            @"iPhone12,3" : @"iPhone 11 Pro",
            @"iPhone12,5" : @"iPhone 11 Pro Max",
            @"iPhone12,8" : @"iPhone SE (2nd generation)",
            @"iPhone13,1" : @"iPhone 12 mini",
            @"iPhone13,2" : @"iPhone 12",
            @"iPhone13,3" : @"iPhone 12 Pro",
            @"iPhone13,4" : @"iPhone 12 Pro Max",
            @"iPhone14,4" : @"iPhone 13 mini",
            @"iPhone14,5" : @"iPhone 13",
            @"iPhone14,2" : @"iPhone 13 Pro",
            @"iPhone14,3" : @"iPhone 13 Pro Max",
            @"iPhone14,7" : @"iPhone 14",
            @"iPhone14,8" : @"iPhone 14 Plus",
            @"iPhone15,2" : @"iPhone 14 Pro",
            @"iPhone15,3" : @"iPhone 14 Pro Max",
            @"iPhone15,4" : @"iPhone 15",
            @"iPhone15,5" : @"iPhone 15 Plus",
            @"iPhone16,1" : @"iPhone 15 Pro",
            @"iPhone16,2" : @"iPhone 15 Pro Max",
            @"iPhone17,1" : @"iPhone 16 Pro",
            @"iPhone17,2" : @"iPhone 16 Pro Max",
            @"iPhone17,3" : @"iPhone 16",
            @"iPhone17,4" : @"iPhone 16 Plus",
            
            @"iPad1,1" : @"iPad 1",
            @"iPad2,1" : @"iPad 2 (WiFi)",
            @"iPad2,2" : @"iPad 2 (GSM)",
            @"iPad2,3" : @"iPad 2 (CDMA)",
            @"iPad2,4" : @"iPad 2",
            @"iPad2,5" : @"iPad mini 1",
            @"iPad2,6" : @"iPad mini 1",
            @"iPad2,7" : @"iPad mini 1",
            @"iPad3,1" : @"iPad 3 (WiFi)",
            @"iPad3,2" : @"iPad 3 (4G)",
            @"iPad3,3" : @"iPad 3 (4G)",
            @"iPad3,4" : @"iPad 4",
            @"iPad3,5" : @"iPad 4",
            @"iPad3,6" : @"iPad 4",
            @"iPad4,1" : @"iPad Air",
            @"iPad4,2" : @"iPad Air",
            @"iPad4,3" : @"iPad Air",
            @"iPad4,4" : @"iPad mini 2",
            @"iPad4,5" : @"iPad mini 2",
            @"iPad4,6" : @"iPad mini 2",
            @"iPad4,7" : @"iPad mini 3",
            @"iPad4,8" : @"iPad mini 3",
            @"iPad4,9" : @"iPad mini 3",
            @"iPad5,1" : @"iPad mini 4",
            @"iPad5,2" : @"iPad mini 4",
            @"iPad5,3" : @"iPad Air 2",
            @"iPad5,4" : @"iPad Air 2",
            @"iPad6,3" : @"iPad Pro (9.7 inch)",
            @"iPad6,4" : @"iPad Pro (9.7 inch)",
            @"iPad6,7" : @"iPad Pro (12.9 inch)",
            @"iPad6,8" : @"iPad Pro (12.9 inch)",
            @"iPad6,11": @"iPad 5 (WiFi)",
            @"iPad6,12": @"iPad 5 (Cellular)",
            @"iPad7,1" : @"iPad Pro (12.9 inch, 2nd generation)",
            @"iPad7,2" : @"iPad Pro (12.9 inch, 2nd generation)",
            @"iPad7,3" : @"iPad Pro (10.5 inch)",
            @"iPad7,4" : @"iPad Pro (10.5 inch)",
            @"iPad7,5" : @"iPad 6 (WiFi)",
            @"iPad7,6" : @"iPad 6 (Cellular)",
            @"iPad7,11": @"iPad 7 (WiFi)",
            @"iPad7,12": @"iPad 7 (Cellular)",
            @"iPad8,1" : @"iPad Pro (11 inch)",
            @"iPad8,2" : @"iPad Pro (11 inch)",
            @"iPad8,3" : @"iPad Pro (11 inch)",
            @"iPad8,4" : @"iPad Pro (11 inch)",
            @"iPad8,5" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,6" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,7" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,8" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,9" : @"iPad Pro (11 inch, 2nd generation)",
            @"iPad8,10" : @"iPad Pro (11 inch, 2nd generation)",
            @"iPad8,11" : @"iPad Pro (12.9 inch, 4th generation)",
            @"iPad8,12" : @"iPad Pro (12.9 inch, 4th generation)",
            @"iPad11,1" : @"iPad mini (5th generation)",
            @"iPad11,2" : @"iPad mini (5th generation)",
            @"iPad11,3" : @"iPad Air (3rd generation)",
            @"iPad11,4" : @"iPad Air (3rd generation)",
            @"iPad11,6" : @"iPad (WiFi)",
            @"iPad11,7" : @"iPad (Cellular)",
            @"iPad13,1" : @"iPad Air (4th generation)",
            @"iPad13,2" : @"iPad Air (4th generation)",
            @"iPad13,4" : @"iPad Pro (11 inch, 3rd generation)",
            @"iPad13,5" : @"iPad Pro (11 inch, 3rd generation)",
            @"iPad13,6" : @"iPad Pro (11 inch, 3rd generation)",
            @"iPad13,7" : @"iPad Pro (11 inch, 3rd generation)",
            @"iPad13,8" : @"iPad Pro (12.9 inch, 5th generation)",
            @"iPad13,9" : @"iPad Pro (12.9 inch, 5th generation)",
            @"iPad13,10" : @"iPad Pro (12.9 inch, 5th generation)",
            @"iPad13,11" : @"iPad Pro (12.9 inch, 5th generation)",
            @"iPad14,1" : @"iPad mini (6th generation)",
            @"iPad14,2" : @"iPad mini (6th generation)",
            @"iPad14,3" : @"iPad Pro 11 inch 4th Gen",
            @"iPad14,4" : @"iPad Pro 11 inch 4th Gen",
            @"iPad14,5" : @"iPad Pro 12.9 inch 6th Gen",
            @"iPad14,6" : @"iPad Pro 12.9 inch 6th Gen",
            @"iPad14,8" : @"iPad Air 6th Gen",
            @"iPad14,9" : @"iPad Air 6th Gen",
            @"iPad14,10" : @"iPad Air 7th Gen",
            @"iPad14,11" : @"iPad Air 7th Gen",
            @"iPad16,3" : @"iPad Pro 11 inch 5th Gen",
            @"iPad16,4" : @"iPad Pro 11 inch 5th Gen",
            @"iPad16,5" : @"iPad Pro 12.9 inch 7th Gen",
            @"iPad16,6" : @"iPad Pro 12.9 inch 7th Gen",
            
            @"iPod1,1" : @"iPod touch 1",
            @"iPod2,1" : @"iPod touch 2",
            @"iPod3,1" : @"iPod touch 3",
            @"iPod4,1" : @"iPod touch 4",
            @"iPod5,1" : @"iPod touch 5",
            @"iPod7,1" : @"iPod touch 6",
            @"iPod9,1" : @"iPod touch 7",
            
            @"i386" : @"Simulator x86",
            @"x86_64" : @"Simulator x64",
            
            @"Watch1,1" : @"Apple Watch 38mm",
            @"Watch1,2" : @"Apple Watch 42mm",
            @"Watch2,3" : @"Apple Watch Series 2 38mm",
            @"Watch2,4" : @"Apple Watch Series 2 42mm",
            @"Watch2,6" : @"Apple Watch Series 1 38mm",
            @"Watch2,7" : @"Apple Watch Series 1 42mm",
            @"Watch3,1" : @"Apple Watch Series 3 38mm",
            @"Watch3,2" : @"Apple Watch Series 3 42mm",
            @"Watch3,3" : @"Apple Watch Series 3 38mm (LTE)",
            @"Watch3,4" : @"Apple Watch Series 3 42mm (LTE)",
            @"Watch4,1" : @"Apple Watch Series 4 40mm",
            @"Watch4,2" : @"Apple Watch Series 4 44mm",
            @"Watch4,3" : @"Apple Watch Series 4 40mm (LTE)",
            @"Watch4,4" : @"Apple Watch Series 4 44mm (LTE)",
            @"Watch5,1" : @"Apple Watch Series 5 40mm",
            @"Watch5,2" : @"Apple Watch Series 5 44mm",
            @"Watch5,3" : @"Apple Watch Series 5 40mm (LTE)",
            @"Watch5,4" : @"Apple Watch Series 5 44mm (LTE)",
            @"Watch5,9" : @"Apple Watch SE 40mm",
            @"Watch5,10" : @"Apple Watch SE 44mm",
            @"Watch5,11" : @"Apple Watch SE 40mm",
            @"Watch5,12" : @"Apple Watch SE 44mm",
            @"Watch6,1"  : @"Apple Watch Series 6 40mm",
            @"Watch6,2"  : @"Apple Watch Series 6 44mm",
            @"Watch6,3"  : @"Apple Watch Series 6 40mm",
            @"Watch6,4"  : @"Apple Watch Series 6 44mm",
            @"Watch6,6" : @"Apple Watch Series 7 41mm case (GPS)",
            @"Watch6,7" : @"Apple Watch Series 7 45mm case (GPS)",
            @"Watch6,8" : @"Apple Watch Series 7 41mm case (GPS+Cellular)",
            @"Watch6,9" : @"Apple Watch Series 7 45mm case (GPS+Cellular)",
            @"Watch6,10" : @"Apple Watch SE 40mm case (GPS)",
            @"Watch6,11" : @"Apple Watch SE 44mm case (GPS)",
            @"Watch6,12" : @"Apple Watch SE 40mm case (GPS+Cellular)",
            @"Watch6,13" : @"Apple Watch SE 44mm case (GPS+Cellular)",
            @"Watch6,14" : @"Apple Watch Series 8 41mm case (GPS)",
            @"Watch6,15" : @"Apple Watch Series 8 45mm case (GPS)",
            @"Watch6,16" : @"Apple Watch Series 8 41mm case (GPS+Cellular)",
            @"Watch6,17" : @"Apple Watch Series 8 45mm case (GPS+Cellular)",
            @"Watch6,18" : @"Apple Watch Ultra",
            @"Watch7,1" : @"Apple Watch Series 9 41mm case (GPS)",
            @"Watch7,2" : @"Apple Watch Series 9 45mm case (GPS)",
            @"Watch7,3" : @"Apple Watch Series 9 41mm case (GPS+Cellular)",
            @"Watch7,4" : @"Apple Watch Series 9 45mm case (GPS+Cellular)",
            @"Watch7,5" : @"Apple Watch Ultra 2",
            
            @"AudioAccessory1,1" : @"HomePod",
            @"AudioAccessory1,2" : @"HomePod",
            @"AudioAccessory5,1" : @"HomePod mini",
            
            @"AirPods1,1" : @"AirPods (1st generation)",
            @"AirPods2,1" : @"AirPods (2nd generation)",
            @"iProd8,1"   : @"AirPods Pro",
            
            @"AppleTV2,1" : @"Apple TV 2",
            @"AppleTV3,1" : @"Apple TV 3",
            @"AppleTV3,2" : @"Apple TV 3",
            @"AppleTV5,3" : @"Apple TV 4",
            @"AppleTV6,2" : @"Apple TV 4K",
        };
        name = dict[model];
        if (!name) name = model;
        if ([self isSimulator]) name = [name stringByAppendingString:@" Simulator"];
    });
    return name;
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


//@"iPhone15,2" : @"iPhone 14 Pro",
//@"iPhone15,3" : @"iPhone 14 Pro Max",
//@"iPhone15,4" : @"iPhone 15",
//@"iPhone15,5" : @"iPhone 15 Plus",
//@"iPhone16,1" : @"iPhone 15 Pro",
//@"iPhone16,2" : @"iPhone 15 Pro Max",
//@"iPhone17,1" : @"iPhone 16 Pro",
//@"iPhone17,2" : @"iPhone 16 Pro Max",
//@"iPhone17,3" : @"iPhone 16",
//@"iPhone17,4" : @"iPhone 16 Plus",
static NSInteger isDynamicIslandScreen = -1;
+ (BOOL)isDynamicIslandScreen {
    if (![self isIPhone]) return NO;
    if (isDynamicIslandScreen < 0) {
        NSArray *models = @[@"iPhone 14 Pro", @"iPhone 15", @"iPhone 16"];
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject isKindOfClass:NSString.class] && [[self deviceName] hasPrefix:evaluatedObject];
        }];
        isDynamicIslandScreen = [models filteredArrayUsingPredicate:predicate].count > 0 ? 1 : 0;
    }
    return isDynamicIslandScreen > 0;
}

static NSInteger isNotchedScreen = -1;
+ (BOOL)isNotchedScreen {
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
                    // 使用一个强制竖屏的rootViewController，避免一个仅支持竖屏的App在横屏启动时会受到这里创建的window的影响，导致状态栏、safeAreaInsets等错乱
                    GKPortraitViewController *viewController = [GKPortraitViewController new];
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
    if ([self isDynamicIslandScreen]) {
        return YES;
    }
    return [self isIPad] || (![self isZoomedMode] && ([self is67InchScreenAndiPhone14Later] || [self is67InchScreen] || [self is65InchScreen] || [self is61InchScreen] || [self is55InchScreen]));
}

static NSInteger is69InchScreen = -1;
+ (BOOL)is69InchScreen {
    if (is69InchScreen < 0) {
        is69InchScreen = (GK_DEVICE_WIDTH == self.screenSizeFor69Inch.width && GK_DEVICE_HEIGHT == self.screenSizeFor69Inch.height) ? 1 : 0;
    }
    return is69InchScreen > 0;
}

static NSInteger is67InchScreenAndiPhone14Later = -1;
+ (BOOL)is67InchScreenAndiPhone14Later {
    if (is67InchScreenAndiPhone14Later < 0) {
        is67InchScreenAndiPhone14Later = (GK_DEVICE_WIDTH == self.screenSizeFor67InchAndiPhone14Later.width && GK_DEVICE_HEIGHT == self.screenSizeFor67InchAndiPhone14Later.height) ? 1 : 0;
    }
    return is67InchScreenAndiPhone14Later > 0;
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

static NSInteger is63InchScreen = -1;
+ (BOOL)is63InchScreen {
    if (is63InchScreen < 0) {
        is63InchScreen = (GK_DEVICE_WIDTH == self.screenSizeFor63Inch.width && GK_DEVICE_HEIGHT == self.screenSizeFor63Inch.height) ? 1 : 0;
    }
    return is63InchScreen > 0;
}

static NSInteger is61InchScreenAndiPhone14ProLater = -1;
+ (BOOL)is61InchScreenAndiPhone14ProLater {
    if (is61InchScreenAndiPhone14ProLater < 0) {
        is61InchScreenAndiPhone14ProLater = (GK_DEVICE_WIDTH == self.screenSizeFor61InchAndiPhone14ProLater.width && GK_DEVICE_HEIGHT == self.screenSizeFor61InchAndiPhone14ProLater.height) ? 1 : 0;
    }
    return is61InchScreenAndiPhone14ProLater > 0;
}

static NSInteger is61InchScreenAndiPhone12Later = -1;
+ (BOOL)is61InchScreenAndiPhone12Later {
    if (is61InchScreenAndiPhone12Later < 0) {
        is61InchScreenAndiPhone12Later = (GK_DEVICE_WIDTH == self.screenSizeFor61InchAndiPhone12Later.width && GK_DEVICE_HEIGHT == self.screenSizeFor61InchAndiPhone12Later.height) ? 1 : 0;
    }
    return is61InchScreenAndiPhone12Later > 0;
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

+ (CGSize)screenSizeFor69Inch {
    return CGSizeMake(440, 956);
}

+ (CGSize)screenSizeFor67InchAndiPhone14Later {
    return CGSizeMake(430, 932);
}

+ (CGSize)screenSizeFor67Inch {
    return CGSizeMake(428, 926);
}

+ (CGSize)screenSizeFor65Inch {
    return CGSizeMake(414, 896);
}

+ (CGSize)screenSizeFor63Inch {
    return CGSizeMake(402, 874);
}

+ (CGSize)screenSizeFor61InchAndiPhone14ProLater {
    return CGSizeMake(393, 852);
}

+ (CGSize)screenSizeFor61InchAndiPhone12Later {
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

+ (CGFloat)navBarHeightForPortrait {
    if ([self isIPad]) {
        return GK_SYSTEM_VERSION >= 12.0 ? 50 : 44;
    }
    return 44;
}

+ (CGFloat)navBarHeight_nonFullScreen {
    return 56;
}

+ (CGFloat)navBarFullHeight {
    NSString *deviceModel = [self deviceModel];
    CGFloat pixelOne = 1.0 / UIScreen.mainScreen.scale;
    CGFloat result = [self statusBarFullHeight];
    if (isIPad) {
        result += 50;
    }else if (GK_IS_LANDSCAPE) {
        result += ([self isRegularScreen] ? 44 : 32);
    }else {
        result += 44;
        if ([deviceModel isEqualToString:@"iPhone17,1"] || [deviceModel isEqualToString:@"iPhone17,2"]) { // 16 Pro / 16 Pro Max
            result += (2 + pixelOne); // 56.333
        }else if ([self isDynamicIslandScreen]) {
            result -= pixelOne;  //53.667
        }
    }
    return result;
}

+ (CGFloat)navBarFullHeightForPortrait {
    NSString *deviceModel = [self deviceModel];
    CGFloat pixelOne = 1.0 / UIScreen.mainScreen.scale;
    CGFloat result = [self statusBarHeightForPortrait];
    if (isIPad) {
        result += 50;
    }else {
        result += 44;
        if ([deviceModel isEqualToString:@"iPhone17,1"] || [deviceModel isEqualToString:@"iPhone17,2"]) { // 16 Pro / 16 Pro Max
            result += (2 + pixelOne); // 56.333
        }else if ([self isDynamicIslandScreen]) {
            result -= pixelOne;  //53.667
        }
    }
    return result;
}

+ (CGFloat)statusBarFullHeight {
    if (!UIApplication.sharedApplication.statusBarHidden) {
        return UIApplication.sharedApplication.statusBarFrame.size.height;
    }
    if ([self isIPad]) {
        return [self isNotchedScreen] ? 24 : 20;
    }
    if (![self isNotchedScreen]) {
        return 20;
    }
    if (GK_IS_LANDSCAPE) {
        return 0;
    }
    return [self statusBarHeightForPortrait];
}

+ (CGFloat)statusBarHeightForPortrait {
    if ([self isIPad]) {
        return [self isNotchedScreen] ? 24 : 20;
    }
    if (![self isNotchedScreen]) {
        return 20;
    }
    if ([[self deviceModel] isEqualToString:@"iPhone12,1"]) {
        // iPhone 13 Mini
        return 48;
    }
    if ([self isDynamicIslandScreen]) {
        return 54;
    }
    if ([self is61InchScreenAndiPhone12Later] || [self is67InchScreen]) {
        return 47;
    }
    
    // iPhone XR/11 在iOS14之后状态栏高度为48，之前为44
    if ([self is61InchScreen]) {
        if (@available(iOS 14.0, *)) {
            return 48;
        }else {
            return 44;
        }
    }
    
    double version = UIDevice.currentDevice.systemVersion.doubleValue;
    return ([self is54InchScreen] && version >= 15.0) ? 50 : 44;
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
        statusBarFrame = CGRectMake(0, 0, [self keyWindow].bounds.size.width, statusBarH);
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
    
    if (!window) {
        window = [UIApplication sharedApplication].delegate.window;
    }
    
    return window;
}

+ (UIEdgeInsets)safeAreaInsetsForDeviceWithNotch {
    if (![self isNotchedScreen]) {
        return UIEdgeInsetsZero;
    }
    
    if ([self isIPad]) {
        return UIEdgeInsetsMake(24, 0, 20, 0);
    }
    
    static NSDictionary<NSString *, NSDictionary<NSNumber *, NSValue *> *> *dict;
    if (!dict) {
        dict = @{
            // iPhone 16 Pro
            @"iPhone17,1": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(62, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 62, 21, 62)],
            },
            // iPhone 16 Pro Max
            @"iPhone17,2": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(62, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 62, 21, 62)],
            },
            // iPhone 16
            @"iPhone17,3": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(59, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 59, 21, 59)],
            },
            // iPhone 16 Plus
            @"iPhone17,4": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(59, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 59, 21, 59)],
            },
            // iPhone 15
            @"iPhone15,4": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone15,4-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(48, 0, 28, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 48, 21, 48)],
            },
            // iPhone 15 Plus
            @"iPhone15,5": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone15,5-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(41, 0, 30, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 41, 21, 41)],
            },
            // iPhone 15 Pro
            @"iPhone16,1": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(59, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 59, 21, 59)],
            },
            @"iPhone16,1-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(48, 0, 28, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 48, 21, 48)],
            },
            // iPhone 15 Pro Max
            @"iPhone16,2": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(59, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 59, 21, 59)],
            },
            @"iPhone16,2-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(51, 0, 31, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 51, 21, 51)],
            },
            // iPhone 14
            @"iPhone14,7": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone14,7-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(48, 0, 28, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 48, 21, 48)],
            },
            // iPhone 14 Plus
            @"iPhone14,8": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone14,8-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(41, 0, 30, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 41, 21, 41)],
            },
            // iPhone 14 Pro
            @"iPhone15,2": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(59, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 59, 21, 59)],
            },
            @"iPhone15,2-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(48, 0, 28, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 48, 21, 48)],
            },
            // iPhone 14 Pro Max
            @"iPhone15,3": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(59, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 59, 21, 59)],
            },
            @"iPhone15,3-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(51, 0, 31, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 51, 21, 51)],
            },
            // iPhone 13 mini
            @"iPhone14,4": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(50, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 50, 21, 50)],
            },
            @"iPhone14,4-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(43, 0, 29, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 43, 21, 43)],
            },
            // iPhone 13
            @"iPhone14,5": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone14,5-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(39, 0, 28, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 39, 21, 39)],
            },
            // iPhone 13 Pro
            @"iPhone14,2": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone14,2-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(39, 0, 28, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 39, 21, 39)],
            },
            // iPhone 13 Pro Max
            @"iPhone14,3": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone14,3-Zoom": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(41, 0, 29 + 2.0 / 3.0, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 41, 21, 41)],
            },
            
            
            // iPhone 12 mini
            @"iPhone13,1": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(50, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 50, 21, 50)],
            },
            @"iPhone13,1-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(43, 0, 29, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 43, 21, 43)],
            },
            // iPhone 12
            @"iPhone13,2": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone13,2-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(39, 0, 28, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 39, 21, 39)],
            },
            // iPhone 12 Pro
            @"iPhone13,3": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone13,3-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(39, 0, 28, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 39, 21, 39)],
            },
            // iPhone 12 Pro Max
            @"iPhone13,4": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            @"iPhone13,4-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(41, 0, 29 + 2.0 / 3.0, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 41, 21, 41)],
            },
            
            
            // iPhone 11
            @"iPhone12,1": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(48, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 48, 21, 48)],
            },
            @"iPhone12,1-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(44, 0, 31, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 44, 21, 44)],
            },
            // iPhone 11 Pro Max
            @"iPhone12,5": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(44, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 44, 21, 44)],
            },
            @"iPhone12,5-Zoom": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(40, 0, 30 + 2.0 / 3.0, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 40, 21, 40)],
            },
        };
    }
    
    NSString *deviceKey = [self deviceModel];
    if (!dict[deviceKey]) {
        deviceKey = @"iPhone14,2"; // 默认按最新的 iPhone 13 Pro 处理，因为新出的设备肯定更大概率与上一代设备相似
    }
    if ([self isZoomedMode]) {
        deviceKey = [NSString stringWithFormat:@"%@-Zoom", deviceKey];
    }
    
    NSNumber *orientationKey = nil;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            orientationKey = @(UIInterfaceOrientationLandscapeLeft);
            break;
        default:
            orientationKey = @(UIInterfaceOrientationPortrait);
            break;
    }
    UIEdgeInsets insets = dict[deviceKey][orientationKey].UIEdgeInsetsValue;
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        insets = UIEdgeInsetsMake(insets.bottom, insets.left, insets.top, insets.right);
    }else if (orientation == UIInterfaceOrientationLandscapeRight) {
        insets = UIEdgeInsetsMake(insets.top, insets.right, insets.bottom, insets.left);
    }
    return insets;
}

@end
