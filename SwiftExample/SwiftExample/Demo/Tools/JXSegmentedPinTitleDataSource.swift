//
//  JXSegmentedPinTitleDataSource.swift
//  SwiftExample
//
//  Created by gaokun on 2021/3/18.
//

import UIKit
import JXSegmentedView

class JXSegmentedPinTitleDataSource: JXSegmentedTitleDataSource {
    open var pinImage: UIImage?
    open var pinImageSize: CGSize = CGSize.zero

    open override func preferredItemModelInstance() -> JXSegmentedBaseItemModel {
        return JXSegmentedPinTitleItemModel()
    }

    open override func preferredRefreshItemModel(_ itemModel: JXSegmentedBaseItemModel, at index: Int, selectedIndex: Int) {
        super.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)

        guard let itemModel = itemModel as? JXSegmentedPinTitleItemModel else {
            return
        }
        itemModel.pinImage = pinImage
        itemModel.pinImgSize = pinImageSize
    }

    //MARK: - JXSegmentedViewDataSource
    open override func registerCellClass(in segmentedView: JXSegmentedView) {
        segmentedView.collectionView.register(JXSegmentedPinTitleCell.self, forCellWithReuseIdentifier: "cell")
    }

    open override func segmentedView(_ segmentedView: JXSegmentedView, cellForItemAt index: Int) -> JXSegmentedBaseCell {
        let cell = segmentedView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        return cell
    }
}
