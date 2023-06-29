# JXCategoryViewExt

<p align="center">
<a href="https://github.com/QuintGao/JXCategoryViewExt"><img src="https://img.shields.io/badge/platform-iOS-red.svg"></a>
<a href="" ><img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat"></a>
<a href="https://cocoapods.org/pods/JXCategoryViewExt"><img src="http://img.shields.io/cocoapods/v/JXCategoryViewExt.svg?style=flat"></a>
<a href=""><img src="https://img.shields.io/badge/support-ios%208%2B-orange.svg"></a>
</p>

该库是对[JXCategoryView](https://github.com/pujiaxin33/JXCategoryView/)的扩展及优化，目前的JXCategoryView版本1.6.1，JXCategoryViewExt版本1.2.0

## 优化及bug修改

#### 优化
1、增加方法，可动态刷新标题和指示器颜色，需使用JXCategoryTitleView
```
/// 刷新所有cell状态
- (void)gk_refreshCellState;

/// 刷新所有指示器状态
- (void)gk_refreshIndicatorState;

/// 刷新所有cell和指示器状态
- (void)gk_refreshCellAndIndicatorState;

```

2、增加属性selectItemOnScrollHalf，可控制在滑动到一半的时候选中下一个item

#### bug修改
1、修复某些情况下将listView的frame设置为CGRectZero导致使用Masonry布局时出现报错  
2、修复某些情况下导致的Unbalanced calls to begin/end appearance transitions for XXXX

## pod扩展
JXCategoryViewExt优化了JXCategoryView的pod方式，将不同组件进行拆分，可按需pod

#### 基础库
```
pod 'JXCategoryViewExt' 或 pod 'JXCategoryViewExt/Core'
```

#### 分类
```
// 文字
pod 'JXCategoryViewExt/Title'

// 文字+副标题
pod 'JXCategoryViewExt/SubTitle'

// 图片
pod 'JXCategoryViewExt/Image'

// 文字+图片
pod 'JXCategoryViewExt/TitleImage'

// 富文本
pod 'JXCategoryViewExt/TitleAttribute'

// title+小红点
pod 'JXCategoryViewExt/Dot'

// title+小红点缩放
pod 'JXCategoryViewExt/DotZoom'

// title+数字
pod 'JXCategoryViewExt/Number'

// title+(文字、数字、红点混合)
pod 'JXCategoryViewExt/Badge'

// title垂直滚动缩放
pod 'JXCategoryViewExt/VerticalZoomTitle'
```

#### 指示器
```
// 背景
pod 'JXCategoryViewExt/Background'

// 线
pod 'JXCategoryViewExt/Indicator/Line'

// 线+对齐
pod 'JXCategoryViewExt/Indicator/AlignmentLine'

// 线+彩虹效果
pod 'JXCategoryViewExt/Indicator/RainbowLine'

// 图片
pod 'JXCategoryViewExt/Indicator/Image'

// 球
pod 'JXCategoryViewExt/Indicator/Ball'

// 三角形
pod 'JXCategoryViewExt/Indicator/Triangle'

// 点线
pod 'JXCategoryViewExt/Indicator/DotLine'
```

#### RTL
```
pod 'JXCategoryViewExt/RTL'
```

## 更新记录
* 1.2.0 2023.02.14 JXCategoryView更新到1.6.1，代码优化
* 1.1.7 2022.04.19 新增JXCategoryBadgeView，支持文字、数字、红点混合显示
* 1.1.6 2021.12.03 删除多余属性
* 1.1.4 2021.10.18 JXCategorySubTitleImageView优化，修复bug
* 1.1.2 2021.08.20 新增JXCategorySubTitleImageView类型
* 1.1.0 2021.08.19 JXCategoryTitleImageView支持忽略image宽度
* 1.0.8 2021.07.21 JXCategoryTitleView支持动态设置标题
* 1.0.7 2021.06.23 JXCategoryTitleView文字缩放优化
* 1.0.6 2021.04.30 JXCategoryView更新到1.5.9版本
* 1.0.5 2021.03.10 优化滑动到一半选中时的动画效果
* 1.0.4 2021.03.08 修复某些情况下导致的Unbalanced calls to begin/end appearance transitions for xxx
* 1.0.3 2021.01.25 增加subTitle分类样式和alignmentLine指示器样式
* 1.0.2 2021.01.21 将IndicatorBackgroundView和RTL移除基类，单独pod
* 1.0.1 2021.01.19 新增标题圆点缩放样式，可实现网易新闻效果
* 1.0.0 2021.01.15 优化及bug修改，将pod拆分为多个
