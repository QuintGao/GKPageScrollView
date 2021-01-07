<div align=center><img src="https://upload-images.jianshu.io/upload_images/1598505-e2dbef3c2d9e3fd9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="405" height="63" /></div>

<p align="center">
<a href="https://travis-ci.org/QuintGao/GKPageScrollView"><img src="http://img.shields/io/travis/QuintGao/GKPageScrollView/master.svg?style=flat"></a>
<a href="https://github.com/QuintGao/GKPageScrollView"><img src="https://img.shields.io/badge/platform-iOS-red.svg"></a>
<a href="" ><img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat"></a>
<a href="https://github.com/QuintGao/GKPageScrollView"><img src="https://img.shields.io/badge/language-Objective--C%2FSwift%205.x-orange.svg"></a>
<a href="https://cocoapods.org/pods/GKPageScrollView"><img src="http://img.shields.io/cocoapods/v/GKPageScrollView.svg?style=flat"></a>
<a href=""><img src="https://img.shields.io/badge/support-ios%208%2B-orange.svg"></a>
</p>

iOS类似微博、抖音、网易云等个人详情页滑动嵌套效果
==========

GKPageScrollView是一个UIScrollview嵌套滑动库，主要参考了[JXPagingView](https://github.com/pujiaxin33/JXPagingView)，在他的基础上做了修改，实现了自己想要的效果。  

GKPageSmoothView是一个可延续滑动的UIScrollView嵌套滑动库

## 主要功能

### GKPageScrollView

- 支持上下滑动、左右滑动，手势返回等
- 支持如UITableView的sectionView的悬停效果
- 支持多种分页控件，如[JXCategoryView](https://github.com/pujiaxin33/JXCategoryView),[WMPageController](https://github.com/wangmchn/WMPageController),[VTMagic](https://github.com/tianzhuo112/VTMagic)等
- 可实现导航栏颜色渐变、头图下拉放大等效果
- 支持主页、列表页下拉刷新，列表页上拉加载
- 支持列表懒加载创建

### GKPageSmoothView

- 支持上下滑动、左右滑动、手势返回等
- 支持顶部悬停、底部悬停
- 支持底部悬停拖拽，可实现豆瓣电影详情页效果
- 支持如[JXCategoryView](https://github.com/pujiaxin33/JXCategoryView),[JXSegmentedView](https://github.com/pujiaxin33/JXSegmentedView)等的分段控件
- 可实现导航栏颜色渐变、头图下拉放大等效果
- 支持主页下拉刷新、列表页上拉加载

## 1.5.0升级指南
1.5.0版本以后，使用swift版本需  
`pod 'GKPageScrollView/Swift'`  
`pod 'GKPageSmoothView/Swift'`

## 使用方法
### 1、手动安装
##### 下载GKPageScrollView demo
* Objective-C：  
拖入Source/GKPageScrollView文件夹中的.h和.m文件，#import "GKPageScrollView.h"，开始使用  
拖入Source/GKPageSmoothView文件夹中的.h和.m文件，#import "GKPageSmoothView.h"，开始使用

* Swift：    
拖入Source/GKPageScrollViewSwift文件夹中的.swift文件，开始使用    
拖入Source/GKPageSmoothViewSwift文件夹中的.swift文件，开始使用  

### 2、CocoaPods安装：
* Objective-C：   
`pod 'GKPageScrollView'` then `#import <GKPageScrollView/GKPageScrollView.h>`    
`pod 'GKPageSmoothView'` then `#import <GKPageSmoothView/GKPageSmoothView.h>`

* Swift：    
`pod 'GKPageScrollViewSwift'` then `import GKPageScrollViewSwift`    
`pod 'GKPageSmoothViewSwift'` then `import GKPageSmoothViewSwift`

如果发现pod search GKPageScrollView/GKPageScrollViewSwift 不是最新版本，在终端执行pod setup命令更新本地spec镜像缓存，重新搜索即可。

### 3、Swift Package Manager 安装
依次点击 Xcode 的菜单 File > Swift Packages > Add Package Dependency，填入 `https://github.com/QuintGao/GKPageScrollView.git`  
选择需要使用的库，GKPageScrollView/GKPageScrollViewSwift/GKPageSmoothView/GKPageSmoothViewSwift

## 常见问题
1、headerView出现多个，不要在headerView代理方法中做视图创建、添加等操作  
2、[手势处理](https://github.com/QuintGao/GKPageScrollView/blob/master/Document/%E6%89%8B%E5%8A%BF%E5%A4%84%E7%90%86.md)

## 效果图

|说明|效果图|
|-------|-------|
| **微博个人主页** | ![wb](https://upload-images.jianshu.io/upload_images/1598505-53da65a9a8f3229c.gif?imageMogr2/auto-orient/strip)|
| **微博发现页** |![wb_find](https://upload-images.jianshu.io/upload_images/1598505-a5f087ed3b5e93d4.gif?imageMogr2/auto-orient/strip)|
| **网易云歌手页** | ![wy](https://upload-images.jianshu.io/upload_images/1598505-5c55692e236b9f82.gif?imageMogr2/auto-orient/strip) |
| **抖音个人主页** | ![dy](https://upload-images.jianshu.io/upload_images/1598505-8c0450b2032bc18c.gif?imageMogr2/auto-orient/strip) |
| **主页下拉刷新** | ![mainRefresh](https://upload-images.jianshu.io/upload_images/1598505-5209661b7169f611.gif?imageMogr2/auto-orient/strip) |
| **列表下拉刷新** | ![listRefresh](https://upload-images.jianshu.io/upload_images/1598505-4bd5353e7471cb52.gif?imageMogr2/auto-orient/strip) |
| **列表懒加载** | ![lazyload](https://upload-images.jianshu.io/upload_images/1598505-7917c1f0f1749c7e.gif?imageMogr2/auto-orient/strip) |
| **嵌套滑动1** | ![nest1](https://upload-images.jianshu.io/upload_images/1598505-40e73956ad04226e.gif?imageMogr2/auto-orient/strip)|
| **嵌套滑动2** |![nest2](https://upload-images.jianshu.io/upload_images/1598505-8e2acebddb2f5366.gif?imageMogr2/auto-orient/strip) |
| **豆瓣电影详情** |![db](https://upload-images.jianshu.io/upload_images/1598505-9958ad3c0c89451f.gif?imageMogr2/auto-orient/strip)|

## 说明
[iOS-多个UIScrollView滑动嵌套(仿微博、抖音、网易云个人详情页)](https://www.jianshu.com/p/5ce57fccdc03)   
[iOS用GKPageScrollView实现微博发现页滑动效果](https://www.jianshu.com/p/f9846c46fca7)   
[iOS用GKPageScrollView实现多层分类嵌套滑动](https://www.jianshu.com/p/5de1bcd3ecad)  
[【iOS】仿豆瓣电影详情页嵌套滑动效果](https://www.jianshu.com/p/75b979177ebe)  

## 版本更新

* 2021.01.07   1.5.2 - 修复某些情况下出现页面错乱问题#47
* 2021.01.02   1.5.0 - pod and spm update
* 2020.12.10   1.4.2 - 拆分GKPageScrollView和GKPageSmoothView，GKPageSmoothView支持底部悬浮、底部拖拽
* 2020.12.09   1.4.1 - 增加属性可传入横向滑动的scrollView，更加方便处理手势冲突
* 2020.12.01   1.4.0 - 修复延续滑动可能出现header不能滑动的bug #57
* 2020.08.07   1.3.8 - 修复列表刷新快速滑动时的bug
* 2020.07.22   1.3.7 - 滑动延续代码优化
* 2020.05.19   1.3.6 - 增加列表延续滑动功能，需使用GKPageSmoothView类
* 2020.04.18   1.3.5 - 优化代码，支持Swift 5.x
* 2019.11.11   1.3.3 - 修复GKPageScrollView与返回手势的滑动冲突
* 2019.10.25   1.3.1 - 增加GKPageTableViewGestureDelegate，解决嵌套时的滑动冲突 
* 2019.10.22   1.3.0 - 修复pageScrollView高度为0时出现的崩溃问题
* 2019.10.09   1.2.9 - 解决pageScrollView不是全屏时的高度不准确问题
* 2019.06.16   1.2.7 - 优化设置列表加载方式的方法，可通过属性设置懒加载方式
* 2019.06.06   1.2.6 - 解决当HeaderView的高度设置为小于1时列表不能滑动问题
* 2019.06.03   1.2.5 - 修改点击状态栏后位置错乱问题
* 2019.04.22   1.2.3 - UITableView cell点击处理，解决使用mj_header可能出现的bug
* 2019.04.18   1.2.1 - 公开滑动处理方法，修复方法版本判断错误问题
* 2019.03.21   1.2.0 - 优化刷新方法，可用于实现item个数不固定的情况
* 2019.03.14   1.1.0 - 增加列表懒加载功能，可用于子列表较多的情况
* 2019.03.04   1.0.9 - 增加Swift版本，pod统一更新到1.0.9
* 2019.02.25   1.0.7 - 优化切换临界点和原点的方法，增加仿微博发现页demo
* 2019.02.20   1.0.6 - 增加快速切换临界点和原点的方法
* 2018.12.11   1.0.3 - 支持下拉刷新、上拉加载
