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
        static var gkNavBarAlpha: Void?
        static var gkNavBarInit: Void?
        static var gkNavBarAdded: Void?
        static var gkNavigationBar: Void?
        static var gkNavigationItem: Void?
        static var gkStatusBarHidden: Void?
        static var gkStatusBarStyle: Void?
        static var gkBackImage: Void?
        static var gkDarkBackImage: Void?
        static var gkBlackBackImage: Void?
        static var gkWhiteBackImage: Void?
        static var gkBackStyle: Void?
        static var gkNavBackgroundColor: Void?
        static var gkNavBackgroundImage: Void?
        static var gkDarkNavBackgroundImage: Void?
        static var gkNavShadowColor: Void?
        static var gkNavShadowImage: Void?
        static var gkDarkNavShadowImage: Void?
        static var gkNavLineHidden: Void?
        static var gkNavTitle: Void?
        static var gkNavTitleView: Void?
        static var gkNavTitleColor: Void?
        static var gkNavTitleFont: Void?
        static var gkNavLeftBarButtonItem: Void?
        static var gkNavLeftBarButtonItems: Void?
        static var gkNavRightBarButtonItem: Void?
        static var gkNavRightBarButtonItems: Void?
        static var gkDisableFixNavItemSpace: Void?
        static var gkOpenFixNavItemSpace: Void?
        static var gkNavItemLeftSpace: Void?
        static var gkNavItemRightSpace: Void?
    }
    
    public var gk_navBarAlpha: CGFloat {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkNavBarAlpha) as? CGFloat else { return 1 }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavBarAlpha, newValue)
            
            self.gk_navigationBar.gk_navBarBackgroundAlpha = newValue
        }
    }
    
    fileprivate var gk_navBarInit: Bool {
        get {
            guard let isInit = gk_getAssociatedObject(self, &AssociatedKeys.gkNavBarInit) as? Bool else { return false }
            return isInit
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavBarInit, newValue)
        }
    }
    
    fileprivate var gk_navBarAdded: Bool {
        get {
            guard let added = gk_getAssociatedObject(self, &AssociatedKeys.gkNavBarAdded) as? Bool else { return false }
            return added
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavBarAdded, newValue)
        }
    }
    
    public var gk_navigationBar: GKNavigationBar {
        get {
            var navigationBar = gk_getAssociatedObject(self, &AssociatedKeys.gkNavigationBar) as? GKNavigationBar
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
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavigationBar, newValue)
            
            self.gk_disableFixNavItemSpace = GKConfigure.disableFixSpace
            self.gk_openFixNavItemSpace = true
            setupNavBarAppearance()
            setupNavBarFrame()
        }
    }
    
    public var gk_navigationItem: UINavigationItem {
        get {
            var item = gk_getAssociatedObject(self, &AssociatedKeys.gkNavigationItem) as? UINavigationItem
            if item == nil {
                item = UINavigationItem()
                self.gk_navigationItem = item!
            }
            return item!
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavigationItem, newValue)
            
            self.gk_navigationBar.items = [newValue]
        }
    }
    
    public var gk_statusBarHidden: Bool {
        get {
            guard let isHidden = gk_getAssociatedObject(self, &AssociatedKeys.gkStatusBarHidden) as? Bool else { return false }
            return isHidden
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkStatusBarHidden, newValue)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public var gk_statusBarStyle: UIStatusBarStyle {
        get {
            guard let style = gk_getAssociatedObject(self, &AssociatedKeys.gkStatusBarStyle) as? UIStatusBarStyle else { return GKConfigure.statusBarStyle }
            return style
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkStatusBarStyle, newValue)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public var gk_backImage: UIImage? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkBackImage) as? UIImage
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkBackImage, newValue)
            
            setBackItemImage(image: newValue)
        }
    }
    
    public var gk_darkBackImage: UIImage? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkDarkBackImage) as? UIImage
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkDarkBackImage, newValue)
            
            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    setBackItemImage(image: newValue)
                }
            }
        }
    }
    
    public var gk_blackBackImage: UIImage? {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkBlackBackImage) else { return GKConfigure.blackBackImage }
            return obj as? UIImage
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkBlackBackImage, newValue)
            setBackItemImage(image: newValue)
        }
    }
    
    public var gk_whiteBackImage: UIImage? {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkWhiteBackImage) else { return GKConfigure.whiteBackImage }
            return obj as? UIImage
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkWhiteBackImage, newValue)
            setBackItemImage(image: newValue)
        }
    }
    
    public var gk_backStyle: GKNavigationBarBackStyle {
        get {
            guard let style = gk_getAssociatedObject(self, &AssociatedKeys.gkBackStyle) as? GKNavigationBarBackStyle else { return .none }
            return style
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkBackStyle, newValue)
            setBackItemImage(image: self.gk_backImage)
        }
    }
    
    public var gk_navBackgroundColor: UIColor? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavBackgroundColor) as? UIColor
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavBackgroundColor, newValue)
            setNavBackground(newValue)
        }
    }
    
    public var gk_navBackgroundImage: UIImage? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavBackgroundImage) as? UIImage
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavBackgroundImage, newValue)
            setNavBackground(newValue)
        }
    }
    
    public var gk_darkNavBackgroundImage: UIImage? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkDarkNavBackgroundImage) as? UIImage
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkDarkNavBackgroundImage, newValue)
            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    setNavBackground(newValue)
                }
            }
        }
    }
    
    public var gk_navShadowColor: UIColor? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavShadowColor) as? UIColor
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavShadowColor, newValue)
            setNavShadow(newValue)
        }
    }
    
    public var gk_navShadowImage: UIImage? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavShadowImage) as? UIImage
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavShadowImage, newValue)
            setNavShadow(newValue)
        }
    }
    
    public var gk_darkNavShadowImage: UIImage? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkDarkNavShadowImage) as? UIImage
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkDarkNavShadowImage, newValue)
            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    setNavShadow(newValue)
                }
            }
        }
    }
    
    public var gk_navLineHidden: Bool {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkNavLineHidden) as? Bool else { return false }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavLineHidden, newValue)
            
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
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavTitle) as? String
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavTitle, newValue)
            self.gk_navigationItem.title = newValue
        }
    }
    
    public var gk_navTitleView: UIView? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavTitleView) as? UIView
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavTitleView, newValue)
            self.gk_navigationItem.titleView = newValue
        }
    }
    
    public var gk_navTitleColor: UIColor? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavTitleColor) as? UIColor
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavTitleColor, newValue)
            setNavTitle(newValue)
        }
    }
    
    public var gk_navTitleFont: UIFont? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavTitleFont) as? UIFont
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavTitleFont, newValue)
            setNavTitle(newValue)
        }
    }
    
    public var gk_navLeftBarButtonItem: UIBarButtonItem? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavLeftBarButtonItem) as? UIBarButtonItem
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavLeftBarButtonItem, newValue)
            self.gk_navigationItem.leftBarButtonItem = newValue
        }
    }
    
    public var gk_navLeftBarButtonItems: [UIBarButtonItem]? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavLeftBarButtonItems) as? [UIBarButtonItem]
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavLeftBarButtonItems, newValue)
            self.gk_navigationItem.leftBarButtonItems = newValue
        }
    }
    
    public var gk_navRightBarButtonItem: UIBarButtonItem? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavRightBarButtonItem) as? UIBarButtonItem
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavRightBarButtonItem, newValue)
            self.gk_navigationItem.rightBarButtonItem = newValue
        }
    }
    
    public var gk_navRightBarButtonItems: [UIBarButtonItem]? {
        get {
            return gk_getAssociatedObject(self, &AssociatedKeys.gkNavRightBarButtonItems) as? [UIBarButtonItem]
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavRightBarButtonItems, newValue)
            self.gk_navigationItem.rightBarButtonItems = newValue
        }
    }
    
    public var gk_disableFixNavItemSpace: Bool {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkDisableFixNavItemSpace) as? Bool else { return false }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkDisableFixNavItemSpace, newValue)
            if GKConfigure.gk_disableFixSpace == newValue { return }
            GKConfigure.update { configure in
                configure.gk_disableFixSpace = newValue
            }
        }
    }
    
    public var gk_openFixNavItemSpace: Bool {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkOpenFixNavItemSpace) as? Bool else { return false }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkOpenFixNavItemSpace, newValue)
            if GKConfigure.gk_openSystemFixSpace == newValue { return }
            GKConfigure.update { configure in
                configure.gk_openSystemFixSpace = newValue
            }
        }
    }
    
    public var gk_navItemLeftSpace: CGFloat {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkNavItemLeftSpace) as? CGFloat else { return GKNavigationBarItemSpace }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavItemLeftSpace, newValue)
            if newValue == GKNavigationBarItemSpace { return }
            GKConfigure.update { (configure) in
                configure.gk_navItemLeftSpace = newValue
            }
        }
    }
    
    public var gk_navItemRightSpace: CGFloat {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.gkNavItemRightSpace) as? CGFloat else { return GKNavigationBarItemSpace }
            return obj
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.gkNavItemRightSpace, newValue)
            if newValue == GKNavigationBarItemSpace { return }
            GKConfigure.update { (configure) in
                configure.gk_navItemRightSpace = newValue
            }
        }
    }
}

