//
//  UIViewController+GKExtension.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

// 左滑push代理
@objc
public protocol GKViewControllerPushDelegate: NSObjectProtocol {
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
@objc
public protocol GKViewControllerPopDelegate: NSObjectProtocol {
    
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
@objc
public protocol GKGesturePopHandlerProtocol: NSObjectProtocol {
    // 是否可以通过手势pop返回
    @objc optional func navigationShouldPopOnGesture() -> Bool
}

public let GKViewControllerPropertyChanged = NSNotification.Name(rawValue: "GKViewControllerPropertyChanged")

extension UIViewController: GKAwakeProtocol {
   
    fileprivate struct AssociatedKeys {
        static var gkInteractivePopDisabled: Bool = false
        static var gkFullScreenPopDisabled: Bool = false
        static var gkSystemGestureHandleDisabled: Bool = false
        static var gkMaxPopDistance: CGFloat = 0
        static var gkNavBarAlpha: CGFloat = 1
        static var gkPushDelegate: GKViewControllerPushDelegate?
        static var gkPopDelegate: GKViewControllerPopDelegate?
        static var gkPushTransition: UIViewControllerAnimatedTransitioning?
        static var gkPopTransition: UIViewControllerAnimatedTransitioning?
        static var gkNavBarInit: Bool = false
        static var gkNavigationBar: GKNavigationBar = GKNavigationBar()
        static var gkNavigationItem: UINavigationItem = UINavigationItem()
        static var gkStatusBarHidden: Bool = GKConfigure.statusBarHidden
        static var gkStatusBarStyle: UIStatusBarStyle = GKConfigure.statusBarStyle
        static var gkBackImage: UIImage?
        static var gkBackStyle: GKNavigationBarBackStyle = .none
        static var gkNavBackgroundColor: UIColor?
        static var gkNavBackgroundImage: UIImage?
        static var gkNavShadowColor: UIColor?
        static var gkNavShadowImage: UIImage?
        static var gkNavLineHidden: Bool = false
        static var gkNavTitle: String?
        static var gkNavTitleView: UIView?
        static var gkNavTitleColor: UIColor?
        static var gkNavTitleFont: UIFont?
        static var gkNavLeftBarButtonItem: UIBarButtonItem?
        static var gkNavLeftBarButtonItems: [UIBarButtonItem]?
        static var gkNavRightBarButtonItem: UIBarButtonItem?
        static var gkNavRightBarButtonItems: [UIBarButtonItem]?
        static var gkNavItemLeftSpace: CGFloat = GKConfigure.gk_navItemLeftSpace
        static var gkNavItemRightSpace: CGFloat = GKConfigure.gk_navItemRightSpace
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
    
    public var gk_navBarAlpha: CGFloat {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkNavBarAlpha) as? CGFloat else { return 1 }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavBarAlpha, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_navigationBar.gk_navBarBackgroundAlpha = newValue
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
    
    fileprivate var gk_navBarInit: Bool {
        get {
            guard let isInit = objc_getAssociatedObject(self, &AssociatedKeys.gkNavBarInit) as? Bool else { return false }
            return isInit
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavBarInit, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var gk_navigationBar: GKNavigationBar {
        get {
            var navigationBar = objc_getAssociatedObject(self, &AssociatedKeys.gkNavigationBar) as? GKNavigationBar
            if navigationBar == nil {
                navigationBar = GKNavigationBar()
                self.view.addSubview(navigationBar!)
                
                self.gk_navBarInit = true
                self.gk_navigationBar = navigationBar!
            }
            
            return navigationBar!
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavigationBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            setupNavBarAppearance()
            setupNavBarFrame()
        }
    }
    
    public var gk_navigationItem: UINavigationItem {
        get {
            var item = objc_getAssociatedObject(self, &AssociatedKeys.gkNavigationItem) as? UINavigationItem
            if item == nil {
                item = UINavigationItem()
                self.gk_navigationItem = item!
            }
            return item!
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavigationItem, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_navigationBar.items = [newValue]
        }
    }
    
    public var gk_statusBarHidden: Bool {
        get {
            guard let isHidden = objc_getAssociatedObject(self, &AssociatedKeys.gkStatusBarHidden) as? Bool else { return false }
            return isHidden
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkStatusBarHidden, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public var gk_statusBarStyle: UIStatusBarStyle {
        get {
            guard let style = objc_getAssociatedObject(self, &AssociatedKeys.gkStatusBarStyle) as? UIStatusBarStyle else { return GKConfigure.statusBarStyle }
            return style
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkStatusBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public var gk_backImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkBackImage) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkBackImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            setBackItemImage(image: newValue)
        }
    }
    
    public var gk_backStyle: GKNavigationBarBackStyle {
        get {
            guard let style = objc_getAssociatedObject(self, &AssociatedKeys.gkBackStyle) as? GKNavigationBarBackStyle else { return .none }
            return style
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkBackStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            setBackItemImage(image: self.gk_backImage)
        }
    }
    
    public var gk_navItemLeftSpace: CGFloat {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkNavItemLeftSpace) as? CGFloat else { return GKNavigationBarItemSpace }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavItemLeftSpace, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if newValue == GKNavigationBarItemSpace {
                return
            }
            
            GKConfigure.update { (configure) in
                configure.gk_navItemLeftSpace = newValue
            }
        }
    }
    
    public var gk_navItemRightSpace: CGFloat {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkNavItemRightSpace) as? CGFloat else { return GKNavigationBarItemSpace }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavItemRightSpace, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if newValue == GKNavigationBarItemSpace {
                return
            }
            
            GKConfigure.update { (configure) in
                configure.gk_navItemRightSpace = newValue
            }
        }
    }
    
