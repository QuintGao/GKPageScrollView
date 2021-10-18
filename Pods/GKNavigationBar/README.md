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

## 框架特性

* 无侵入性，低耦合性
* 支持自定义导航栏样式（隐藏、透明等）
* 支持控制器开关返回手势
* 支持控制器开关全屏返回手势
* 支持控制器设置导航栏透明度，可实现渐变效果
* 完美解决UITableView，UIScrollView滑动手势冲突
* 可实现push，pop时控制器缩放效果（如：今日头条）
* 可实现左滑push一个控制器的效果（如：网易新闻）

## 使用
### 1、在AppDelegate中添加导航配置

```
[GKConfigure setupDefaultConfigure]
```

### 2、创建根导航控制器
若要开启手势处理，需使用+ (instancetype)rootVC:(UIViewController *)rootVC方法创建导航控制器

```
UINavigationController *nav = [UINavigationController rootVC:[GKMainViewController new]];
```

### 3、设置导航栏属性（调用即创建）
```
self.gk_navBackgroundColor = [UIColor red]
```


## 安装
<details open>
  <summary><font size=3>CocoaPods</font></summary>

```
# 将以下内容添加到您的Podfile中：
pod 'GKNavigationBar'

// 只使用手势处理
pod 'GKNavigationBar/GestureHandle'
```
</details>

<details>
  <summary><font size=3>Carthage</font></summary>

```
Cartfile文件中添加以下内容
github "QuintGao/GKNavigationBar"

执行carthage update --platform iOS
```
</details>

<details>
  <summary><font size=3>SPM</font></summary>

```
在Xcode中点击File->Swift Packages->Add Package Dependency，然后输入https://github.com/QuintGao/GKNavigationBar
```
</details>
<details>
  <summary><font size=3>手动导入</font></summary>

```
直接拖入GKNavigationBar文件夹到项目，#import "GKNavigationBar.h"，开始使用
```
</details>

## 常见问题
感谢使用该库，如果在使用过程中遇到问题可查看issue或提交issue，或者进QQ群1047100313  

<details>
  <summary><font size=3>1、手势不生效？</font></summary>

```
1、查看是否使用了+ (instancetype)rootVC:(UIViewController *)rootVC 方法初始化导航控制器  
2、查看是否在控制器中禁用了手势返回self.gk_interactivePopDisabled = YES，self.gk_fullScreenPopDisabled = YES
```
</details>

<details>
  <summary><font size=3>2、导航栏不显示？</font></summary>

```
查看是否调用了跟导航栏相关的方法，如self.gk_navTitle = @"GKNavigationBar"  
注意：只有调用跟导航栏相关的方法才会初始化导航栏！
```
</details>

<details>
  <summary><font size=3>3、切换控制器的时候出现状态栏显示异常（一半黑一半白等）</font></summary>

```
解决办法：在控制器初始化方法里面设置状态栏样式
- (instancetype)init {
    if (self = [super init]) {
        self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

```
</details>

<details>
  <summary><font size=3>4、状态栏相关方法无效？</font></summary>

```
解决办法：在基类控制器里实现下面两个方法
- (BOOL)prefersStatusBarHidden {
    return self.gk_statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.gk_statusBarStyle;
}
```
</details>

<details>
  <summary><font size=3>5、返回手势如何拦截？</font></summary>

```
// 重写下面的方法，拦截返回手势
#pragma mark - GKGesturePopHandlerProtocol
- (BOOL)navigationShouldPop {
    // do something
    
    return NO;
}

也可以单独处理点击返回和手势返回

// 重写下面的方法，拦截点击返回
- (BOOL)navigationShouldPopOnClick {
    // do something
    
    return NO;
}
// 重写下面的方法，拦截手势返回
- (BOOL)navigationShouldPopOnGesture {
    // do something
    
    return NO;
}
```
</details>

<details>
  <summary><font size=3>6、如何与系统导航平滑过渡？</font></summary>

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
</details>

<details>
  <summary><font size=3>7、如何屏蔽某些控制器？</font></summary>

```
// 屏蔽导航栏间距处理
configure.shiledItemSpaceVCs = @[NSClassFromString(@"TZPhotoPickerController"), @"TZAlbumPickerController", @"TZ"];

// 屏蔽手势处理
configure.shiledGuestureVCs = @[NSClassFromString(@"TZPhotoPickerController"), @"TZAlbumPickerController", @"TZ"];
```
</details>

## 版本记录

<details open>
  <summary><font size=4>最近更新</font></summary>

```
1.6.0 - 2021.09.09 修复visibleViewController方法返回错误问题
1.5.9 - 2021.06.25 配置类增加backgroundImage，可设置全局导航图片
1.5.8 - 2021.06.09 增加恢复系统导航栏显示的逻辑及方法 #86
1.5.7 - 2021.05.20 修复bug #78，创建导航栏item方法优化
1.5.6 - 2021.05.18 优化导航栏返回按钮及高度处理#77，手势处理优化
1.5.5 - 2021.05.14 修复导航栏间距失效的问题#76
1.5.4 - 2021.05.12 修复可能提前触发viewDidLoad方法的问题
1.5.3 - 2021.05.07 修复直接设置背景色无效的问题#71，#74，增加对非全屏的支持
1.5.2 - 2021.04.06 增加协议方法，解决返回手势与WKWebView中的手势冲突问题
1.5.1 - 2021.03.09 返回手势优化，新增backStyle对应的image，可全局配置
1.5.0 - 2021.03.05  
----1、优化状态栏样式修改及显隐方法，可以不用在基类实现相关方法  
----2、导航栏添加机制优化，修复某些情况下可能出现两个导航栏的bug  
----3、增加全局开启UIScrollView手势处理方法
```
</details>

<details>
  <summary><font size=4>历史更新</font></summary>

```
* 1.4.3 - 2021.02.23 导航栏高度适配优化，导航栏间距调整优化，控制器增加禁止导航栏间距调整属性#62 #67
* 1.4.2 - 2021.02.20 返回拦截优化，增加同时处理点击返回和手势返回的方法
* 1.4.1 - 2021.02.07 暗黑模式适配优化，导航栏背景色和分割线颜色支持设置动态颜色
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
```
</details>

## 作者

- QQ： [1094887059](http://wpa.qq.com/msgrd?v=3&uin=1094887059&site=qq&menu=yes)  
- QQ群：[1047100313](https://qm.qq.com/cgi-bin/qm/qr?k=Aj_f4C5-R3X1_KEdeb_Ttg8pxK_41ZJu&jump_from=webapi)

- [简书](https://www.jianshu.com/u/ba61bbfc87e8)

- 支持作者

<img src="https://upload-images.jianshu.io/upload_images/1598505-1637d63e4e18e103.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" height="200">
&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
<img src="https://upload-images.jianshu.io/upload_images/1598505-0be88fd4943d1994.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="200" height="200">

[回到顶部](#readme)
