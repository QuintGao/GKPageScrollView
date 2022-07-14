//
//  UIViewController+GKGesture.swift
//  GKNavigationBarSwift
//
//  Created by gaokun on 2022/3/18.
//  Copyright © 2022 QuintGao. All rights reserved.
//

import UIKit

// 左滑push代理
@objc public protocol GKViewControllerPushDelegate: NSObjectProtocol {
    /// 左滑push，在这里创建将要push的控制器
    @objc optional func pushToNextViewController()
    
    /// push手势滑动开始
    @objc optional func viewControllerPushScrollBegan()
    
    /// push手势滑动进度更新
    /// - Parameter progress: 进度（0-1）
    @objc optional func viewControllerPushScrollUpdate(progress: CGFloat)
    
    /// push手势滑动结束
    /// - Parameter finished: 是否完成push操作（true：push成功 false：push取消）
    @objc optional func viewControllerPushScrollEnded(finished: Bool)
}

// 右滑pop代理
@objc public protocol GKViewControllerPopDelegate: NSObjectProtocol {
    
    /// pop手势滑动开始
    @objc optional func viewControllerPopScrollBegan()
    
    /// pop手势滑动进度更新
    /// - Parameter progress: 进度（0-1）
    @objc optional func viewControllerPopScrollUpdate(progress: CGFloat)
    
    /// pop手势滑动结束
    /// - Parameter finished: 是否完成pop操作（true：pop成功 false：pop取消）
    @objc optional func viewControllerPopScrollEnded(finished: Bool)
}

// 返回拦截
@objc public protocol GKGesturePopHandlerProtocol: NSObjectProtocol {
    /// 是否可以返回，包括点击返回和手势返回，默认YES
    @objc func navigationShouldPop() -> Bool
    
    /// 是否可以手势返回
    @objc optional func navigationShouldPopOnGesture() -> Bool
    
    /// 是否可以点击返回
    @objc optional func navigationShouldPopOnClick() -> Bool
}

public let GKViewControllerPropertyChanged = NSNotification.Name(rawValue: "GKViewControllerPropertyChanged")

extension UIViewController: GKGestureAwakeProtocol {
    // MARK: - 重新系统方法
    private static let onceToken = UUID().uuidString
    @objc public static func gkGestureAwake() {
        DispatchQueue.once(token: onceToken) {
            let oriSels = ["viewWillAppear:",
                           "viewDidAppear:",
                           "viewDidDisappear:"]
            
            for oriSel in oriSels {
                gk_swizzled_instanceMethod("gkGesture", oldClass: self, oldSelector: oriSel, newClass: self)
            }
        }
    }
    
    @objc func gkGesture_viewWillAppear(_ animated: Bool) {
        if self.hasPushDelegate {
            self.gk_pushDelegate = self as? GKViewControllerPushDelegate
            self.hasPushDelegate = false
        }
        if self.hasPopDelegate {
            self.gk_popDelegate = self as? GKViewControllerPopDelegate
            self.hasPopDelegate = false
        }
        gkGesture_viewWillAppear(animated)
    }
    
    @objc func gkGesture_viewDidAppear(_ animated: Bool) {
        postPropertyChangeNotification()
        gkGesture_viewDidAppear(animated)
    }
    
    @objc func gkGesture_viewDidDisappear(_ animated: Bool) {
        if let delegate = self.gk_pushDelegate as? NSObject, delegate == self {
            self.hasPushDelegate = true
        }
        
        if let delegate = self.gk_popDelegate as? NSObject, delegate == self {
            self.hasPopDelegate = true
        }
        
        // 这两个代理系统不会自动回收，所以要做下处理
        self.gk_pushDelegate = nil;
        self.gk_popDelegate = nil;

        gkGesture_viewDidDisappear(animated)
    }
    
    fileprivate func postPropertyChangeNotification() {
        NotificationCenter.default.post(name: GKViewControllerPropertyChanged, object: ["viewController": self])
    }
}

extension UIViewController {
    fileprivate struct AssociatedKeys {
        static var gkInteractivePopDisabled: Bool = false
        static var gkFullScreenPopDisabled: Bool = false
        static var gkSystemGestureHandleDisabled: Bool = false
        static var gkMaxPopDistance: CGFloat = 0
        static var gkPushDelegate: GKViewControllerPushDelegate?
        static var gkPopDelegate: GKViewControllerPopDelegate?
        static var gkPushTransition: UIViewControllerAnimatedTransitioning?
        static var gkPopTransition: UIViewControllerAnimatedTransitioning?
        static var hasPushDelegate: Bool = false
        static var hasPopDelegate: Bool = false
    }
    
    public var gk_interactivePopDisabled: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkInteractivePopDisabled) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkInteractivePopDisabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            postPropertyChangeNotification()
        }
    }
    
    public var gk_fullScreenPopDisabled: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkFullScreenPopDisabled) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkFullScreenPopDisabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            postPropertyChangeNotification()
        }
    }
    
    public var gk_systemGestureHandleDisabled: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkSystemGestureHandleDisabled) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkSystemGestureHandleDisabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            postPropertyChangeNotification()
        }
    }
    
    public var gk_maxPopDistance: CGFloat {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkMaxPopDistance) as? CGFloat else { return 0 }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkMaxPopDistance, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            postPropertyChangeNotification()
        }
    }
    
    public var gk_pushDelegate: GKViewControllerPushDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkPushDelegate) as? GKViewControllerPushDelegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkPushDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var gk_popDelegate: GKViewControllerPopDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkPopDelegate) as? GKViewControllerPopDelegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkPopDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var gk_pushTransition: UIViewControllerAnimatedTransitioning? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkPushTransition) as? UIViewControllerAnimatedTransitioning
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkPushTransition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var gk_popTransition: UIViewControllerAnimatedTransitioning? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkPopTransition) as? UIViewControllerAnimatedTransitioning
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkPopTransition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var hasPushDelegate: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.hasPushDelegate) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.hasPushDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var hasPopDelegate: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.hasPopDelegate) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.hasPopDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIViewController: GKGesturePopHandlerProtocol {
    open func navigationShouldPop() -> Bool {
        return true
    }
}
