//
//  JXSegmentedSubTitleImageDataSource.swift
//  JXSegmentedViewExt
//
//  Created by QuintGao on 2022/4/11.
//

import UIKit

public enum JXSegmentedSubTitleImageType {
    case none       // 无图片
    case left       // 图片在标题左边
    case right      // 图片在标题右边
}

open class JXSegmentedSubTitleImageDataSource: JXSegmentedSubTitleDataSource {
    
    /// 数量需要和item的数量保持一致。可以是ImageName或者图片网络地址
    open var normalImageInfos: [String]?
    /// 数量需要和item的数量保持一致。可以是ImageName或者图片网络地址。如果不赋值，选中时就不会处理图片切换。
    open var selectedImageInfos: [String]?
    /// 内部默认通过UIImage(named:)加载图片。如果传递的是图片网络地址或者想自己处理图片加载逻辑，可以通过该闭包处理。
    open var loadImageClosure: LoadImageClosure?
    open var imageSize: CGSize = CGSize(width: 20, height: 20)
    open var titleImageSpacing: CGFloat = 5
    open var isImageZoomEnabled = false
    open var imageSelectedZoomScale: CGFloat = 1.2
    
    // 图片显示类型
    open var imageTypes: [JXSegmentedSubTitleImageType]?
    
    // 计算指示器位置时是否忽略图片宽度
    open var isIgnoreImageWidth = false
    
    // 子标题是否相对于cell居中，只支持上下结构且对齐方式将失效
    open var isSubTitleInCenterX = false
    
    open override func preferredItemModelInstance() -> JXSegmentedBaseItemModel {
        return JXSegmentedSubTitleImageItemModel()
    }
    
    open override func preferredRefreshItemModel(_ itemModel: JXSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        super.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)
        
        guard let itemModel = itemModel as? JXSegmentedSubTitleImageItemModel else {
            return
        }
        
        itemModel.loadImageClosure = loadImageClosure
        itemModel.imageType = (imageTypes != nil) ? imageTypes![index] : .none
        itemModel.imageSize = imageSize
        itemModel.titleImageSpacing = titleImageSpacing
        itemModel.imageInfo = normalImageInfos?[index]
        itemModel.selectedImageInfo = selectedImageInfos?[index]
        itemModel.isImageZoomEnabled = isImageZoomEnabled
        itemModel.imageNormalZoomScale = 1
        itemModel.imageSelectedZoomScale = imageSelectedZoomScale
        if index == selectedIndex {
            itemModel.imageCurrentZoomScale = itemModel.imageSelectedZoomScale
        }else {
            itemModel.imageCurrentZoomScale = itemModel.imageNormalZoomScale
        }
        itemModel.isSubTitleInCenterX = isSubTitleInCenterX
    }
    
    open override func preferredSegmentedView(_ segmentedView: JXSegmentedView, widthForItemAt index: Int) -> CGFloat {
        if itemWidth == JXSegmentedViewAutomaticDimension {
            let titleWidth = super.preferredSegmentedView(segmentedView, widthForItemAt: index)
            let style = positionStyle
            let type = (imageTypes != nil) ? imageTypes![index] : .none
            var cellWidth: CGFloat = 0
            if (style == .top || style == .bottom) && type != .none {
                cellWidth = titleWidth + titleImageSpacing + imageSize.width
            }else {
                cellWidth = titleWidth
            }
            return cellWidth
        }else {
            return itemWidth
        }
    }
    
    //MARK: - JXSegmentedViewDataSource
    open override func registerCellClass(in segmentedView: JXSegmentedView) {
        segmentedView.collectionView.register(JXSegmentedSubTitleImageCell.self, forCellWithReuseIdentifier: "cell")
    }

    open override func segmentedView(_ segmentedView: JXSegmentedView, cellForItemAt index: Int) -> JXSegmentedBaseCell {
        let cell = segmentedView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        return cell
    }
    
    public override func getCellFrameAt(index: Int, frame: CGRect) -> CGRect {
        var frame = super.getCellFrameAt(index: index, frame: frame)
        guard let imageTypes = imageTypes else { return frame }
        if isIgnoreImageWidth && (positionStyle == .top || positionStyle == .bottom) {
            if index >= 0 && index < imageTypes.count {
                let type = imageTypes[index]
                var imageWidth: CGFloat = 0
                if type != .none {
                    imageWidth = titleImageSpacing + imageSize.width
                }
                frame.size.width -= imageWidth
                if type == .left {
                    frame.origin.x += imageWidth
                }
            }
        }
        return frame
    }
    
    public override func getSelectCellFrameAt(index: Int, frame: CGRect) -> CGRect {
        var frame = super.getCellFrameAt(index: index, frame: frame)
        guard let imageTypes = imageTypes else { return frame }
        if isIgnoreImageWidth && (positionStyle == .top || positionStyle == .bottom) {
            if index >= 0 && index < imageTypes.count {
                let type = imageTypes[index]
                var imageWidth: CGFloat = 0
                if type != .none {
                    imageWidth = titleImageSpacing + imageSize.width
                }
                frame.size.width -= imageWidth
                if type == .left {
                    frame.origin.x += imageWidth
                }
            }
        }
        return frame
    }
    
    open override func refreshItemModel(_ segmentedView: JXSegmentedView, leftItemModel: JXSegmentedBaseItemModel, rightItemModel: JXSegmentedBaseItemModel, percent: CGFloat) {
        super.refreshItemModel(segmentedView, leftItemModel: leftItemModel, rightItemModel: rightItemModel, percent: percent)
        
        guard let leftModel = leftItemModel as? JXSegmentedSubTitleImageItemModel, let rightModel = rightItemModel as? JXSegmentedSubTitleImageItemModel else {
            return
        }
        
        if isImageZoomEnabled {
            leftModel.imageCurrentZoomScale = JXSegmentedViewTool.interpolate(from: imageSelectedZoomScale, to: 1, percent: CGFloat(percent))
            rightModel.imageCurrentZoomScale = JXSegmentedViewTool.interpolate(from: 1, to: imageSelectedZoomScale, percent: CGFloat(percent))
        }
    }
    
    open override func refreshItemModel(_ segmentedView: JXSegmentedView, currentSelectedItemModel: JXSegmentedBaseItemModel, willSelectedItemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
        super.refreshItemModel(segmentedView, currentSelectedItemModel: currentSelectedItemModel, willSelectedItemModel: willSelectedItemModel, selectedType: selectedType)
        
        guard let myCurrentSelectedItemModel = currentSelectedItemModel as? JXSegmentedSubTitleImageItemModel, let myWillSelectedItemModel = willSelectedItemModel as? JXSegmentedSubTitleImageItemModel else {
            return
        }

        myCurrentSelectedItemModel.imageCurrentZoomScale = myCurrentSelectedItemModel.imageNormalZoomScale
        myWillSelectedItemModel.imageCurrentZoomScale = myWillSelectedItemModel.imageSelectedZoomScale
    }
}
