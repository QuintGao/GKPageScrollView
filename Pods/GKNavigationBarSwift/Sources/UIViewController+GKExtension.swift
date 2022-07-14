//
//  UIViewController+GKExtension.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

extension UIViewController: GKAwakeProtocol {
   
    fileprivate struct AssociatedKeys {
        static var gkNavBarAlpha: CGFloat = 1
        static var gkNavBarInit: Bool = false
        static var gkNavBarAdded: Bool = false
        static var gkNavigationBar: GKNavigationBar = GKNavigationBar()
        static var gkNavigationItem: UINavigationItem = UINavigationItem()
        static var gkStatusBarHidden: Bool = GKConfigure.statusBarHidden
        static var gkStatusBarStyle: UIStatusBarStyle = GKConfigure.statusBarStyle
        static var gkBackImage: UIImage?
        static var gkDarkBackImage: UIImage?
        static var gkBlackBackImage: UIImage?
        static var gkWhiteBackImage: UIImage?
        static var gkBackStyle: GKNavigationBarBackStyle = .none
        static var gkNavBackgroundColor: UIColor?
        static var gkNavBackgroundImage: UIImage?
        static var gkDarkNavBackgroundImage: UIImage?
        static var gkNavShadowColor: UIColor?
        static var gkNavShadowImage: UIImage?
        static var gkDarkNavShadowImage: UIImage?
        static var gkNavLineHidden: Bool = false
        static var gkNavTitle: String?
        static var gkNavTitleView: UIView?
        static var gkNavTitleColor: UIColor?
        static var gkNavTitleFont: UIFont?
        static var gkNavLeftBarButtonItem: UIBarButtonItem?
        static var gkNavLeftBarButtonItems: [UIBarButtonItem]?
        static var gkNavRightBarButtonItem: UIBarButtonItem?
        static var gkNavRightBarButtonItems: [UIBarButtonItem]?
        static var gkDisableFixNavItemSpace: Bool = false
        static var gkOpenFixNavItemSpace: Bool = false
        static var gkNavItemLeftSpace: CGFloat = GKConfigure.gk_navItemLeftSpace
        static var gkNavItemRightSpace: CGFloat = GKConfigure.gk_navItemRightSpace
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
    
    fileprivate var gk_navBarInit: Bool {
        get {
            guard let isInit = objc_getAssociatedObject(self, &AssociatedKeys.gkNavBarInit) as? Bool else { return false }
            return isInit
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavBarInit, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var gk_navBarAdded: Bool {
        get {
            guard let added = objc_getAssociatedObject(self, &AssociatedKeys.gkNavBarAdded) as? Bool else { return false }
            return added
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavBarAdded, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var gk_navigationBar: GKNavigationBar {
        get {
            var navigationBar = objc_getAssociatedObject(self, &AssociatedKeys.gkNavigationBar) as? GKNavigationBar
            if navigationBar == nil {
                navigationBar = GKNavigationBar()
                
                self.gk_navBarInit = true
                self.gk_navigationBar = navigationBar!
            }
            
            if self.isViewLoaded && !self.gk_navBarAdded {
                self.view.addSubview(navigationBar!)
                self.gk_navBarAdded = true
            }
            
            return navigationBar!
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavigationBar, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            self.gk_disableFixNavItemSpace = GKConfigure.disableFixSpace
            self.gk_openFixNavItemSpace = true
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
    
    public var gk_darkBackImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkDarkBackImage) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkDarkBackImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    setBackItemImage(image: newValue)
                }
            }
        }
    }
    
    public var gk_blackBackImage: UIImage? {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkBlackBackImage) else { return GKConfigure.blackBackImage }
            return obj as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkBlackBackImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setBackItemImage(image: newValue)
        }
    }
    
    public var gk_whiteBackImage: UIImage? {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkWhiteBackImage) else { return GKConfigure.whiteBackImage }
            return obj as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkWhiteBackImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
    
