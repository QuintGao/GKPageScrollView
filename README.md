<div align=center><img src="https://upload-images.jianshu.io/upload_images/1598505-e2dbef3c2d9e3fd9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" width="405" height="63" /></div>

<p align="center">
<a href="https://travis-ci.org/QuintGao/GKPageScrollView"><img src="https://img.shields.io/travis/QuintGao/GKPageScrollView/master.svg?style=flat"></a>
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

## 特性

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
* 1、headerView出现多个，不要在headerView代理方法中做视图创建、添加等操作  
* 2、[手势处理](https://github.com/QuintGao/GKPageScrollView/blob/master/Document/%E6%89%8B%E5%8A%BF%E5%A4%84%E7%90%86.md)
* 3、listView使用UICollectionView崩溃，参考demo中的GKBaseCollectionViewLayout，重写collectionViewContentSize
* 4、关于GKPageScrollView的懒加载方式
  * 1.8.6及之前版本，需设置categoryView.contentScrollView
  ```
     _categoryView.contentScrollView = self.pageScrollView.listContainerView.collectionView;
  ```

  * 1.8.7及之后版本，需设置categoryView.listContainer
  ```
     // OC版本
     _categoryView.listContainer = (id<JXCategoryViewListContainer>)self.pageScrollView.listContainerView;

     // Swift版本
     // 1.实现JXSegmentedViewListContainer协议
     extension GKPageListContainerView: JXSegmentedViewListContainer {}

     // 2.设置listContainer
     segmentedView.listContainer = self.pageScrollView.listContainerView
  ```
* 5、列表使用UICollectionView不能上下滑动？
```
把UICollectionView的alwaysBounceVertical属性设置为true
```

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

<details open>
    <summary><font size=4>最近更新</font></summary>

* 2025.03.18   2.0.0 - 新增根据索引切换列表方法及滑动切换回调代理方法
* 2025.03.13   1.9.8 - GKPageSmoothView增加刷新后是否重置位置属性
* 2024.10.09   1.9.7 - 修复GKPageSmoothView直接点击item时的异常问题
* 2024.07.25   1.9.6 - 修复GKPageSmoothView切换闪动问题，优化demo
* 2024.07.05   1.9.5 - 修复bug #143，代码优化
* 2024.04.18   1.9.4 - 添加隐私清单文件
* 2023.12.28   1.9.3 - 修复Swift报错 #140
* 2023.11.08   1.9.2 - 横竖屏适配，代码优化
* 2023.10.17   1.9.0 - 1、修复子列表无法获取到导航控制器的问题 2、其他逻辑及代码优化
* 2023.08.03   1.8.9 - GKPageListViewDelegate增加新的方法，支持子列表切换索引 #132
* 2023.05.23   1.8.8 - 修复oc项目pod引入后启动崩溃的问题 #127，GKPageSmoothView设置defaultSelectedIndex优化
* 2023.05.22   1.8.7 - 列表生命周期完善
* 2023.05.11   1.8.6 - 1、修复xcode14 image not found #115
                       2、尝试修复设置contentOffset导致的死循环 #113
* 2023.04.24   1.8.5 - GKPageScrollView新增属性控制横向滚动的UIScrollView
* 2023.01.11   1.8.4 - 修复GKPageSmoothView使用CollectionView时可能崩溃的问题 #122
* 2022.12.07   1.8.3 - 优化代码，增加主页和列表页同时支持刷新demo
* 2022.10.22   1.8.2 - 1、修复内存泄漏问题 #117
                       2、尝试解决崩溃问题 #116
* 2022.10.17   1.8.1 - 刷新headerView方法优化 #111
* 2022.09.02   1.8.0 - 1、修复GKPageScrollView滑动headerView后isMainCanScroll不准确的问题
                       2、GKPageScrollView新增restoreWhenRefreshHeader属性，可控制刷新headerView后的位置
                       3、滑动到原点和临界点方法新增是否需要动画方法 #111
* 2022.08.18   1.7.5 - 修复GKPageSmoothView的headerView或segmentedView高度获取不准确问题
* 2022.07.14   1.7.4 - 修复refreshHeaderView后可能出现异常的问题 #109
* 2022.06.23   1.7.3 - 1、当showInFooter为YES时刷新优化
                       2、修复可能出现的列表抖动问题 #98 #108
* 2022.04.14   1.7.2 - 1、GKPageScrollView支持动态设置frame和ceilPointHeight #104
                       2、GKPageSmoothView新增refreshSegmentedView方法，bug修复 #103
* 2022.03.15   1.7.1 - 修复headerView设置高度较低的问题 #100
* 2021.12.07   1.7.0 - 1、GKPageScrollView增加showInFooter属性，解决header超过一屏时的卡顿问题 #94
                       2、GKPageSmoothView放开currentIndex属性
</details>

<details>
     <summary><font size=4>历史更新</font></summary>

* 2021.11.08   1.6.9 - 1、修复低版本xcode报错问题 #87
                       2、修复内存泄漏问题 #88
                       3、修复cell高度无法自适应问题 #89
* 2021.10.29   1.6.8 - GKSmoothView优化，修复吸顶后点击切换显示异常问题 #87
* 2021.10.20   1.6.7 - GKSmoothView frame变化优化
* 2021.10.15   1.6.6 - 优化更新，增加设置cell属性代理 #81
* 2021.09.08   1.6.5 - 修复可能出现的黑屏问题 #77
* 2021.09.06   1.6.3 - 修复改变外部尺寸，子列表尺寸无变化问题
* 2021.07.30   1.6.2 - GKSmoothView增加代理方法，是否允许重置listScrollView的位置
* 2021.07.28   1.6.1 - GKSmoothView内部优化，修改内容不足一屏时的逻辑
* 2021.07.19   1.6.0 - 新增禁止主页滑动属性，设置后只有列表可以滑动
* 2021.06.16   1.5.8 - GKPageScrollView内部优化，修复某些情况下快速滑动导致CPU升高的问题
* 2021.04.19   1.5.6 - 修复GKPageSmoothView加载UICollectionView时的bug，去掉打印
* 2021.04.16   1.5.5 - GKPageSmoothView增加返回header容器高度，demo增加下拉刷新和上拉加载
* 2021.03.19   1.5.4 - 代码优化，GKPageSmoothView新增快速滑动到原点、临界点的方法
* 2021.01.25   1.5.3 - 1、修复GKPageSmoothView swift版本可能出现的错乱问题 #65，
                       2、GKPageScrollView增加刷新segmentedView方法
* 2021.01.07   1.5.2 - 修复某些情况下出现页面错乱问题#64
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