extension UIViewController {
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
        }
    }
    
    @objc func gk_viewDidLoad() {
        // 设置默认状态
        if let nav = self.navigationController, nav == self.parent {
            self.gk_disableFixNavItemSpace = true
            self.gk_openFixNavItemSpace = false
        }

        if shouldHandleNavBar() {
            // 设置默认导航栏间距
            self.gk_navItemLeftSpace  = GKNavigationBarItemSpace
            self.gk_navItemRightSpace = GKNavigationBarItemSpace
        }
        
        // 如果是根控制器，取消返回按钮
        if let nav = self.navigationController, nav.children.count <= 1 {
            if !self.gk_navBarInit { return }
            self.gk_navLeftBarButtonItem = nil
        }
        gk_viewDidLoad()
    }
    
    @objc func gk_viewWillAppear(_ animated: Bool) {
        if self.isKind(of: UINavigationController.self) { return }
        if self.isKind(of: UITabBarController.self) { return }
        if self.isKind(of: UIImagePickerController.self) { return }
        if self.isKind(of: UIVideoEditorController.self) { return }
        if self.isKind(of: UIAlertController.self) { return }
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
            if let nav = self.navigationController, nav == self.parent, !nav.isNavigationBarHidden, !isNonFullScreen() {
                self.gk_disableFixNavItemSpace = self.gk_disableFixNavItemSpace
                self.gk_openFixNavItemSpace = self.gk_openFixNavItemSpace
            }
            restoreSystemNavBar()
        }
        
        // 当创建了gk_navigationBar或者父控制器是导航控制器的时候才去调整导航栏间距
        if self.shouldFixItemSpace() {
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
                if self.isKind(of: UINavigationController.self) { return }
                if self.isKind(of: UITabBarController.self) { return }
                if !self.gk_navBarInit { return }
                
                // 非根控制器重新设置返回按钮
                var isRootVC = false
                if let nav = self.navigationController, nav.children.first == self {
                    isRootVC = true
                }
                if !isRootVC && self.gk_backImage != nil && self.gk_navLeftBarButtonItem == nil && self.gk_navLeftBarButtonItems == nil {
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
        if self.isKind(of: UITabBarController.self) {
            let tabbarVC = self as! UITabBarController
            return tabbarVC.selectedViewController?.gk_findCurrentViewController(false)
        }
        if self.isKind(of: UINavigationController.self) {
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
                        let isStopFindController = obj.isKind(of: UINavigationController.self) || obj.isKind(of: UITabBarController.self)
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
        if vc.isKind(of: UIAlertController.self) {
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
        
        if self.isKind(of: UITabBarController.self) {
            return false
        }
        
        if let vc = self.parent, vc.isKind(of: UINavigationController.self) {
            return true
        }
        return false
    }
    
    fileprivate func shouldFixItemSpace() -> Bool {
        if self.gk_navBarInit {
            if self.isKind(of: UINavigationController.self) {
                return false
            }
            if self.isKind(of: UITabBarController.self) {
                return false
            }
            if self.navigationController == nil {
                return false
            }
            if let parent = self.parent, !parent.isKind(of: UINavigationController.self) {
                return false
            }
            return true
        }
        return self.gk_openFixNavItemSpace
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
                    // iPhone 14 Pro 状态栏高度与安全区域高度不一致，这里改为使用状态栏高度
                    var topH = GKDevice.statusBarFrame().height
                    if topH == 0 { topH = GKDevice.safeAreaInsets().top }
                    navBarH = topH + gkNavBarH
                }else {
                    navBarH = self.gk_statusBarHidden ? gkNavBarH : gkStatusBarNavBarH
                }
            }
        }
        self.gk_navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: navBarH)
        self.gk_navigationBar.gk_statusBarHidden = self.gk_statusBarHidden
        self.gk_navigationBar.layoutSubviews()
    }
    
    fileprivate func isNonFullScreen() -> Bool {
        var isNonFullScreen = false
        var viewW = self.view.bounds.width
        var viewH = self.view.bounds.height
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
            var window = view.window
            if window == nil {
                window = GKDevice.keyWindow()
            }
            
            isNonFullScreen = (self.presentingViewController != nil) && viewH < window?.bounds.height ?? 0
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
        
        self.gk_navigationItem.leftBarButtonItem = UIBarButtonItem.gk_item(image: backImage, target: self, action: #selector(backItemClick(_:)))
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
            var bgImage = image
            if bgImage == nil, let color = color {
                bgImage = UIImage.gk_image(with: color)
            }
            gk_navigationBar.setBackgroundImage(bgImage, for: .default)
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
            var shadowImage = image
            if shadowImage == nil, let color = color {
                shadowImage = UIImage.gk_change(with: UIImage.gk_image(with: "nav_line"), color: color)
            }
            gk_navigationBar.shadowImage = shadowImage
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
