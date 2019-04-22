<div align=center><img src="/Pictures/GKPageScrollView.png" width="405" height="63" /></div>

![](https://img.shields.io/badge/platform-iOS-red.svg)&nbsp;&nbsp;
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/QuintGao/GKPageScrollView/master/LICENSE)&nbsp;&nbsp;
![](https://img.shields.io/badge/language-Objective--C%2FSwift%204.x-orange.svg)&nbsp;&nbsp;
![](https://img.shields.io/badge/pod%20Objc-1.2.1-blue.svg) &nbsp;&nbsp;
![](https://img.shields.io/badge/pod%20Swift-1.2.1-blue.svg) &nbsp;&nbsp;
[![support](https://img.shields.io/badge/support-ios%208%2B-orange.svg)](#) 

iOS类似微博、抖音、网易云等个人详情页滑动嵌套效果
==========

GKPageScrollView是一个UIScrollview嵌套滑动库，主页参考了[JXPagingView](https://github.com/pujiaxin33/JXPagingView)，在他的基础上做了修改，实现了自己想要的效果。

## 主要功能

- 支持上下滑动、左右滑动，手势返回等
- 支持如UITableView的sectionView的悬停效果
- 支持多种分页控件，如[JXCategory](https://github.com/pujiaxin33/JXCategoryView),[WMPageController](https://github.com/wangmchn/WMPageController)等
- 可实现导航栏颜色渐变、头图下拉放大等效果
- 支持主页、列表页下拉刷新，上拉加载
- 支持列表懒加载功能

## 使用方法
### 1、手动安装
##### 下载GKPageScrollView demo
* Objective-C：拖入GKPageScrollView/objc文件夹中的.h和.m文件，#import "GKPageScrollView.h"，开始使用
* Swift：拖入GKPageScrollView/swift文件夹中的.swift文件，开始使用

### 2、CocoaPods安装：
* Objective-C：`pod 'GKPageScrollView'` then `#import <GKPageScrollView.h>`
* Swift：`pod 'GKPageScrollViewSwift'` then `import GKPageScrollViewSwift`

如果发现pod search GKPageScrollView/GKPageScrollViewSwift 不是最新版本，在终端执行pod setup命令更新本地spec镜像缓存，重新搜索即可。

## 效果图

| 说明 | 效果图 |
|-------|-------|
| **微博个人主页** | ![wb](https://github.com/QuintGao/GKPageScrollView/blob/master/Pictures/wb.gif) |
| **微博发现页** | ![wb](https://github.com/QuintGao/GKPageScrollView/blob/master/Pictures/wb_find.gif) |
| **网易云歌手页** | ![wy](https://github.com/QuintGao/GKPageScrollView/blob/master/Pictures/wy.gif) |
| **抖音个人主页** | ![dy](https://github.com/QuintGao/GKPageScrollView/blob/master/Pictures/dy.gif) |
| **主页下拉刷新** | ![dy](https://github.com/QuintGao/GKPageScrollView/blob/master/Pictures/mainRefresh.gif) |
| **列表下拉刷新** | ![dy](https://github.com/QuintGao/GKPageScrollView/blob/master/Pictures/listRefresh.gif) |
| **列表懒加载** | ![dy](https://github.com/QuintGao/GKPageScrollView/blob/master/Pictures/lazyload.gif) |

## 说明
简书：[iOS-多个UIScrollView滑动嵌套(仿微博、抖音、网易云个人详情页)](https://www.jianshu.com/p/5ce57fccdc03)

## 版本更新
* 2019.4.22   1.2.3 - UITableView cell点击处理，解决使用mj_header可能出现的bug
* 2019.4.18   1.2.1 - 公开滑动处理方法，修复方法版本判断错误问题
* 2019.3.21   1.2.0 - 优化刷新方法，可用于实现item个数不固定的情况
* 2019.3.14   1.1.0 - 增加列表懒加载功能，可用于子列表较多的情况
* 2019.3.4     1.0.9 - 增加Swift版本，pod统一更新到1.0.9
* 2019.2.25   1.0.7 - 优化切换临界点和原点的方法，增加仿微博发现页demo
* 2019.2.20   1.0.6 - 增加快速切换临界点和原点的方法
* 2018.12.11 1.0.3 - 支持下拉刷新、上拉加载
