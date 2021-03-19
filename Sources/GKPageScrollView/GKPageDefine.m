//
//  GKPageDefine.m
//  GKPageScrollViewObjc
//
//  Created by gaokun on 2020/10/22.
//  Copyright © 2020 gaokun. All rights reserved.
//

#import "GKPageDefine.h"

/// 设备宽度，跟横竖屏无关
#define DEVICE_WIDTH MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)

/// 设备高度，跟横竖屏无关
#define DEVICE_HEIGHT MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)

@implementation GKPageDefine

// 来源QMUI
static NSInteger isNotchedScreen = -1;
+ (BOOL)gk_isNotchedScreen {
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

static NSInteger is58InchScreen = -1;
+ (BOOL)is58InchScreen {
    if (is58InchScreen < 0) {
        // iPhone XS 和 iPhone X 的物理尺寸是一致的，因此无需比较机器的Identifier
        is58InchScreen = (DEVICE_WIDTH == self.screenSizeFor58Inch.width && DEVICE_HEIGHT == self.screenSizeFor58Inch.height) ? 1 : 0;
    }
    return is58InchScreen > 0;
}

+ (CGSize)screenSizeFor58Inch {
    return CGSizeMake(375, 812);
}

+ (CGRect)gk_statusBarFrame {
    CGRect statusBarFrame = CGRectZero;
    if (@available(iOS 13.0, *)) {
        statusBarFrame = [GKPageDefine getKeyWindow].windowScene.statusBarManager.statusBarFrame;
    }
    
    if (CGRectEqualToRect(statusBarFrame, CGRectZero)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
#pragma clang diagnostic pop
    }
    
    if (CGRectEqualToRect(statusBarFrame, CGRectZero)) {
        CGFloat statusBarH = [GKPageDefine gk_isNotchedScreen] ? 44 : 20;
        statusBarFrame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, statusBarH);
    }
    
    return statusBarFrame;
}

+ (UIWindow *)getKeyWindow {
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

@end
