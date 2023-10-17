//
//  UIScrollView+GKExtension.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

extension UIScrollView: GKAwakeProtocol {
    fileprivate struct AssociatedKeys {
        static var gkOpenGestureHandle: Void?
    }
    
    /// 是否开启UIScrollView左滑返回手势处理，默认NO
    public var gk_openGestureHandle: Bool {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkOpenGestureHandle) as? Bool else { return false }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkOpenGestureHandle, newValue)
        }
    }
    
    // MARK: - 重新系统方法
    private static let onceToken = UUID().uuidString
    @objc public static func gkAwake() {
        DispatchQueue.once(token: onceToken) {
            let oriSels = ["willMoveToSuperview:"]
            
            for oriSel in oriSels {
                gk_swizzled_instanceMethod("gkGesture", oldClass: self, oldSelector: oriSel, newClass: self)
            }
        }
    }
    
    @objc func gkGesture_willMove(toSuperview newSuperview: UIView?) {
        if (newSuperview != nil), GKConfigure.gk_openScrollViewGestureHandle {
            self.gk_openGestureHandle = true
        }
        gkGesture_willMove(toSuperview: newSuperview)
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
