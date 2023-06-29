//
//  JXSegmentedIndicatorAlignmentLineView.swift
//  JXSegmentedViewExt
//
//  Created by QuintGao on 2022/4/24.
//

import UIKit

public enum JXSegmentedIndicatorAlignmentStyle {
    case leading
    case center
    case trailing
}

open class JXSegmentedIndicatorAlignmentLineView: JXSegmentedIndicatorLineView {

    open var alignmentStyle = JXSegmentedIndicatorAlignmentStyle.center

    open override func calculateOriginX(_ frame: CGRect, width: CGFloat) -> CGFloat {
        var originX: CGFloat = 0
        switch alignmentStyle {
        case .leading:
            originX = frame.origin.x
        case .center:
            originX = super.calculateOriginX(frame, width: width)
        case .trailing:
            originX = frame.origin.x + frame.size.width - width
        }
        return originX
    }
}