    public var gk_navBackgroundColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavBackgroundColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if newValue != nil {
                self.gk_navigationBar.setBackgroundImage(UIImage.gk_image(with: newValue!), for: .default)
            }
        }
    }
    
    public var gk_navBackgroundImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavBackgroundImage) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavBackgroundImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_navigationBar.setBackgroundImage(newValue, for: .default)
        }
    }
    
    public var gk_navShadowColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavShadowColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavShadowColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            guard let shadowColor = newValue else { return }
            
            self.gk_navigationBar.shadowImage = UIImage.gk_change(with: UIImage.gk_image(with: "nav_line"), color: shadowColor)
        }
    }
    
    public var gk_navShadowImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavShadowImage) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavShadowImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_navigationBar.shadowImage = newValue
        }
    }
    
    public var gk_navLineHidden: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkNavLineHidden) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavLineHidden, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_navigationBar.gk_navLineHidden = newValue
            
            if #available(iOS 11.0, *) {
                var shadowImage: UIImage?
                if newValue {
                    shadowImage = UIImage()
                }else if self.gk_navShadowImage != nil {
                    shadowImage = self.gk_navShadowImage
                }else if self.gk_navShadowColor != nil {
                    shadowImage = UIImage.gk_change(with: UIImage.gk_image(with: "nav_line"), color: self.gk_navShadowColor!)
                }
                
                self.gk_navigationBar.shadowImage = shadowImage
            }
            self.gk_navigationBar.layoutSubviews()
        }
    }
    
    public var gk_navTitle: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavTitle) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavTitle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_navigationItem.title = newValue
        }
    }
    
    public var gk_navTitleView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavTitleView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavTitleView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_navigationItem.titleView = newValue
        }
    }
    
    public var gk_navTitleColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavTitleColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavTitleColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if newValue != nil && self.gk_navTitleFont != nil {
                self.gk_navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: newValue!, NSAttributedString.Key.font: self.gk_navTitleFont!]
            }
        }
    }
    
    public var gk_navTitleFont: UIFont? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavTitleFont) as? UIFont
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavTitleFont, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if newValue != nil && self.gk_navTitleColor != nil {
                self.gk_navigationBar.titleTextAttributes = [NSAttributedString.Key.font: newValue!, NSAttributedString.Key.foregroundColor: self.gk_navTitleColor!]
            }
        }
    }
    
    public var gk_navLeftBarButtonItem: UIBarButtonItem? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavLeftBarButtonItem) as? UIBarButtonItem
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavLeftBarButtonItem, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_navigationItem.leftBarButtonItem = newValue
        }
    }
    
    public var gk_navLeftBarButtonItems: [UIBarButtonItem]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavLeftBarButtonItems) as? [UIBarButtonItem]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavLeftBarButtonItems, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_navigationItem.leftBarButtonItems = newValue
        }
    }
    
    public var gk_navRightBarButtonItem: UIBarButtonItem? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavRightBarButtonItem) as? UIBarButtonItem
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavRightBarButtonItem, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_navigationItem.rightBarButtonItem = newValue
        }
    }
    
    public var gk_navRightBarButtonItems: [UIBarButtonItem]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavRightBarButtonItems) as? [UIBarButtonItem]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavRightBarButtonItems, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_navigationItem.rightBarButtonItems = newValue
        }
    }
    
    var hasPushDelegate: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.hasPushDelegate) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.hasPushDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var hasPopDelegate: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.hasPopDelegate) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.hasPopDelegate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - 重新系统方法
    private static let onceToken = UUID().uuidString
    @objc public static func gkAwake() {
        DispatchQueue.once(token: onceToken) {
            let oriSels = ["viewDidLoad",
                           "viewWillAppear:",
                           "viewDidAppear:",
                           "viewWillLayoutSubviews"]
            
            for oriSel in oriSels {
                gk_swizzled_instanceMethod("gk", oldClass: self, oldSelector: oriSel, newClass: self)
            }
            
            let gestureOriSels = ["viewWillAppear:", "viewDidDisappear:"]
            
            for oriSel in gestureOriSels {
                gk_swizzled_instanceMethod("gkGesture", oldClass: self, oldSelector: oriSel, newClass: self)
            }
        }
    }
    
    @objc func gk_viewDidLoad() {
        // 初始化导航栏间距
        self.gk_navItemLeftSpace  = GKNavigationBarItemSpace
        self.gk_navItemRightSpace = GKNavigationBarItemSpace
        
        // 判断是否需要屏蔽导航栏间距调整
        var exist = false
        if let shiledVCs = GKConfigure.shiledItemSpaceVCs {
            for obj in shiledVCs {
                if obj is UIViewController.Type {
                    if self.isKind(of: obj as! UIViewController.Type) {
                        exist = true
                    }
                }else if obj is String {
                    if let cls = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last, let str = obj as? String {
                        if cls == str {
                            exist = true
                        }else if cls.contains(str) {
                            exist = true
                        }
                    }
                }
            }
        }
        
        GKConfigure.update { (configure) in
            configure.gk_disableFixSpace = exist
        }
        
        gk_viewDidLoad()
    }
    
    @objc func gk_viewWillAppear(_ animated: Bool) {
        if self.isKind(of: UINavigationController.classForCoder()) { return }
        if self.isKind(of: UITabBarController.classForCoder()) { return }
        if self.isKind(of: UIImagePickerController.classForCoder()) { return }
        if self.isKind(of: UIVideoEditorController.classForCoder()) { return }
        if self.isKind(of: UIAlertController.classForCoder()) { return }
        if NSStringFromClass(self.classForCoder).components(separatedBy: ".").last == "PUPhotoPickerHostViewController" { return }
        if self.navigationController == nil { return }
        
        if self.gk_navBarInit {
            // 隐藏系统导航栏
            if self.navigationController?.gk_openSystemNavHandle == false {
                self.navigationController?.isNavigationBarHidden = true
            }
            
            // 将自定义的导航栏放置顶层
            if !self.gk_navigationBar.isHidden {
                self.view.bringSubviewToFront(self.gk_navigationBar)
            }
            
            // 状态栏
            self.gk_navigationBar.gk_statusBarHidden = self.gk_statusBarHidden
        }
        
        // 允许调整导航栏间距
        if !GKConfigure.gk_disableFixSpace {
            if self.gk_navItemLeftSpace == GKNavigationBarItemSpace {
                self.gk_navItemLeftSpace = GKConfigure.navItemLeftSpace
            }
            
            if self.gk_navItemRightSpace == GKNavigationBarItemSpace {
                self.gk_navItemRightSpace = GKConfigure.navItemRightSpace
            }
            
            // 重置navItem_space
            GKConfigure.update { (configure) in
                configure.gk_navItemLeftSpace = self.gk_navItemLeftSpace
                configure.gk_navItemRightSpace = self.gk_navItemRightSpace
            }
        }
        
        gk_viewWillAppear(animated)
    }
    
    @objc func gk_viewDidAppear(_ animated: Bool) {
        // 每次视图出现时重新设置当前控制器的手势
        postPropertyChangeNotification()
        
        if self.gk_navBarInit && self.navigationController?.isNavigationBarHidden == false {
            self.navigationController?.isNavigationBarHidden = true
        }
        
        gk_viewDidAppear(animated)
    }
    
    @objc func gk_viewWillLayoutSubviews() {
        if self.gk_navBarInit {
            setupNavBarFrame()
        }
        gk_viewWillLayoutSubviews()
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
    
    @objc func gkGesture_viewDidDisappear(_ animated: Bool) {
        if let delegate = self.gk_pushDelegate {
            if delegate as! NSObject == self {
                self.hasPushDelegate = true
            }
        }
        
        if let delegate = self.gk_popDelegate {
            if delegate as! NSObject == self {
                self.hasPopDelegate = true
            }
        }
        
        // 这两个代理系统不会自动回收，所以要做下处理
        self.gk_pushDelegate = nil;
        self.gk_popDelegate = nil;

        gkGesture_viewDidDisappear(animated)
    }
    
    fileprivate func setupNavBarAppearance() {
        // 设置默认背景色
        if self.gk_navBackgroundColor == nil {
            self.gk_navBackgroundColor = GKConfigure.backgroundColor
        }
        
        // 设置默认标题字体
        if self.gk_navTitleFont == nil {
            self.gk_navTitleFont = GKConfigure.titleFont
        }
        
        // 设置默认标题颜色
        if self.gk_navTitleColor == nil {
            self.gk_navTitleColor = GKConfigure.titleColor
        }
        
        // 设置默认返回按钮图片
        if self.gk_backImage == nil {
            self.gk_backImage = GKConfigure.backImage
        }
        
        // 设置默认返回样式
        if self.gk_backStyle == .none {
            self.gk_backStyle = GKConfigure.backStyle
        }
    }
    
    fileprivate func setupNavBarFrame() {
        let width  = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        var navBarH: CGFloat = 0.0
        if width > height { // 横屏
            if GK_IS_IPAD {
                let statusBarH = UIApplication.shared.statusBarFrame.size.height
                let navigaBarH = self.navigationController?.navigationBar.frame.size.height ?? 44
                navBarH = statusBarH + navigaBarH
            }else if GK_NOTCHED_SCREEN {
                navBarH = GK_NAVBAR_HEIGHT
            }else {
                if width == 736.0 && height == 414.0 { // plus横屏
                    navBarH = self.gk_statusBarHidden ? GK_NAVBAR_HEIGHT : GK_STATUSBAR_NAVBAR_HEIGHT
                }else { // 其他机型横屏
                    navBarH = self.gk_statusBarHidden ? 32.0 : 52.0
                }
            }
        }else { // 竖屏
            navBarH = self.gk_statusBarHidden ? (GK_SAFEAREA_TOP + GK_NAVBAR_HEIGHT) : GK_STATUSBAR_NAVBAR_HEIGHT
        }
        self.gk_navigationBar.frame = CGRect(x: 0, y: 0, width: width, height: navBarH)
        self.gk_navigationBar.gk_statusBarHidden = self.gk_statusBarHidden
        self.gk_navigationBar.layoutSubviews()
    }
    
    fileprivate func postPropertyChangeNotification() {
        NotificationCenter.default.post(name: GKViewControllerPropertyChanged, object: ["viewController": self])
    }
    
    fileprivate func setBackItemImage(image: UIImage?) {
        if self.gk_navBarInit == false { return }
        
        var backImage = image
        
        // 根控制器不作处理
        guard let count = self.navigationController?.children.count else { return }
        if (count<=1) { return }
        
        if backImage == nil {
            if self.gk_backStyle != .none {
                let imageName = self.gk_backStyle == .black ? "btn_back_black" : "btn_back_white"
                backImage = UIImage.gk_image(with: imageName)
            }
        }
        
        if backImage == nil { return }
        
        self.gk_navLeftBarButtonItem = UIBarButtonItem.gk_item(image: backImage, target: self, action: #selector(backItemClick(_:)))
    }
    
    @objc open func backItemClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Public Methods
    public func refreshNavBarFrame() {
        self.setupNavBarFrame()
    }
    
    public func gk_visibleViewControllerIfExist() -> UIViewController? {
        if self.presentedViewController != nil {
            return self.presentedViewController?.gk_visibleViewControllerIfExist()
        }
        
        if self.isKind(of: UINavigationController.classForCoder()) {
            let navVC = self as? UINavigationController
            
            return navVC?.visibleViewController?.gk_visibleViewControllerIfExist()
        }
        
        if self.isKind(of: UITabBarController.classForCoder()) {
            let tabbarVC = self as? UITabBarController
            return tabbarVC?.selectedViewController?.gk_visibleViewControllerIfExist()
        }
        
        if self.isViewLoaded && self.view.window != nil {
            return self
        }else {
            print("找不到可见的控制器，viewController.self=\(self)，self.view.window=\(String(describing: self.view.window))")
            return nil
        }
    }
}

extension UIViewController: GKGesturePopHandlerProtocol {
    open func navigationShouldPopOnGesture() -> Bool {
        return true
    }
}

