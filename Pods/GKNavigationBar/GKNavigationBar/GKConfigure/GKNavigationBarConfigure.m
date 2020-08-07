//
//  GKNavigationBarConfigure.m
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKNavigationBarConfigure.h"

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
    
    self.titleColor = [UIColor blackColor];
    self.titleFont = [UIFont boldSystemFontOfSize:17.0f];
    
    self.backStyle = GKNavigationBarBackStyleBlack;
    self.gk_disableFixSpace = NO;
    self.gk_navItemLeftSpace = 0;
    self.gk_navItemRightSpace = 0;
    self.navItemLeftSpace = 0;
    self.navItemRightSpace = 0;
    
    self.statusBarHidden = NO;
    self.statusBarStyle = UIStatusBarStyleDefault;
    
    self.gk_pushTransitionCriticalValue = 0.3f;
    self.gk_popTransitionCriticalValue = 0.5f;
    
    self.gk_translationX = 5.0f;
    self.gk_translationY = 5.0f;
    self.gk_scaleX = 0.95f;
    self.gk_scaleY = 0.97f;
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

- (void)setupItemSpaceShiledVCs:(NSArray *)vcs {
    self.shiledItemSpaceVCs = vcs;
}

- (void)setupGuestureShiledVCs:(NSArray *)vcs {
    self.shiledGuestureVCs = vcs;
}

- (CGFloat)gk_fixedSpace {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return MIN(screenSize.width, screenSize.height) > 375.0f ? 20.0f : 16.0f;
}

@end
