//
//  JXSegmentedSubTitleCell.swift
//  JXSegmentedViewExt
//
//  Created by QuintGao on 2022/4/8.
//

import UIKit

open class JXSegmentedSubTitleCell: JXSegmentedTitleCell {
    public let subTitleLabel = UILabel()
    public var subTitleLabelCenterX = NSLayoutConstraint()
    
    open override func commonInit() {
        super.commonInit()
        
        subTitleLabel.textAlignment = .center
        subTitleLabel.clipsToBounds = true
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subTitleLabel)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let myCellModel = itemModel as? JXSegmentedSubTitleItemModel else { return }
        
        let positionMargin = myCellModel.subTitleWithTitlePositionMargin
        NSLayoutConstraint.deactivate(subTitleLabel.constraints)
        switch myCellModel.positionStyle {
        case .top:
            subTitleLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: positionMargin).isActive = true
            subTitleLeftRightAlign(cellModel: myCellModel)
            break
        case .left:
            titleLabelCenterX.isActive = false
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
            subTitleLabel.rightAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: positionMargin).isActive = true
            subTitleTopBottomAlign(cellModel: myCellModel)
            break
        case .bottom:
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: positionMargin).isActive = true
            subTitleLeftRightAlign(cellModel: myCellModel)
            break
        case .right:
            titleLabelCenterX.isActive = false
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0).isActive = true
            subTitleLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: positionMargin).isActive = true
            subTitleTopBottomAlign(cellModel: myCellModel)
            break
        }
        
        let labelSize = (myCellModel.subTitle ?? "").size(withAttributes: [NSAttributedString.Key.font: myCellModel.subTitleNormalFont])
        subTitleLabel.widthAnchor.constraint(equalToConstant: CGFloat(ceilf(Float(labelSize.width)))).isActive = true
        subTitleLabel.heightAnchor.constraint(equalToConstant: CGFloat(ceilf(Float(labelSize.height)))).isActive = true
    }
    
    open override func reloadData(itemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType)
        
        guard let myCellModel = itemModel as? JXSegmentedSubTitleItemModel else { return }
        if myCellModel.isSelected {
            subTitleLabel.font = myCellModel.subTitleSelectedFont
        }else {
            subTitleLabel.font = myCellModel.subTitleNormalFont
        }
        let titleString = myCellModel.subTitle ?? ""
        let attributedString = NSMutableAttributedString(string: titleString)
        subTitleLabel.attributedText = attributedString
        subTitleLabel.textColor = myCellModel.subTitleCurrentColor
    }
    
    // 上下结构，左中右对齐
    fileprivate func subTitleLeftRightAlign(cellModel: JXSegmentedSubTitleItemModel) {
        let alignMargin = cellModel.subTitleWithTitleAlignMargin
        switch cellModel.alignStyle {
        case .left:
            subTitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: alignMargin).isActive = true
            break
        case .right:
            subTitleLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: alignMargin).isActive = true
            break
        default:
            subTitleLabelCenterX = subTitleLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor, constant: alignMargin)
            subTitleLabelCenterX.isActive = true
        }
    }
    
    fileprivate func subTitleTopBottomAlign(cellModel: JXSegmentedSubTitleItemModel) {
        let alignMargin = cellModel.subTitleWithTitleAlignMargin
        switch cellModel.alignStyle {
        case .top:
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: alignMargin).isActive = true
            break
        case .bottom:
            subTitleLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: alignMargin).isActive = true
            break
        default:
            subTitleLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: alignMargin).isActive = true
        }
    }
}
