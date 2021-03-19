//
//  JXSegmentedPinTitleCell.swift
//  SwiftExample
//
//  Created by gaokun on 2021/3/18.
//

import UIKit
import JXSegmentedView

class JXSegmentedPinTitleCell: JXSegmentedTitleCell {
    public let pinImgView = UIImageView()

    open override func commonInit() {
        super.commonInit()

        contentView.addSubview(pinImgView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard let myItemModel = itemModel as? JXSegmentedPinTitleItemModel else {
            return
        }
        
//        self.pinImgView = [[UIImageView alloc] init];
//        self.pinImgView.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.contentView addSubview:self.pinImgView];
//        [self.pinImgView.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor].active = YES;
//        [self.pinImgView.rightAnchor constraintEqualToAnchor:self.titleLabel.leftAnchor constant:-2].active = YES;
        pinImgView.center = titleLabel.center
        pinImgView.frame.origin.x = titleLabel.frame.origin.x - 2 - pinImgView.frame.size.width;
    }

    open override func reloadData(itemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType )

        guard let myItemModel = itemModel as? JXSegmentedPinTitleItemModel else {
            return
        }

        pinImgView.image = myItemModel.pinImage
        pinImgView.sizeToFit()
        pinImgView.isHidden = !myItemModel.isSelected
        setNeedsLayout()
    }
}
