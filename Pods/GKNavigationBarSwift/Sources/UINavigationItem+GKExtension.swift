//
//  UINavigationItem+GKExtension.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

extension UINavigationItem: GKAwakeProtocol {
    // MARK: - 重新系统方法
    private static let onceToken = UUID().uuidString
    @objc public static func gkAwake() {
        if #available(iOS 11.0, *) {} else {
            DispatchQueue.once(token: onceToken) {
                let oriSels = ["setLeftBarButtonItem:animated:",
                               "setLeftBarButtonItems:animated:",
                               "setRightBarButtonItem:animated:",
                               "setRightBarButtonItems:animated:"]
                
                for oriSel in oriSels {
                    gk_swizzled_instanceMethod("gk", oldClass: self, oldSelector: oriSel, newClass: self)
                }
            }
        }
    }
    
    @objc func gk_setLeftBarButtonItem(_ item: UIBarButtonItem?, animated: Bool) {
        if !GKConfigure.gk_disableFixSpace && item != nil { // 存在按钮且需要调节
            self.setLeftBarButtonItems([item!], animated: animated)
        }else { // 不存在按钮或者不需要调节
            self.setLeftBarButtonItems(nil, animated: false)
            self.gk_setLeftBarButtonItem(item, animated: animated)
        }
    }
    
    @objc func gk_setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        guard var leftItems = items else { return }
        
        if !GKConfigure.gk_disableFixSpace && leftItems.count > 0 {
            let firstItem = leftItems.first!
            let width = GKConfigure.gk_navItemLeftSpace - GKConfigure.gk_fixedSpace()
            if firstItem.width == width {
                self.gk_setLeftBarButtonItems(leftItems, animated: animated)
            }else {
                leftItems.insert(fixedSpace(width), at: 0)
                self.gk_setLeftBarButtonItems(leftItems, animated: animated)
            }
        }else {
            self.gk_setLeftBarButtonItems(leftItems, animated: animated)
        }
    }
    
    @objc func gk_setRightBarButtonItem(_ item: UIBarButtonItem?, animated: Bool) {
        if !GKConfigure.gk_disableFixSpace && item != nil {
            self.setRightBarButtonItems([item!], animated: animated)
        }else {
            self.setRightBarButtonItems(nil, animated: false)
            self.gk_setRightBarButtonItem(item, animated: animated)
        }
    }
    
    @objc func gk_setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        guard var rightItems = items else { return }
        if !GKConfigure.gk_disableFixSpace && rightItems.count > 0 {
            let firstItem = rightItems.first!
            let width = GKConfigure.gk_navItemRightSpace - GKConfigure.gk_fixedSpace()
            if firstItem.width == width {
                self.gk_setRightBarButtonItems(items, animated: animated)
            }else {
                rightItems.insert(fixedSpace(width), at: 0)
                self.gk_setRightBarButtonItems(rightItems, animated: animated)
            }
        }else {
            self.gk_setRightBarButtonItems(rightItems, animated: animated);
        }
    }
    
    fileprivate func fixedSpace(_ width: CGFloat) -> UIBarButtonItem {
        let fixedItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedItem.width = width
        return fixedItem
    }
}

extension NSObject: GKObjectAwakeProtocol {
    // MARK: - 重新系统方法
    private static let onceToken = UUID().uuidString
    public static func gkObjectAwake() {
        if #available(iOS 11.0, *) {
            let oriSels = ["_UINavigationBarContentView": "layoutSubviews", "_UINavigationBarContentViewLayout": "_updateMarginConstraints"]
            for (cls, sel) in oriSels {
                gk_swizzled_instanceMethod("gk", oldClass: NSClassFromString(cls), oldSelector: sel, newClass: NSObject.classForCoder())
            }
        }
    }
    
    @objc func gk_layoutSubviews() {
        gk_layoutSubviews()
        if GKConfigure.gk_disableFixSpace {
            return
        }
        
        if let cls = NSClassFromString("_UINavigationBarContentView") {
            if !self.isMember(of: cls) {
                return
            }
            
            let layout = self.value(forKey: "_layout") as? NSObject
            if layout == nil {
                return
            }
            let selector = NSSelectorFromString("_updateMarginConstraints")

            guard let result = layout?.responds(to: selector) else { return }
            
            if result {
                layout?.perform(selector)
            }
        }
    }
    
    @objc func gk__updateMarginConstraints() {
        gk__updateMarginConstraints()
        if GKConfigure.gk_disableFixSpace {
            return
        }
        
        if let cls = NSClassFromString("_UINavigationBarContentViewLayout") {
            if !self.isMember(of: cls) {
                return
            }
            
            gk_adjustLeadingBarConstraints()
            gk_adjustTrailingBarConstraints()
        }
    }
    
    fileprivate func gk_adjustLeadingBarConstraints() {
        if GKConfigure.gk_disableFixSpace {
            return
        }
        let leadingBarConstrainst: [NSLayoutConstraint]? = self.value(forKey: "_leadingBarConstraints") as? [NSLayoutConstraint]
        if leadingBarConstrainst == nil {
            return
        }
        let constant = GKConfigure.gk_navItemLeftSpace - GKConfigure.gk_fixedSpace()
        
        for constraint in leadingBarConstrainst! {
            if constraint.firstAttribute == .leading && constraint.secondAttribute == .leading {
                constraint.constant = constant
            }
        }
    }
    
    fileprivate func gk_adjustTrailingBarConstraints() {
        if GKConfigure.gk_disableFixSpace {
            return
        }
        
        let trailingBarConstraints: [NSLayoutConstraint]? = self.value(forKey: "_trailingBarConstraints") as? [NSLayoutConstraint]
        if trailingBarConstraints == nil {
            return
        }
        
        let constant = GKConfigure.gk_fixedSpace() - GKConfigure.gk_navItemRightSpace
        
        for constraint in trailingBarConstraints! {
            if constraint.firstAttribute == .trailing && constraint.secondAttribute == .trailing {
                constraint.constant = constant
            }
        }
    }
}
