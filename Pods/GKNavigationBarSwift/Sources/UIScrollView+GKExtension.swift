//
//  UIScrollView+GKExtension.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

extension UIScrollView {
    fileprivate struct AssociatedKeys {
        static var gkOpenGestureHandle: Bool = false
    }
    
    /// 是否开启UIScrollView左滑返回手势处理，默认NO
    public var gk_openGestureHandle: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkOpenGestureHandle) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkOpenGestureHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIScrollView {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if !self.gk_openGestureHandle {
            return true
        }
        
        if self.panBack(gesture: gestureRecognizer) {
            return false
        }
        return true
    }
    
    fileprivate func panBack(gesture: UIGestureRecognizer) -> Bool {
        if gesture == self.panGestureRecognizer {
            let point = self.panGestureRecognizer.translation(in: self)
            let state = gesture.state
            
            // 设置手势滑动的位置距离屏幕左边的区域
            let locationDistance = UIScreen.main.bounds.size.width
            if state == .began || state == .possible {
                let location = gesture.location(in: self)
                if point.x > 0 && location.x < locationDistance && contentOffset.x <= 0 {
                    return true
                }
            }
        }
        return false
    }
}
