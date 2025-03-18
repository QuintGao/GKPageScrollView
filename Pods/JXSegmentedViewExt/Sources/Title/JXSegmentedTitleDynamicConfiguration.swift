//
//  JXSegmentedTitleDynamicConfiguration.swift
//  JXSegmentedViewExt
//
//  Created by QuintGao on 2024/5/16.
//

import UIKit

public protocol JXSegmentedTitleDynamicConfiguration: NSObject {
    func titleNumberOfLines(at index: Int) -> Int
    func titleNormalColor(at index: Int) -> UIColor
    func titleSelectedColor(at index: Int) -> UIColor
    func titleNormalFont(at index: Int) -> UIFont
    func titleSelectedFont(at index: Int) -> UIFont?
}
