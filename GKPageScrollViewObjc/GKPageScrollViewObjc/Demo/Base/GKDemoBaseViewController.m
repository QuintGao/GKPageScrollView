//
//  GKDemoBaseViewController.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/27.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDemoBaseViewController.h"

@interface GKDemoBaseViewController ()

@end

@implementation GKDemoBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)prefersStatusBarHidden {
    return self.gk_statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.gk_statusBarStyle;
}

@end
