//
//  JXSegmentedSubTitleImageItemModel.swift
//  JXSegmentedViewExt
//
//  Created by QuintGao on 2022/4/11.
//

import UIKit

open class JXSegmentedSubTitleImageItemModel: JXSegmentedSubTitleItemModel {
    open var imageType: JXSegmentedSubTitleImageType = .none
    open var imageInfo: String?
    open var selectedImageInfo: String?
    open var loadImageClosure: LoadImageClosure?
    open var imageSize: CGSize = CGSize(width: 20, height: 20)
    open var titleImageSpacing: CGFloat = 5
    open var isImageZoomEnabled = false
    open var imageNormalZoomScale: CGFloat = 0
    open var imageCurrentZoomScale: CGFloat = 0
    open var imageSelectedZoomScale: CGFloat = 0
    open var isSubTitleInCenterX = false
}
