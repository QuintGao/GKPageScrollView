## GKNavigationBar
GKNavigationBarViewController的分类实现方式，耦合度底，使用更加便捷

[![Build Status](http://img.shields.io/travis/QuintGao/GKNavigationBar/master.svg?style=flat)](https://travis-ci.org/QuintGao/GKNavigationBar)
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/QuintGao/GKNavigationBar/master/LICENSE)
[![platform](http://img.shields.io/cocoapods/p/GKNavigationBar.svg?style=flat)](http://cocoadocs.org/docsets/GKNavigationBar)
[![languages](https://img.shields.io/badge/language-objective--c-blue.svg)](#)
[![cocoapods](http://img.shields.io/cocoapods/v/GKNavigationBar.svg?style=flat)](https://cocoapods.org/pods/GKNavigationBar)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/QuintGao/GKNavigationBar)
[![support](https://img.shields.io/badge/support-ios%208%2B-orange.svg)](#) 


Swift版本请看这里 → [GKNavigationBarSwift](https://github.com/QuintGao/GKNavigationBarSwift)

## 介绍：(本框架的特性)

* 无侵入性，低耦合性
* 支持自定义导航栏样式（隐藏、透明等）
* 支持控制器开关返回手势
* 支持控制器开关全屏返回手势
* 支持控制器设置导航栏透明度，可实现渐变效果
* 完美解决UITableView，UIScrollView滑动手势冲突
* 可实现push，pop时控制器缩放效果（如：今日头条）
* 可实现左滑push一个控制器的效果（如：网易新闻）

## 重要！！！
感谢使用该库，如果在使用过程中遇到问题可查看issue或提交issue，或者进QQ群1047100313  

#### 1、手势不生效？
1、查看是否使用了+ (instancetype)rootVC:(UIViewController *)rootVC 方法初始化导航控制器  
2、查看是否在控制器中禁用了手势返回self.gk_interactivePopDisabled = YES，self.gk_fullScreenPopDisabled = YES

#### 2、导航栏不显示？
查看是否调用了跟导航栏相关的方法，如self.gk_navTitle = @"GKNavigationBar"  
注意：只有调用跟导航栏相关的方法才会初始化导航栏！

#### 3、切换控制器的时候出现状态栏显示异常（一半黑一半白等）
解决办法：在控制器初始化方法里面设置状态栏样式
```
- (instancetype)init {
    if (self = [super init]) {
        self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}
```
#### 4、Xcode 11.4 在调试的时候会出现状态栏样式改变不了的情况
解决办法：在基类控制器里实现下面两个方法
```
- (BOOL)prefersStatusBarHidden {
    return self.gk_statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.gk_statusBarStyle;
}
```

## 使用说明

### 使用方式
#### 1、手动导入
直接拖入GKNavigationBar文件夹到项目，#import "GKNavigationBar.h"，开始使用

#### 2、pod方式 
Podfile中添加 pod 'GKNavigationBar'，执行pod install 或pod update 安装，
#import <GKNavigationBar/GKNavigationBar.h>，开始使用

##### 模块说明：
* 如果你只需要导航栏模块，可使用pod 'GKNavigationBar/NavigationBar'
* 如果你只需要手势处理模块，可使用pod 'GKNavigationBar/GestureHandle'

#### 3、Carthage方式
Cartfile中添加 github "QuintGao/GKNavigationBar"，执行carthage update --platform iOS，
#import <GKNavigationBar/GKNavigationBar.h>，开始使用

#### 4、SPM方式
在Xcode中点击File->Swift Packages->Add Package Dependency，然后输入https://github.com/QuintGao/GKNavigationBar
下载相应版本的代码，开始使用

### 使用方法
#### 1、在AppDelegate中添加导航配置

```
[GKConfigure setupDefaultConfigure]
```

#### 2、创建根导航控制器

```
UINavigationController *nav = [UINavigationController rootVC:[GKMainViewController new]];
```

#### 3、设置导航栏属性（调用即创建）
```
self.gk_navBackgroundColor = [UIColor red]
```

### 部分功能说明
#### 1、返回按钮点击及返回手势拦截
```
// 重写下面的方法，拦截返回按钮点击
- (void)backItemClick:(id)sender {
    // do something
    
    [super backItemClick:sender];
}
```

```
// 重写下面的方法，拦截返回手势
#pragma mark - GKGesturePopHandlerProtocol
- (BOOL)navigationShouldPopOnGesture {
    // do something
    
    return NO;
}
```

#### 2、与系统导航平滑过渡
```
1、开启系统导航过渡处理 nav.gk_openSystemNavHandle = YES;
2、在控制器中设置gk_popDelegate并实现下面的方法
#pragma mark - GKViewControllerPopDelegate
- (void)viewControllerPopScrollBegan {
    
}

- (void)viewControllerPopScrollUpdate:(float)progress {
    // 由于已经出栈，所以self.navigationController为nil，不能直接获取导航控制器
    UIViewController *vc = [GKConfigure visibleViewController];
    vc.navigationController.navigationBar.alpha = 1 - progress;
}

- (void)viewControllerPopScrollEnded:(BOOL)finished {
    // 由于已经出栈，所以self.navigationController为nil，不能直接获取导航控制器
    UIViewController *vc = [GKConfigure visibleViewController];
    vc.navigationController.navigationBar.alpha = 1;
    vc.navigationController.navigationBarHidden = finished;
}

```

#### 3、屏蔽某些类的导航栏间距调整处理及手势处理
```
// 屏蔽导航栏间距处理
configure.shiledItemSpaceVCs = @[NSClassFromString(@"TZPhotoPickerController"), @"TZAlbumPickerController", @"TZ"];
```

```
// 屏蔽手势处理
configure.shiledGuestureVCs = @[NSClassFromString(@"TZPhotoPickerController"), @"TZAlbumPickerController", @"TZ"];
```

更多属性及方法可在demo中查看

## 版本记录

* 1.4.0 - 2020.12.25 修复边缘滑动返回失效的bug #60
* 1.3.9 - 2020.12.24 手势处理优化，解决可能出现的卡死问题，push、pop手势灵敏度优化
* 1.3.7 - 2020.12.05 手势处理优化，增加禁用系统手势处理属性
* 1.3.6 - 2020.12.02 修复iPhone 12，iPhone 12 Pro机型导航栏间距调整不准确的bug
* 1.3.4 - 2020.12.01 修复可能出现的卡死情况#53
* 1.3.3 - 2020.11.29 手势滑动优化，支持与系统导航平滑衔接、控制器屏蔽支持部分匹配
* 1.3.0 - 2020.10.29 功能模块拆分，可按需pod不同模块
* 1.2.0 - 2020.10.26 优化代码宏定义，增加自定义转场demo
* 1.1.8 - 2020.10.22 适配iPhone 12 系列手机，增加自定义转场动画属性
* 1.1.6 - 2020.09.09 修复左滑push卡住不动的bug
* 1.1.5 - 2020.08.14 修复屏蔽控制器无效的bug
* 1.1.3 - 2020.07.28 修复导航栏标题或颜色不生效的bug
* 1.1.2 - 2020.07.27 修复方法交换可能带来的crash问题
* 1.1.1 - 2020.07.23 修复手势处理对根控制器的影响
* 1.1.0 - 2020.07.22 修复手势处理存在的问题，增加属性可屏蔽某些控制器对手势处理的影响
* 1.0.9 - 2020.07.16 增加gk_backImage，可自定义返回按钮图片
* 1.0.8 - 2020.07.06 增加某些控制器对导航栏间距调整的影响
* 1.0.7 - 2020.06.22 设置导航栏间距不再局限于GKNavigationBar
* 1.0.6 - 2020.06.18 修复设置导航栏间距失效的bug
* 1.0.0 - 2020.01.14 修复设置某个导航栏间距后其他导航栏间距不准确问题
* 0.0.5 - 2020.01.02 修复某些情况下状态栏显示异常问题
* 0.0.4 - 2019.12.22 优化状态栏切换功能
* 0.0.3 - 2019.11.12 修复设置导航栏左右间距无效的问题
* 0.0.2 - 2019.11.04 优化代码，解决只调用gk_navigationItem时导航栏不出现的bug
* 0.0.1 - 2019.11.03 对GKNavigationBarViewController做了修改，使用更方便
