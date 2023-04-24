//
//  JXSegmentedSubTitleDataSource.swift
//  JXSegmentedViewExt
//
//  Created by QuintGao on 2022/4/8.
//

import UIKit

open class JXSegmentedSubTitleDataSource: JXSegmentedTitleDataSource {
    /// subTitle数组
    open var subTitles = [String]()
    
    /// 子标题相对于title的位置，默认.bottom
    open var positionStyle: JXSegmentedSubTitlePositionStyle = .bottom
    
    /// 子标题相对于title的对齐，默认.center
    /// 当positionStyle为上下时，对齐方式左中右有效
    /// 当positionStyle为左右时，对齐方式上中下有效
    open var alignStyle: JXSegmentedSubTitleAlignStyle = .center
    
    /// 子标题相对于title的间距，默认0
    open var subTitleWithTitlePositionMargin: CGFloat = 0
    
    /// 子标题相对于titl的对齐间距，默认0
    open var subTitleWithTitleAlignMargin: CGFloat = 0
    
    /// 子标题默认颜色，默认black
    open var subTitleNormalColor: UIColor = .black
    
    /// 子标题选中颜色，默认black
    open var subTitleSelectedColor: UIColor = .black
    
    /// 子标题默认字体大小
    open var subTitleNormalFont: UIFont = UIFont.systemFont(ofSize: 12)
    
    /// 子标题选中字体大小
    open var subTitleSelectedFont: UIFont = UIFont.systemFont(ofSize: 12)
    
    /// 是否忽略subTitle宽度，默认NO，此属性只在positionStyle为左右时有效
    open var isIgnoreSubTitleWidth = false
    
    open override func preferredItemCount() -> Int {
        return titles.count
    }
    
    open override func preferredItemModelInstance() -> JXSegmentedBaseItemModel {
        return JXSegmentedSubTitleItemModel()
    }
    
    open override func preferredRefreshItemModel(_ itemModel: JXSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        super.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)
        
        guard let myItemModel = itemModel as? JXSegmentedSubTitleItemModel else { return }
        myItemModel.subTitle = subTitles[index]
        myItemModel.textWidth = widthForTitle(myItemModel.title ?? "", subTitle: myItemModel.subTitle ?? "")
        myItemModel.subTitleNormalFont = subTitleNormalFont
        myItemModel.subTitleSelectedFont = subTitleSelectedFont
        myItemModel.subTitleNormalColor = subTitleNormalColor
        myItemModel.subTitleSelectedColor = subTitleSelectedColor
        myItemModel.positionStyle = positionStyle
        myItemModel.alignStyle = alignStyle
        myItemModel.subTitleWithTitlePositionMargin = subTitleWithTitlePositionMargin
        myItemModel.subTitleWithTitleAlignMargin = subTitleWithTitleAlignMargin
        if index == selectedIndex {
            myItemModel.subTitleCurrentColor = subTitleSelectedColor
        }else {
            myItemModel.subTitleCurrentColor = subTitleNormalColor
        }
    }
    
    open func widthForTitle(_ title: String, subTitle: String) -> CGFloat {
        if widthForTitleClosure != nil {
            return widthForTitleClosure!(title)
        }else {
            let titleW = CGFloat(ceilf(widthForTitle(title, font: titleNormalFont)))
            let subTitleW = CGFloat(ceilf(widthForTitle(subTitle, font: subTitleNormalFont)))
            if positionStyle == .top || positionStyle == .bottom {
                return max(titleW, subTitleW)
            }else {
                return titleW + subTitleW
            }
        }
    }
    
    open override func preferredSegmentedView(_ segmentedView: JXSegmentedView, widthForItemAt index: Int) -> CGFloat {
        if itemWidth == JXSegmentedViewAutomaticDimension {
            
        }
        
        
        var width = super.preferredSegmentedView(segmentedView, widthForItemAt: index)
        if itemWidth == JXSegmentedViewAutomaticDimension {
            width = (dataSource[index] as! JXSegmentedSubTitleItemModel).textWidth
        }else {
            width = itemWidth
        }
        return width
    }
    
    //MARK: - JXSegmentedViewDataSource
    open override func registerCellClass(in segmentedView: JXSegmentedView) {
        segmentedView.collectionView.register(JXSegmentedSubTitleCell.self, forCellWithReuseIdentifier: "cell")
    }

    open override func segmentedView(_ segmentedView: JXSegmentedView, cellForItemAt index: Int) -> JXSegmentedBaseCell {
        let cell = segmentedView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        return cell
    }
    
    public override func getCellFrameAt(index: Int, frame: CGRect) -> CGRect {
        var frame = frame
        if isIgnoreSubTitleWidth && (positionStyle == .left || positionStyle == .right) {
            if index >= 0 && index < subTitles.count {
                let subTitle = subTitles[index]
                let subTitleWidth = subTitle.size(withAttributes: [NSAttributedString.Key.font: subTitleNormalFont]).width
                frame.size.width -= subTitleWidth
                if positionStyle == .left {
                    frame.origin.x += subTitleWidth
                }
            }
        }
        return frame
    }
    
    public override func getSelectCellFrameAt(index: Int, frame: CGRect) -> CGRect {
        var frame = frame
        if isIgnoreSubTitleWidth && (positionStyle == .left || positionStyle == .right) {
            if index >= 0 && index < subTitles.count {
                let subTitle = subTitles[index]
                let subTitleWidth = subTitle.size(withAttributes: [NSAttributedString.Key.font: subTitleNormalFont]).width
                frame.size.width -= subTitleWidth
                if positionStyle == .left {
                    frame.origin.x += subTitleWidth
                }
            }
        }
        return frame
    }
    
    open override func refreshItemModel(_ segmentedView: JXSegmentedView, leftItemModel: JXSegmentedBaseItemModel, rightItemModel: JXSegmentedBaseItemModel, percent: CGFloat) {
        super.refreshItemModel(segmentedView, leftItemModel: leftItemModel, rightItemModel: rightItemModel, percent: percent)
    }
    
    open override func refreshItemModel(_ segmentedView: JXSegmentedView, currentSelectedItemModel: JXSegmentedBaseItemModel, willSelectedItemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
        super.refreshItemModel(segmentedView, currentSelectedItemModel: currentSelectedItemModel, willSelectedItemModel: willSelectedItemModel, selectedType: selectedType)
        
        guard let unSelectedCellModel = currentSelectedItemModel as? JXSegmentedSubTitleItemModel, let selectedCellModel = willSelectedItemModel as? JXSegmentedSubTitleItemModel else { return }
        selectedCellModel.subTitleCurrentColor = selectedCellModel.subTitleSelectedColor
        unSelectedCellModel.subTitleCurrentColor = unSelectedCellModel.subTitleNormalColor
    }
    
    /// MARK: Private
    fileprivate func widthForTitle(_ title: String, font: UIFont) -> Float {
        return Float(NSString(string: title).boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : font], context: nil).size.width)
    }
}
