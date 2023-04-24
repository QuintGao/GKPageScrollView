# JXSegmentedViewExt

<p align="center">
<a href="https://github.com/QuintGao/JXSegmentedViewExt"><img src="https://img.shields.io/badge/platform-iOS-red.svg"></a>
<a href="" ><img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat"></a>
<a href="https://cocoapods.org/pods/JXSegmentedViewExt"><img src="http://img.shields.io/cocoapods/v/JXSegmentedViewExt.svg?style=flat"></a>
<a href=""><img src="https://img.shields.io/badge/support-ios%208%2B-orange.svg"></a>
</p>

该库是对[JXSegmentedView](https://github.com/pujiaxin33/JXSegmentedView)的扩展及优化，目前的JXSegmentedView版本是1.3.0，JXSegmentedViewExt版本是1.0.1

## 优化及bug修改

#### 优化
1、增加方法，可动态刷新标题和指示器颜色
```
/// 刷新所有cell状态
func gk_refreshCellState()

/// 刷新所有指示器状态
func gk_refreshIndicatorState()

/// 刷新所有cell和指示器状态
func gk_refreshCellAndIndicatorState()

```

2、增加属性isSelectItemOnScrollHalf，可控制在滑动到一半的时候选中下一个item

#### bug修改
1、修复某些情况下导致的Unbalanced calls to begin/end appearance transitions for XXXX

## Pod扩展
JXSegmentedViewExt优化了JXSegmentedView的pod方式，将不同组件进行拆分，可按需pod

#### 基础库
```
pod 'JXSegmentedViewExt' 或 pod 'JXSegmentedViewExt/Core'
```

#### 分类
```
// 文字
pod 'JXSegmentedViewExt/Title'

// 文字+副标题
pod 'JXSegmentedViewExt/SubTitle'

// 图片
pod 'JXSegmentedViewExt/Image'

// 文字+图片
pod 'JXSegmentedViewExt/TitleImage'

// 富文本
pod 'JXSegmentedViewExt/TitleAttribute'

// title+小红点
pod 'JXSegmentedViewExt/Dot'

// title+小红点缩放
pod 'JXSegmentedViewExt/DotZoom'

// title+数字
pod 'JXSegmentedViewExt/Number'

// title+(文字、数字、红点混合)
pod 'JXSegmentedViewExt/Badge'

// title垂直滚动缩放
pod 'JXSegmentedViewExt/VerticalZoomTitle'
```

#### 指示器
```
// 背景
pod 'JXSegmentedViewExt/Background'

// 线
pod 'JXSegmentedViewExt/Indicator/Line'

// 线+对齐
pod 'JXSegmentedViewExt/Indicator/AlignmentLine'

// 线+彩虹效果
pod 'JXSegmentedViewExt/Indicator/RainbowLine'

// 图片
pod 'JXSegmentedViewExt/Indicator/Image'

// 背景渐变
pod 'JXSegmentedViewExt/Indicator/Gradient'

// 线渐变
pod 'JXSegmentedViewExt/Indicator/GradientLine'

// 三角形
pod 'JXSegmentedViewExt/Indicator/Triangle'

// 点线
pod 'JXSegmentedViewExt/Indicator/DotLine'

// 双线
pod 'JXSegmentedViewExt/Indicator/DoubleLine'
```

## 更新记录

* 1.0.2 2022.07.12 JXSegmentedTitleImage支持多种组合方式
* 1.0.1 2022.04.25 优化及bug修改，将pod拆分为多个
