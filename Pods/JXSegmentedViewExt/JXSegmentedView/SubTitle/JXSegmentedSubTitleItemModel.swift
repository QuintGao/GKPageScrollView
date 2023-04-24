//
//  JXSegmentedSubTitleItemModel.swift
//  JXSegmentedViewExt
//
//  Created by QuintGao on 2022/4/8.
//

import UIKit

// subTitle相对于title的位置
public enum JXSegmentedSubTitlePositionStyle {
    case top
    case left
    case bottom
    case right
}

// subTitle相对于title的对齐方式
public enum JXSegmentedSubTitleAlignStyle {
    case center
    case left
    case right
    case top
    case bottom
}

open class JXSegmentedSubTitleItemModel: JXSegmentedTitleItemModel {
    open var subTitle: String?
    open var positionStyle: JXSegmentedSubTitlePositionStyle = .bottom
    open var alignStyle: JXSegmentedSubTitleAlignStyle = .center
    open var subTitleWithTitlePositionMargin: CGFloat = 0
    open var subTitleWithTitleAlignMargin: CGFloat = 0
    open var subTitleNormalColor: UIColor = .black
    open var subTitleCurrentColor: UIColor = .black
    open var subTitleSelectedColor: UIColor = .black
    open var subTitleNormalFont: UIFont = UIFont.systemFont(ofSize: 12)
    open var subTitleSelectedFont: UIFont = UIFont.systemFont(ofSize: 12)
}
