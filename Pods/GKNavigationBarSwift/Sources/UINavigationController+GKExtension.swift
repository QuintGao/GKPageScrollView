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
        static var screenPanGesture: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
        static var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
        static var navigationHandle: GKNavigationControllerDelegateHandler = GKNavigationControllerDelegateHandler()
        static var gestureHandle: GKGestureRecognizerDelegateHandler = GKGestureRecognizerDelegateHandler()
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
    
    var screenPanGesture: UIScreenEdgePanGestureRecognizer {
        get {
            var panGesture = objc_getAssociatedObject(self, &AssociatedKeys.screenPanGesture) as? UIScreenEdgePanGestureRecognizer
            if panGesture == nil {
                panGesture = UIScreenEdgePanGestureRecognizer(target: self.navigationHandler, action:#selector(self.navigationHandler.panGestureAction(_:)))
                panGesture?.edges = .left
                
                objc_setAssociatedObject(self, &AssociatedKeys.screenPanGesture, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return panGesture!
        }
    }
    
    var panGesture: UIPanGestureRecognizer {
        get {
            var panGesture = objc_getAssociatedObject(self, &AssociatedKeys.panGesture) as? UIPanGestureRecognizer
            if panGesture == nil {
                panGesture = UIPanGestureRecognizer()
                panGesture?.maximumNumberOfTouches = 1
                
                objc_setAssociatedObject(self, &AssociatedKeys.panGesture, panGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return panGesture!
        }
    }
    
    var navigationHandler: GKNavigationControllerDelegateHandler {
        get {
            var handler = objc_getAssociatedObject(self, &AssociatedKeys.navigationHandle) as? GKNavigationControllerDelegateHandler
            if handler == nil {
                handler = GKNavigationControllerDelegateHandler()
                handler?.navigationController = self
                
                objc_setAssociatedObject(self, &AssociatedKeys.navigationHandle, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return handler!
        }
    }
    
    var gestureHandler: GKGestureRecognizerDelegateHandler {
        get {
            var handler = objc_getAssociatedObject(self, &AssociatedKeys.gestureHandle) as? GKGestureRecognizerDelegateHandler
            if handler == nil {
                handler = GKGestureRecognizerDelegateHandler()
                handler?.navigationController = self
                handler?.systemTarget = self.systemTarget
                handler?.customTarget = self.navigationHandler
                
                objc_setAssociatedObject(self, &AssociatedKeys.gestureHandle, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return handler!
        }
    }
    
    var systemTarget: Any? {
        get {
            let internalTargets = self.interactivePopGestureRecognizer?.value(forKey: "targets") as? [AnyObject]
            let internamTarget = internalTargets?.first?.value(forKey: "target")
            return internamTarget
        }
    }
    
    // MARK: - 重新系统方法
    private static let onceToken = UUID().uuidString
    public static func gkChildAwake() {
        DispatchQueue.once(token: onceToken) {
            gk_swizzled_instanceMethod("gkNav", oldClass: self, oldSelector: "viewDidLoad", newClass: self)
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
            self.delegate = self.navigationHandler
            
            // 注册控制器属性改变通知
            NotificationCenter.default.addObserver(self, selector: #selector(propertyChangeNotification(_:)), name: GKViewControllerPropertyChanged, object: nil)
        }
        gkNav_viewDidLoad()
    }
    
    @objc func propertyChangeNotification(_ notify: Notification) {
        guard let obj = notify.object as? [String: Any] else { return }
        
        let vc: UIViewController = obj["viewController"] as! UIViewController
        
        // 不处理导航控制器和tabbar控制器
        if vc.isKind(of: UINavigationController.classForCoder()) { return }
        if vc.isKind(of: UITabBarController.classForCoder()) { return }
        if vc.navigationController == nil { return }
        
        var exist = false
        
        if let shiledVCs = GKConfigure.shiledGuestureVCs {
            for obj in shiledVCs {
                if obj is UIViewController.Type {
                    if vc.isKind(of: obj as! UIViewController.Type) {
                        exist = true
                    }
                }else if obj is String {
                    if NSStringFromClass(vc.classForCoder).components(separatedBy: ".").last == (obj as! String) {
                        exist = true
                    }
                }
            }
        }
        if exist { return }
        
        let isRootVC = vc == self.viewControllers.first
        
        // 手势处理
        if vc.gk_interactivePopDisabled { // 禁止滑动
            self.interactivePopGestureRecognizer?.delegate = nil
            self.interactivePopGestureRecognizer?.isEnabled = false
            self.interactivePopGestureRecognizer?.view?.removeGestureRecognizer(self.screenPanGesture)
            self.interactivePopGestureRecognizer?.view?.removeGestureRecognizer(self.panGesture)
        }else if vc.gk_fullScreenPopDisabled { // 禁止全屏滑动，支持边缘滑动
            self.interactivePopGestureRecognizer?.view?.removeGestureRecognizer(self.panGesture)
            
            if self.gk_transitionScale {
                self.interactivePopGestureRecognizer?.delegate = nil
                self.interactivePopGestureRecognizer?.isEnabled = false
                
                if self.interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(self.screenPanGesture) == false {
                    self.interactivePopGestureRecognizer?.view?.addGestureRecognizer(self.screenPanGesture)
                    self.screenPanGesture.delegate = self.gestureHandler
                }
            }else {
                self.interactivePopGestureRecognizer?.delaysTouchesBegan = true
                self.interactivePopGestureRecognizer?.delegate = self.gestureHandler
                self.interactivePopGestureRecognizer?.isEnabled = !isRootVC
            }
        }else { // 支持全屏滑动
            self.interactivePopGestureRecognizer?.delegate = nil
            self.interactivePopGestureRecognizer?.isEnabled = false
            self.interactivePopGestureRecognizer?.view?.removeGestureRecognizer(self.screenPanGesture)
            
            // 给self.interactivePopGestureRecognizer.view添加全屏滑动手势
            if !isRootVC && self.interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(self.panGesture) == false {
                self.interactivePopGestureRecognizer?.view?.addGestureRecognizer(self.panGesture)
                self.panGesture.delegate = self.gestureHandler
            }
            
            // 手势处理
            if self.gk_transitionScale || self.gk_openScrollLeftPush {
                self.panGesture.addTarget(self.navigationHandler, action: #selector(self.navigationHandler.panGestureAction(_:)))
            }else {
                let internalAction = NSSelectorFromString("handleNavigationTransition:")
                
                if self.systemTarget != nil {
                    self.panGesture.addTarget(self.systemTarget!, action: internalAction)
                }
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
