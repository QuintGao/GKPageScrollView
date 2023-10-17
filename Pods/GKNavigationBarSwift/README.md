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
感谢使用该库，如果在使用过程中遇到问题可查看issue或提交issue，或者进QQ群1047100313

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
// 最好在初始化方法中设置gk_statusBarStyle，否则可能导致状态栏切换闪动问题
override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    self.gk_statusBarStyle = .lightContent
}
```
3、Xcode 11.4 在调试的时候会出现不自动调用awake方法
解决办法：APP启动的时候调用GKConfigure.awake()方法，1.4.6版本修改了加载时机可不用手动调用此方法了
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

![demo](https://github.com/QuintGao/GKExampleImages/blob/master/GKNavigationBar/demo.png)

## 版本记录

* 1.6.5 - 2023.10.13 适配iOS17，修复非全屏bug
* 1.6.4 - 2023.07.21 消除警告，SPM优化
* 1.6.1 - 2023.07.17 修复导航栏间距调整可能失效问题
* 1.6.0 - 2023.06.28 导航栏宽度适配Mac
* 1.5.9 - 2023.03.29 1、修复获取keyWindow崩溃问题 2、push、pop转场动画优化 3、修复导航栏间距调整bug
* 1.5.8 - 2022.12.27 修复某些情况下控制器无法释放的问题 #26 #27
* 1.5.6 - 2022.09.29 移除导航栏上的点击事件
* 1.5.5 - 2022.09.16 导航栏高度适配iPhone14系列新设备
* 1.5.4 - 2022.08.22 修复iOS13之前设置背景色、分割线颜色不生效问题
* 1.5.3 - 2022.08.18 修复侧滑返回时可能出现导航栏间距不准确问题
* 1.5.2 - 2022.08.16 屏蔽GKNavigationBar的touches事件和tap事件
* 1.5.1 - 2022.07.29 1、增加返回手势与其他手势冲突处理代理方法
                     2、当只设置gk_backImage时处理优化
                     3、解决当子控制器添加导航栏时设置导航栏间距无效的问题
* 1.5.0 - 2022.06.22 修复编译报错问题 #20
* 1.4.7 - 2022.06.14 1、awake方法修改为配置时加载，可不用手动调用
                     2、获取当前控制器方法优化
                     3、导航栏添加时机优化
* 1.4.5 - 2022.04.20 修复导航栏设置透明的bug
* 1.4.4 - 2022.04.15 导航栏设置适配iOS13之后
* 1.4.3 - 2022.03.30 修复最新版xcode编译报错问题
* 1.4.2 - 2022.03.27 模拟器获取设备型号优化，内部代码优化
* 1.4.0 - 2022.03.23 优化代码，同步oc版本，修复已知问题
* 1.3.1 - 2020.12.25 修复边缘手势无效的bug
* 1.3.0 - 2020.12.24 手势处理优化，解决可能出现的卡死问题 #10，push、pop手势灵敏度优化
* 1.2.6 - 2020.12.06 导航栏间距调整优化，手势处理优化
* 1.2.5 - 2020.12.01 修复可能出现卡死的bug
* 1.2.4 - 2020.11.27 手势处理优化，bug修改
* 1.2.3 - 2020.11.16 修复切换根控制器后不能释放的bug
* 1.2.2 - 2020.11.16 修复iOS12机型设置导航栏按钮间距无效的bug，增加返回手势拦截demo
* 1.2.0 - 2020.10.27 优化代码宏定义，增加自定义转场demo
* 1.1.8 - 2020.10.22 适配iPhone 12机型，增加自定义转场动画属性
* 1.1.5 - 2020.08.14 修复屏蔽控制器无效的bug
* 1.0.3 - 2020.07.30 增加某些控制器对导航栏间距调整的影响
* 1.0.2 - 2020.07.27 修复交换方法可能导致的crash问题
* 1.0.0 - 2020.07.22 优化手势处理，增加属性可屏蔽某些控制器对手势处理的影响
* 0.0.9 - 2020.07.16 增加gk_backImage，可自定义导航栏返回按钮图片
* 0.0.7 - 2020.06.22 设置导航栏间距不再局限于GKNavigationBar
* 0.0.6 - 2020.06.18  修复设置导航栏item间距的bug
* 0.0.4 - 2020.04.18  修复设置标题文字颜色及大小可能无效的情况
* 0.0.3 - 2020.04.12  优化对UIScrollView手势的处理
* 0.0.1 - 2020.04.12  初始版本，支持Cocoapods，Carthage，SPM
