# JXCategoryViewExt

<p align="center">
<a href="https://github.com/QuintGao/JXCategoryViewExt"><img src="https://img.shields.io/badge/platform-iOS-red.svg"></a>
<a href="" ><img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat"></a>
<a href="https://cocoapods.org/pods/JXCategoryViewExt"><img src="http://img.shields.io/cocoapods/v/JXCategoryViewExt.svg?style=flat"></a>
<a href=""><img src="https://img.shields.io/badge/support-ios%208%2B-orange.svg"></a>
</p>

该库是对[JXCategoryView](https://github.com/pujiaxin33/JXCategoryView/)的扩展及优化，目前的JXCategoryView版本1.5.8，JXCategoryViewExt版本1.0.0

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
* 1.0.3 2021.01.25 增加subTitle分类样式和alignmentLine指示器样式
* 1.0.2 2021.01.21 将IndicatorBackgroundView和RTL移除基类，单独pod
* 1.0.1 2021.01.19 新增标题圆点缩放样式，可实现网易新闻效果
* 1.0.0 2021.01.15 优化及bug修改，将pod拆分为多个
