//
//  AppDelegate.m
//  ObjcExample
//
//  Created by gaokun on 2020/12/29.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GKConfigure setupCustomConfigure:^(GKNavigationBarConfigure *configure) {
        configure.titleColor = [UIColor blackColor];
        configure.titleFont = [UIFont systemFontOfSize:18.0f];
        configure.gk_navItemLeftSpace = 4.0f;
        configure.gk_navItemRightSpace = 4.0f;
        configure.backStyle = GKNavigationBarBackStyleWhite;
    }];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [UINavigationController rootVC:[ViewController new]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
