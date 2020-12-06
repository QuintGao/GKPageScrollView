//
//  UINavigationController+GKExtension.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

extension UINavigationController {
    // 创建便利构造函数为UINavigationcontroller增加初始化方法
    public convenience init(rootVC: UIViewController) {
        self.init()
        gk_openGestureHandle = true
        gk_transitionScale = false
        pushViewController(rootVC, animated: true)
    }
    
    public convenience init(rootVC: UIViewController, scale: Bool) {
        self.init()
        gk_openGestureHandle = true
        gk_transitionScale = scale
        pushViewController(rootVC, animated: true)
    }
}

extension UINavigationController: GKChildAwakeProtocol {
    fileprivate struct AssociatedKeys {
        static var gkTransitionScale: Bool = false
        static var gkOpenScrollLeftPush: Bool = false
        static var gkOpenGestureHandle: Bool = false
        static var gkOpenSystemNavHandle: Bool = false
        static var screenPanGesture: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
        static var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
        static var transition: GKNavigationInteractiveTransition = GKNavigationInteractiveTransition()
    }
    
    public var gk_transitionScale: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkTransitionScale) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkTransitionScale, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var gk_openScrollLeftPush: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkOpenScrollLeftPush) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkOpenScrollLeftPush, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var gk_openGestureHandle: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkOpenGestureHandle) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkOpenGestureHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var gk_openSystemNavHandle: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkOpenSystemNavHandle) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkOpenSystemNavHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var screenPanGesture: UIScreenEdgePanGestureRecognizer {
        get {
            var panGesture = objc_getAssociatedObject(self, &AssociatedKeys.screenPanGesture) as? UIScreenEdgePanGestureRecognizer
            if panGesture == nil {
                panGesture = UIScreenEdgePanGestureRecognizer(target: self.interactiveTransition, action:#selector(self.interactiveTransition.panGestureAction(_:)))
                panGesture?.edges = .left
                panGesture?.delegate = self.interactiveTransition
                
                objc_setAssociatedObject(self, &AssociatedKeys.screenPanGesture, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return panGesture!
        }
    }
    
    var panGesture: UIPanGestureRecognizer {
        get {
            var panGesture = objc_getAssociatedObject(self, &AssociatedKeys.panGesture) as? UIPanGestureRecognizer
            if panGesture == nil {
                panGesture = UIPanGestureRecognizer(target: self.interactiveTransition, action: #selector(self.interactiveTransition.panGestureAction(_:)))
                panGesture?.maximumNumberOfTouches = 1
                panGesture?.delegate = self.interactiveTransition
                
                objc_setAssociatedObject(self, &AssociatedKeys.panGesture, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return panGesture!
        }
    }
    
    var interactiveTransition: GKNavigationInteractiveTransition {
        get {
            var transition = objc_getAssociatedObject(self, &AssociatedKeys.transition) as? GKNavigationInteractiveTransition
            if transition == nil {
                transition = GKNavigationInteractiveTransition()
                transition?.navigationController = self
                transition?.systemTarget = self.systemTarget
                transition?.systemAction = self.systemAction
                
                objc_setAssociatedObject(self, &AssociatedKeys.transition, transition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return transition!
        }
    }
    
    var systemTarget: Any? {
        get {
            let internalTargets = self.interactivePopGestureRecognizer?.value(forKey: "targets") as? [AnyObject]
            let internamTarget = internalTargets?.first?.value(forKey: "target")
            return internamTarget
        }
    }
    
    var systemAction: Selector {
        return NSSelectorFromString("handleNavigationTransition:")
    }
    
    // MARK: - 重新系统方法
    private static let onceToken = UUID().uuidString
    public static func gkChildAwake() {
        DispatchQueue.once(token: onceToken) {
            gk_swizzled_instanceMethod("gkNav", oldClass: self, oldSelector: "viewDidLoad", newClass: self)
            gk_swizzled_instanceMethod("gkNav", oldClass: self, oldSelector: "pushViewController:animated:", newClass: self)
        }
    }
    
    @objc func gkNav_viewDidLoad() {
        if self.gk_openGestureHandle {
            if self.isKind(of: UIImagePickerController.classForCoder()) {
                return
            }
            if self.isKind(of: UIVideoEditorController.classForCoder()) {
                return
            }
            
            // 设置背景色
            self.view.backgroundColor = UIColor.black
            
            // 设置代理
            self.delegate = self.interactiveTransition
            self.interactivePopGestureRecognizer?.isEnabled = false
            
            // 注册控制器属性改变通知
            NotificationCenter.default.addObserver(self, selector: #selector(propertyChangeNotification(_:)), name: GKViewControllerPropertyChanged, object: nil)
        }
        gkNav_viewDidLoad()
    }
    
    @objc func gkNav_pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.gk_openSystemNavHandle {
            self.isNavigationBarHidden = true
        }
        gkNav_pushViewController(viewController, animated: animated)
    }
    
    @objc func propertyChangeNotification(_ notify: Notification) {
        guard let obj = notify.object as? [String: Any] else { return }
        
        let vc: UIViewController = obj["viewController"] as! UIViewController
        
        // 不处理导航控制器和tabbar控制器
        if vc.isKind(of: UINavigationController.classForCoder()) { return }
        if vc.isKind(of: UITabBarController.classForCoder()) { return }
        if vc.navigationController == nil { return }
        if vc.navigationController != self { return }
        
        var exist = false
        
        if let shiledVCs = GKConfigure.shiledGuestureVCs {
            for obj in shiledVCs {
                if obj is UIViewController.Type {
                    if vc.isKind(of: obj as! UIViewController.Type) {
                        exist = true
                    }
                }else if obj is String {
                    if let cls = NSStringFromClass(vc.classForCoder).components(separatedBy: ".").last, let str = obj as? String {
                        if cls == str {
                            exist = true
                        }else if cls.contains(str) {
                            exist = true
                        }
                    }
                }
            }
        }
        if exist { return }
        
        // 手势处理
        if vc.gk_interactivePopDisabled { // 禁止滑动
            self.view.removeGestureRecognizer(self.screenPanGesture)
            self.view.removeGestureRecognizer(self.panGesture)
        }else if vc.gk_fullScreenPopDisabled { // 禁止全屏滑动，支持边缘滑动
            self.view.removeGestureRecognizer(self.panGesture)
            self.view.addGestureRecognizer(self.screenPanGesture)
            if vc.gk_systemGestureHandleDisabled {
                self.screenPanGesture.removeTarget(self.systemTarget, action: self.systemAction)
            }else {
                self.screenPanGesture.addTarget(self.systemTarget!, action: self.systemAction)
            }
        }else { // 支持全屏滑动
            self.view.removeGestureRecognizer(self.screenPanGesture)
            self.view.addGestureRecognizer(self.panGesture)
            if vc.gk_systemGestureHandleDisabled {
                self.panGesture.removeTarget(self.systemTarget, action: self.systemAction)
            }else {
                self.panGesture.addTarget(self.systemTarget!, action: self.systemAction)
            }
        }
    }
}

extension UINavigationController {
    open override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
