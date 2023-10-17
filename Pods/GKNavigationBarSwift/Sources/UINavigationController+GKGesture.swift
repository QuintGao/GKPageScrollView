//
//  UINavigationController+GKGesture.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2022/3/18.
//  Copyright © 2022 QuintGao. All rights reserved.
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

extension UINavigationController: GKGestureChildAwakeProtocol {
    // MARK: - 重新系统方法
    private static let onceToken = UUID().uuidString
    public static func gkGestureChildAwake() {
        DispatchQueue.once(token: onceToken) {
            let oriSels = ["viewDidLoad",
                           "pushViewController:animated:",
                           "navigationBar:shouldPopItem:"
            ]
            
            for oriSel in oriSels {
                gk_swizzled_instanceMethod("gkNavGesture", oldClass: self, oldSelector: oriSel, newClass: self)
            }
        }
    }
    
    @objc func gkNavGesture_viewDidLoad() {
        if self.gk_openGestureHandle {
            if self.isKind(of: UIImagePickerController.self) {
                return
            }
            if self.isKind(of: UIVideoEditorController.self) {
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
        gkNavGesture_viewDidLoad()
    }
    
    @objc func gkNavGesture_pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.children.count > 0 {
            let rootVC = self.children.first!
            // 获取tabbar截图
            if viewController.gk_systemGestureHandleDisabled && rootVC.gk_captureImage == nil {
                rootVC.gk_captureImage = GKConfigure.getCapture(with: rootVC.view.window ?? rootVC.view)
            }
            // 设置push时是否隐藏tabbar
            if GKConfigure.gk_hidesBottomBarWhenPushed && rootVC != viewController {
                viewController.hidesBottomBarWhenPushed = true
            }
        }
        gkNavGesture_pushViewController(viewController, animated: animated)
    }
    
    // source：https://github.com/onegray/UIViewController-BackButtonHandler
    @objc func gkNavGesture_navigationBar(_ navigationBar: UINavigationBar, shouldPopItem: UINavigationItem) -> Bool {
        if self.viewControllers.count < navigationBar.items?.count ?? 0 {
            return true
        }
        
        var shouldPop = self.topViewController?.navigationShouldPop()
        
        let selector = NSSelectorFromString("navigationShouldPopOnClick")
        if let vc = self.topViewController, vc.responds(to: selector) {
            if vc.perform(selector) != nil {
                shouldPop = true
            }else {
                shouldPop = false
            }
        }
        
        if shouldPop == true {
            DispatchQueue.main.async { [self] in
                popViewController(animated: true)
            }
        }else {
            // Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
            for subview in navigationBar.subviews {
                if 0.0 < subview.alpha && subview.alpha < 1.0 {
                    UIView.animate(withDuration: 0.25) {
                        subview.alpha = 1.0
                    }
                }
            }
        }
        
        return false
    }
    
    @objc func propertyChangeNotification(_ notify: Notification) {
        guard let obj = notify.object as? [String: Any] else { return }
        
        let vc: UIViewController = obj["viewController"] as! UIViewController
        
        // 不处理导航控制器和tabbar控制器
        if vc.isKind(of: UINavigationController.self) { return }
        if vc.isKind(of: UITabBarController.self) { return }
        if vc.navigationController == nil { return }
        if vc.navigationController != self { return }
        // 修复非导航控制器子类时出现的问题
        if vc.parent != self { return }
        
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
    fileprivate struct AssociatedKeys {
        static var gkTransitionScale: Void?
        static var gkOpenScrollLeftPush: Void?
        static var gkOpenGestureHandle: Void?
        static var screenPanGesture: Void?
        static var panGesture: Void?
        static var transition: Void?
    }
    
    public var gk_transitionScale: Bool {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkTransitionScale) as? Bool else { return false }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkTransitionScale, newValue)
        }
    }
    
    public var gk_openScrollLeftPush: Bool {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkOpenScrollLeftPush) as? Bool else { return false }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkOpenScrollLeftPush, newValue)
        }
    }
    
    fileprivate var gk_openGestureHandle: Bool {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkOpenGestureHandle) as? Bool else { return false }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkOpenGestureHandle, newValue)
        }
    }
    
    var screenPanGesture: UIScreenEdgePanGestureRecognizer {
        get {
            var panGesture = gk_getAssociatedObject(self, &AssociatedKeys.screenPanGesture) as? UIScreenEdgePanGestureRecognizer
            if panGesture == nil {
                panGesture = UIScreenEdgePanGestureRecognizer(target: self.interactiveTransition, action:#selector(self.interactiveTransition.panGestureAction(_:)))
                panGesture?.edges = .left
                panGesture?.delegate = self.interactiveTransition
                
                gk_setAssociatedObject(self, &AssociatedKeys.screenPanGesture, panGesture)
            }
            return panGesture!
        }
    }
    
    var panGesture: UIPanGestureRecognizer {
        get {
            var panGesture = gk_getAssociatedObject(self, &AssociatedKeys.panGesture) as? UIPanGestureRecognizer
            if panGesture == nil {
                panGesture = UIPanGestureRecognizer(target: self.interactiveTransition, action: #selector(self.interactiveTransition.panGestureAction(_:)))
                panGesture?.maximumNumberOfTouches = 1
                panGesture?.delegate = self.interactiveTransition
                
                gk_setAssociatedObject(self, &AssociatedKeys.panGesture, panGesture)
            }
            return panGesture!
        }
    }
    
    var interactiveTransition: GKNavigationInteractiveTransition {
        get {
            var transition = gk_getAssociatedObject(self, &AssociatedKeys.transition) as? GKNavigationInteractiveTransition
            if transition == nil {
                transition = GKNavigationInteractiveTransition()
                transition?.navigationController = self
                transition?.systemTarget = self.systemTarget
                transition?.systemAction = self.systemAction
                
                gk_setAssociatedObject(self, &AssociatedKeys.transition, transition)
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
}

extension UINavigationController {
    open override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
