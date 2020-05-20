# GKNavigationBarSwift

GKNavigationBar的Swift版本 - iOS自定义导航栏，为你的每个控制器添加导航栏

[![Build Status](http://img.shields.io/travis/QuintGao/GKNavigationBarSwift/master.svg?style=flat)](https://travis-ci.org/QuintGao/GKNavigationBarSwift)
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/QuintGao/GKNavigationBarSwift/master/LICENSE)
[![platform](http://img.shields.io/cocoapods/p/GKNavigationBarSwift.svg?style=flat)](http://cocoadocs.org/docsets/GKNavigationBarSwift)
[![languages](https://img.shields.io/badge/language-swift-blue.svg)](#)
[![cocoapods](http://img.shields.io/cocoapods/v/GKNavigationBarSwift.svg?style=flat)](https://cocoapods.org/pods/GKNavigationBarSwift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![support](https://img.shields.io/badge/support-ios%208%2B-orange.svg)](#) 

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
1、如果想要在控制器中动态改变状态栏样式，需要在基类控制器实现下面的方法
```
override var prefersStatusBarHidden: Bool {
    return self.gk_statusBarHidden
}

override var preferredStatusBarStyle: UIStatusBarStyle {
    return self.gk_statusBarStyle
}
```

2、如果切换控制器的时候出现状态栏显示异常（一半黑一半白等）
解决办法：在控制器初始化方法里面设置状态栏样式
```
- (instancetype)init {
    if (self = [super init]) {
        self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}
```
3、Xcode 11.4 在调试的时候会出现不自动调用awake方法
解决办法：APP启动的时候调用GKConfigure.awake()方法
```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    GKConfigure.awake()
}
```

## 使用说明

#### 1、在AppDelegate中添加导航配置

```
GKConfigure.setupDefault()
```

#### 2、创建根导航控制器

```
let nav = UINavigationController(rootVC: GKMainViewController())
nav.gk_openScrollLeftPush = true // 开启左滑push
```

#### 3、设置导航栏属性（调用即创建）

```
self.gk_navBackgroundColor = [UIColor red]
```
更多属性及方法可在demo中查看

## 效果图

![demo](https://github.com/QuintGao/GKNavigationBarSwift/blob/master/imgs/demo.png)

## 版本记录

* 0.0.4 - 2020.04.18  修复设置标题文字颜色及大小可能无效的情况
* 0.0.3 - 2020.04.12  优化对UIScrollView手势的处理
* 0.0.1 - 2020.04.12  初始版本，支持Cocoapods，Carthage，SPM
