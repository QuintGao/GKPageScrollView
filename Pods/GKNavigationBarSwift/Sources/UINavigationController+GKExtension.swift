//
//  UINavigationController+GKExtension.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

extension UINavigationController: GKChildAwakeProtocol {
    // MARK: - 重新系统方法
    private static let onceToken = UUID().uuidString
    public static func gkChildAwake() {
        DispatchQueue.once(token: onceToken) {
            gk_swizzled_instanceMethod("gkNav", oldClass: self, oldSelector: "pushViewController:animated:", newClass: self)
        }
    }
    
    @objc func gkNav_pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.gk_openSystemNavHandle {
            self.isNavigationBarHidden = true
        }
        gkNav_pushViewController(viewController, animated: animated)
    }
}

extension UINavigationController {
    fileprivate struct AssociatedKeys {
        static var gkOpenSystemNavHandle: Void?
        static var gkHideNavigationBar: Void?
    }
    
    public var gk_openSystemNavHandle: Bool {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkOpenSystemNavHandle) as? Bool else { return false }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkOpenSystemNavHandle, newValue)
        }
    }
    
    public var gk_hideNavigationBar: Bool {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkHideNavigationBar) as? Bool else { return false }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkHideNavigationBar, newValue)
        }
    }
}
