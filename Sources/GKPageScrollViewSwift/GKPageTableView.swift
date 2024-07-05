//
//  GKPageTableView.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2019/2/20.
//  Copyright © 2019 QuintGao. All rights reserved.
//

import UIKit

@objc public protocol GKPageTableViewGestureDelegate: NSObjectProtocol {
    
    @objc optional func pageTableView(_ tableView: GKPageTableView, gestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func pageTableView(_ tableView: GKPageTableView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

open class GKPageTableView: UITableView, UIGestureRecognizerDelegate {
    open weak var gestureDelegate: GKPageTableViewGestureDelegate?
    
    open var horizontalScrollViewList: [UIScrollView]?

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = gestureDelegate?.pageTableView?(self, gestureRecognizerShouldBegin: gestureRecognizer) {
            return result
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = gestureDelegate?.pageTableView?(self, gestureRecognizer: gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return result
        }
        
        if let list = horizontalScrollViewList {
            var exist = false
            for scrollView in list {
                if gestureRecognizer.view?.isEqual(scrollView) == true {
                    exist = true
                }
                if otherGestureRecognizer.view?.isEqual(scrollView) == true {
                    exist = true
                }
            }
            if exist { return false }
        }
        
        return gestureRecognizer.view?.isKind(of: UIScrollView.self) ?? false && otherGestureRecognizer.view?.isKind(of: UIScrollView.self) ?? false
    }
}