    public var gk_navBackgroundColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavBackgroundColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNavBackground(newValue)
        }
    }
    
    public var gk_navBackgroundImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavBackgroundImage) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavBackgroundImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNavBackground(newValue)
        }
    }
    
    public var gk_darkNavBackgroundImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkDarkNavBackgroundImage) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkDarkNavBackgroundImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    setNavBackground(newValue)
                }
            }
        }
    }
    
    public var gk_navShadowColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavShadowColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavShadowColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNavShadow(newValue)
        }
    }
    
    public var gk_navShadowImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavShadowImage) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavShadowImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNavShadow(newValue)
        }
    }
    
    public var gk_darkNavShadowImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkDarkNavShadowImage) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkDarkNavShadowImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    setNavShadow(newValue)
                }
            }
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
                setNavShadow(shadowImage, color: nil)
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
            setNavTitle(newValue)
        }
    }
    
    public var gk_navTitleFont: UIFont? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gkNavTitleFont) as? UIFont
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavTitleFont, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNavTitle(newValue)
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
    
    public var gk_disableFixNavItemSpace: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkDisableFixNavItemSpace) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkDisableFixNavItemSpace, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if GKConfigure.gk_disableFixSpace == newValue { return }
            GKConfigure.update { configure in
                configure.gk_disableFixSpace = newValue
            }
        }
    }
    
    public var gk_openFixNavItemSpace: Bool {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkOpenFixNavItemSpace) as? Bool else { return false }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkOpenFixNavItemSpace, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if GKConfigure.gk_openSystemFixSpace == newValue { return }
            GKConfigure.update { configure in
                configure.gk_openSystemFixSpace = newValue
            }
        }
    }
    
    public var gk_navItemLeftSpace: CGFloat {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.gkNavItemLeftSpace) as? CGFloat else { return GKNavigationBarItemSpace }
            return obj
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gkNavItemLeftSpace, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue == GKNavigationBarItemSpace { return }
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
            if newValue == GKNavigationBarItemSpace { return }
            GKConfigure.update { (configure) in
                configure.gk_navItemRightSpace = newValue
            }
        }
    }
    
    // MARK: - 重新系统方法
    private static let onceToken = UUID().uuidString
    @objc public static func gkAwake() {
        DispatchQueue.once(token: onceToken) {
            let oriSels = ["viewDidLoad",
                           "viewWillAppear:",
                           "viewDidAppear:",
                           "viewWillLayoutSubviews",
                           "traitCollectionDidChange:"]
            
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
        // 设置默认状态
        self.gk_disableFixNavItemSpace = true
        self.gk_openFixNavItemSpace = false
        
        if shouldHandleNavBar() {
            // 设置默认导航栏间距
            self.gk_navItemLeftSpace  = GKNavigationBarItemSpace
            self.gk_navItemRightSpace = GKNavigationBarItemSpace
        }
        
        // 如果是根控制器，取消返回按钮
        if let nav = self.navigationController, nav.children.count <= 1 {
            if !self.gk_navBarInit {
                return
            }
            self.gk_navLeftBarButtonItem = nil
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
            let disableFixNavItemSpace = self.gk_disableFixNavItemSpace
            let openFixNavItemSpace = self.gk_openFixNavItemSpace
            self.gk_disableFixNavItemSpace = disableFixNavItemSpace
            self.gk_openFixNavItemSpace = openFixNavItemSpace
            // 隐藏系统导航栏
            if self.navigationController?.gk_openSystemNavHandle == false {
                hiddenSystemNavBar()
            }
            
            // 将自定义的导航栏放置顶层
            if !self.gk_navigationBar.isHidden {
                self.view.bringSubviewToFront(self.gk_navigationBar)
            }
        }else {
            if let nav = navigationController, !nav.isNavigationBarHidden, !isNonFullScreen() {
                self.gk_disableFixNavItemSpace = self.gk_disableFixNavItemSpace
                self.gk_openFixNavItemSpace = self.gk_openFixNavItemSpace
            }
            restoreSystemNavBar()
        }
        
        // 当创建了gk_navigationBar或者福控制器是导航控制器的时候才去调整导航栏间距
        if self.gk_openFixNavItemSpace {
            // 每次控制器出现的时候重置导航栏间距
            if self.gk_navItemLeftSpace == GKNavigationBarItemSpace {
                self.gk_navItemLeftSpace = GKConfigure.navItemLeftSpace
            }else {
                GKConfigure.update { configure in
                    configure.gk_navItemLeftSpace = self.gk_navItemLeftSpace
                }
            }
            
            if self.gk_navItemRightSpace == GKNavigationBarItemSpace {
                self.gk_navItemRightSpace = GKConfigure.navItemRightSpace
            }else {
                GKConfigure.update { configure in
                    configure.gk_navItemRightSpace = self.gk_navItemRightSpace
                }
            }
        }
        
        gk_viewWillAppear(animated)
    }
    
    @objc func gk_viewDidAppear(_ animated: Bool) {
        if self.gk_navBarInit {
            hiddenSystemNavBar()
        }else {
            restoreSystemNavBar()
        }
        gk_viewDidAppear(animated)
    }
    
    @objc func gk_viewWillLayoutSubviews() {
        if self.gk_navBarInit {
            setupNavBarFrame()
        }
        gk_viewWillLayoutSubviews()
    }
    
    @objc func gk_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if self.isKind(of: UINavigationController.classForCoder()) { return }
                if self.isKind(of: UITabBarController.classForCoder()) { return }
                if !self.gk_navBarInit { return }
                
                // 非根控制器重新设置返回按钮
                var isRootVC = false
                if let nav = self.navigationController, nav.children.first == self {
                    isRootVC = true
                }
                if !isRootVC && self.gk_backImage != nil {
                    setBackItemImage(image: self.gk_backImage)
                }
                
                // 重新设置导航栏背景颜色
                if self.gk_navBackgroundImage != nil {
                    setNavBackground(self.gk_navBackgroundImage)
                }else {
                    setNavBackground(self.gk_navBackgroundColor)
                }
                
                // 重新设置分割线颜色
                if self.gk_navShadowImage != nil {
                    setNavShadow(self.gk_navShadowImage)
                }else {
                    setNavShadow(self.gk_navShadowColor)
                }
            }
        }
        gk_traitCollectionDidChange(previousTraitCollection)
    }
    
    // MARK: - Public Funtions
    public func showNavLine() {
        self.gk_navLineHidden = false
    }
    
    public func hideNavLine() {
        self.gk_navLineHidden = true
    }
    
    public func refreshNavBarFrame() {
        self.setupNavBarFrame()
    }
    
    @objc open func backItemClick(_ sender: Any) {
        var shouldPop = navigationShouldPop()
        let selector = NSSelectorFromString("navigationShouldPopOnClick")
        if self.responds(to: selector) {
            if self.perform(selector) != nil {
                shouldPop = true
            }else {
                shouldPop = false
            }
        }
        
        if shouldPop {
            self.navigationController?.popViewController(animated: true)            
        }
    }
    
    public func gk_findCurrentViewController(_ isRoot: Bool) -> UIViewController? {
        if canFindPresented(self.presentedViewController) {
            return self.presentedViewController?.gk_findCurrentViewController(false)
        }
        if self.isKind(of: UITabBarController.classForCoder()) {
            let tabbarVC = self as! UITabBarController
            return tabbarVC.selectedViewController?.gk_findCurrentViewController(false)
        }
        if self.isKind(of: UINavigationController.classForCoder()) {
            let navVC = self as! UINavigationController
            return navVC.topViewController?.gk_findCurrentViewController(false)
        }
        if self.children.count > 0 {
            if self.children.count == 1 && isRoot {
                return self.children.first?.gk_findCurrentViewController(false)
            }else {
                var currentVC: UIViewController? = self
                for obj in self.children {
                    if obj.isViewLoaded {
                        let point = obj.view.convert(CGPoint.zero, to: nil)
                        let windowSize = obj.view.window?.bounds.size ?? .zero
                        // 是否全屏显示
                        let isFullScreenShow = !obj.view.isHidden && obj.view.alpha > 0.01 && __CGPointEqualToPoint(point, .zero) && __CGSizeEqualToSize(obj.view.bounds.size, windowSize)
                        // 判断类型
                        let isStopFindController = obj.isKind(of: UINavigationController.classForCoder()) || obj.isKind(of: UITabBarController.classForCoder())
                        if isFullScreenShow && isStopFindController {
                            currentVC = obj.gk_findCurrentViewController(false)
                            break
                        }
                    }
                }
                return currentVC
            }
        }else if self.responds(to: NSSelectorFromString("contentViewController")) {
            let tempVC = self.perform(NSSelectorFromString("contentViewController")).retain().takeRetainedValue() as? UIViewController
            if tempVC != nil {
                return tempVC?.gk_findCurrentViewController(false)
            }
        }
        return self
    }
    
    fileprivate func canFindPresented(_ viewController: UIViewController?) -> Bool {
        guard let vc = viewController else { return false }
        if vc.isKind(of: UIAlertController.classForCoder()) {
            return false
        }
        if NSStringFromClass(self.classForCoder) == "_UIContextMenuActionsOnlyViewController" {
            return false
        }
        return true
    }
    
    // MARK: - Private Functions
    fileprivate func shouldHandleNavBar() -> Bool {
        if self.gk_navBarInit {
            return true
        }
        
        if self.isKind(of: UITabBarController.classForCoder()) {
            return false
        }
        
        if let vc = self.parent, vc.isKind(of: UINavigationController.classForCoder()) {
            return true
        }
        return false
    }
    
    fileprivate func hiddenSystemNavBar() {
        if let nav = self.navigationController, nav.isNavigationBarHidden == false {
            nav.gk_hideNavigationBar = true
            nav.isNavigationBarHidden = true
        }
    }
    
    fileprivate func restoreSystemNavBar() {
        if GKConfigure.gk_restoreSystemNavBar && self.shouldHandleNavBar() {
            if let nav = self.navigationController, nav.isNavigationBarHidden, nav.gk_hideNavigationBar {
                nav.isNavigationBarHidden = false
            }
        }
    }
    
    fileprivate func setupNavBarAppearance() {
        // 设置默认背景
        if self.gk_navBackgroundImage == nil {
            self.gk_navBackgroundImage = GKConfigure.backgroundImage
        }
        
        if self.gk_darkNavBackgroundImage == nil {
            self.gk_darkNavBackgroundImage = GKConfigure.darkBackgroundImage
        }
        
        if self.gk_navBackgroundColor == nil && self.gk_navBackgroundImage == nil {
            self.gk_navBackgroundColor = GKConfigure.backgroundColor
        }
        
        // 设置分割线
        if self.gk_navShadowImage == nil {
            self.gk_navShadowImage = GKConfigure.lineImage
        }
        
        if self.gk_darkNavShadowImage == nil {
            self.gk_darkNavShadowImage = GKConfigure.darkLineImage
        }
        
        if self.gk_navShadowColor == nil && self.gk_navShadowImage == nil {
            self.gk_navShadowColor = GKConfigure.lineColor
        }
        
        // 设置分割线是否隐藏
        if self.gk_navLineHidden == false && GKConfigure.lineHidden == true {
            self.gk_navLineHidden = GKConfigure.lineHidden
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
        
        if self.gk_darkBackImage == nil {
            self.gk_darkBackImage = GKConfigure.darkBackImage
        }
        
        // 设置默认返回样式
        if self.gk_backStyle == .none {
            self.gk_backStyle = GKConfigure.backStyle
        }
        
        self.gk_navTitle = nil
    }
    
    fileprivate func setupNavBarFrame() {
        let isNonFullScreen = isNonFullScreen()
        var navBarH: CGFloat = 0.0
        
        let width  = UIScreen.main.bounds.size.width
        
        let gkNavBarHNFS = GKDevice.navBarHeightNonFullScreen()
        let gkNavBarH = GKDevice.navBarHeight()
        let gkStatusBarH = GKDevice.statusBarFrame().size.height
        let gkStatusBarNavBarH = gkStatusBarH + gkNavBarH
        
        if GKDevice.isIPad { // iPad
            if isNonFullScreen {
                navBarH = gkNavBarHNFS
                self.gk_navigationBar.gk_nonFullScreen = true
            }else {
                navBarH = self.gk_statusBarHidden ? gkNavBarH : gkStatusBarNavBarH
            }
        }else if GKDevice.isLandScape() { // 横屏不显示状态栏，没有非全屏模式
            navBarH = gkNavBarH
        }else {
            if isNonFullScreen {
                navBarH = gkNavBarHNFS
                self.gk_navigationBar.gk_nonFullScreen = true
            }else {
                if GKDevice.isNotchedScreen { // 刘海屏手机
                    navBarH = GKDevice.safeAreaInsets().top + gkNavBarH
                }else {
                    navBarH = self.gk_statusBarHidden ? gkNavBarH : gkStatusBarNavBarH
                }
            }
        }
        self.gk_navigationBar.frame = CGRect(x: 0, y: 0, width: width, height: navBarH)
        self.gk_navigationBar.gk_statusBarHidden = self.gk_statusBarHidden
        self.gk_navigationBar.layoutSubviews()
    }
    
    fileprivate func isNonFullScreen() -> Bool {
        var isNonFullScreen = false
        var viewW = UIScreen.main.bounds.size.width
        var viewH = UIScreen.main.bounds.size.height
        if self.isViewLoaded {
            var parentVC = self
            // 找到最上层的父控制器
            while (parentVC.parent != nil) {
                parentVC = parentVC.parent!
            }
            viewW = parentVC.view.frame.size.width
            viewH = parentVC.view.frame.size.height
            if viewW == 0 || viewH == 0 {
                return false
            }
            
            // 如果是通过present方式弹出且高度小于屏幕高度，则认为是非全屏
            isNonFullScreen = (self.presentingViewController != nil) && viewH < UIScreen.main.bounds.size.height
        }
        return isNonFullScreen
    }
    
    fileprivate func setBackItemImage(image: UIImage?) {
        if self.gk_navBarInit == false { return }
        // 根控制器不作处理
        guard let count = self.navigationController?.children.count else { return }
        if (count <= 1) {
            self.gk_navLeftBarButtonItem = nil
            return
        }
        
        var backImage = image
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark, self.gk_darkBackImage != nil {
                backImage = self.gk_darkBackImage
            }
        }
        
        if backImage == nil {
            if self.gk_backStyle != .none {
                backImage = self.gk_backStyle == .black ? self.gk_blackBackImage : self.gk_whiteBackImage
            }
        }else {
            if self.gk_backStyle == .none {
                backImage = nil
            }
        }
        
        if backImage == nil { return }
        
        self.gk_navLeftBarButtonItem = UIBarButtonItem.gk_item(image: backImage, target: self, action: #selector(backItemClick(_:)))
    }
    
    fileprivate func setNavBackground(_ image: UIImage?) {
        guard var image = image else { return }
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark, gk_darkNavBackgroundImage != nil {
                image = gk_darkNavBackgroundImage!
            }
        }
        setNavBackground(image, color: nil)
    }
    
    fileprivate func setNavBackground(_ color: UIColor?) {
        guard let color = color else { return }
        setNavBackground(nil, color: color)
    }
    
    fileprivate func setNavShadow(_ image: UIImage?) {
        guard var image = image else { return }
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark, gk_darkNavShadowImage != nil {
                image = gk_darkNavShadowImage!
            }
        }
        setNavShadow(image, color: nil)
    }
    
    fileprivate func setNavShadow(_ color: UIColor?) {
        guard let color = color else { return }
        setNavShadow(nil, color: color)
    }
    
    fileprivate func setNavTitle(_ color: UIColor?) {
        guard let color = color else { return }
        var attr = [NSAttributedString.Key: AnyObject]()
        attr[.foregroundColor] = color
        if gk_navTitleFont != nil {
            attr[.font] = gk_navTitleFont
        }
        setNavTitle(attr)
    }
    
    fileprivate func setNavTitle(_ font: UIFont?) {
        guard let font = font else { return }
        var attr = [NSAttributedString.Key: Any]()
        if gk_navTitleColor != nil {
            attr[.foregroundColor] = gk_navTitleColor
        }
        attr[.font] = font
        setNavTitle(attr)
    }
    
    fileprivate func setNavBackground(_ image: UIImage?, color: UIColor?) {
        if #available(iOS 13.0, *) {
            let appearance = gk_navigationBar.standardAppearance
            let shadowColor = appearance.shadowColor
            let shadowImage = appearance.shadowImage
            appearance.configureWithTransparentBackground()
            appearance.backgroundImage = image
            appearance.backgroundColor = color
            appearance.shadowColor = shadowColor
            appearance.shadowImage = shadowImage
            gk_navigationBar.standardAppearance = appearance
            gk_navigationBar.scrollEdgeAppearance = appearance
        }else {
            guard image == nil, let color = color else { return }
            let image = UIImage.gk_image(with: color)
            gk_navigationBar.setBackgroundImage(image, for: .default)
        }
    }
    
    fileprivate func setNavShadow(_ image: UIImage?, color: UIColor?) {
        if #available(iOS 13.0, *) {
            let appearance = gk_navigationBar.standardAppearance
            let backgroundColor = appearance.backgroundColor
            let backgroundImage = appearance.backgroundImage
            appearance.configureWithTransparentBackground()
            appearance.shadowImage = image
            appearance.shadowColor = color
            appearance.backgroundColor = backgroundColor
            appearance.backgroundImage = backgroundImage
            gk_navigationBar.standardAppearance = appearance
            gk_navigationBar.scrollEdgeAppearance = appearance
        }else {
            guard image == nil, let color = color else { return }
            let image = UIImage.gk_change(with: UIImage.gk_image(with: "nav_line"), color: color)
            gk_navigationBar.shadowImage = image
        }
    }
    
    fileprivate func setNavTitle(_ attr: [NSAttributedString.Key: Any]) {
        if #available(iOS 13, *) {
            let appearance = gk_navigationBar.standardAppearance
            appearance.titleTextAttributes = attr
            gk_navigationBar.standardAppearance = appearance
            gk_navigationBar.scrollEdgeAppearance = appearance
        }else {
            gk_navigationBar.titleTextAttributes = attr
        }
    }
}
