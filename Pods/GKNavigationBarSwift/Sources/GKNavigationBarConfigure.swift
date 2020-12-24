//
//  GKNavigationBarConfigure.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/24.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

public let GKConfigure = GKNavigationBarConfigure.shared

// 配置类宏定义
open class GKNavigationBarConfigure : NSObject {

    /// 导航栏背景色
    open var backgroundColor: UIColor?
    
    /// 导航栏标题颜色
    open var titleColor: UIColor?
    
    /// 导航栏标题字体
    open var titleFont: UIFont?
    
    /// 返回按钮图片，默认nil，优先级高于backStyle
    open var backImage: UIImage?
    
    /// 返回按钮样式
    open var backStyle: GKNavigationBarBackStyle = .none
    
    /// 是否禁止导航栏左右item间距调整，默认是NO
    open var gk_disableFixSpace: Bool = false
    
    /// 导航栏左侧按钮距屏幕左边间距，默认是0，可自行调整
    open var gk_navItemLeftSpace: CGFloat = 0.0
    
    /// 导航栏右侧按钮距屏幕右边间距，默认是0，可自行调整
    open var gk_navItemRightSpace: CGFloat = 0.0
    
    /// 是否隐藏状态栏，默认NO
    open var statusBarHidden: Bool = false
    
    /// 状态栏类型，默认UIStatusBarStyleDefault
    open var statusBarStyle: UIStatusBarStyle = .default
    
    /// 快速滑动时的灵敏度，默认0.7
    open var gk_snapMovementSensitivity: CGFloat = 0.7
    
    /// 左滑push过渡临界值，默认0.3，大于此值完成push操作
    open var gk_pushTransitionCriticalValue: CGFloat = 0.3
    
    /// 右滑pop过渡临界值，默认0.5，大于此值完成pop操作
    open var gk_popTransitionCriticalValue: CGFloat = 0.5
    
    // 以下属性需要设置导航栏转场缩放为YES
    /// 手机系统大于11.0，使用下面的值控制x、y轴的位移距离，默认（5，5）
    open var gk_translationX: CGFloat = 5.0

    open var gk_translationY: CGFloat = 5.0

    
    /// 手机系统小于11.0，使用下面的值控制x、y周的缩放程度，默认（0.95，0.97）
    open var gk_scaleX: CGFloat = 0.95

    open var gk_scaleY: CGFloat = 0.97

    /// 调整导航栏间距时需要屏蔽的VC，默认nil，支持UIViewController和String
    open var shiledItemSpaceVCs: [Any]?
    
    /// 需要屏蔽手势处理的VC，默认nil，支持UIViewController和String
    open var shiledGuestureVCs: [Any]?
    
    /// 导航栏左右间距，内部使用
    open var navItemLeftSpace: CGFloat = 0

    open var navItemRightSpace: CGFloat = 0
    
    /// 单例，设置一次全局使用
    public static let shared: GKNavigationBarConfigure = {
        let instance = GKNavigationBarConfigure()
        // setup code
        return instance
    }()
    
    /// 设置默认配置
    open func setupDefault() {
        backgroundColor = .white
        titleColor = .black
        titleFont = UIFont.boldSystemFont(ofSize: 17.0)
        backStyle = .black
        gk_disableFixSpace = false
        gk_navItemLeftSpace = 0
        gk_navItemRightSpace = 0
        navItemLeftSpace = 0
        navItemRightSpace = 0
        statusBarHidden = false
        statusBarStyle = .default
        gk_snapMovementSensitivity = 0.7
        gk_pushTransitionCriticalValue = 0.3
        gk_popTransitionCriticalValue = 0.5
        gk_translationX = 5.0
        gk_translationY = 5.0
        gk_scaleX = 0.95
        gk_scaleY = 0.97
    }
    
    open func awake() {
        UIViewController.gkAwake()
        UINavigationController.gkChildAwake()
        UINavigationItem.gkAwake()
        NSObject.gkObjectAwake()
    }

    /// 设置自定义配置，此方法只需调用一次
    /// @param block 配置回调
    open func setupCustom(_ block: @escaping (GKNavigationBarConfigure) -> Void) {
        setupDefault()
        
        block(self)
        
        navItemLeftSpace = gk_navItemLeftSpace
        navItemRightSpace = gk_navItemRightSpace
    }

    /// 更新配置
    /// @param block 配置回调
    open func update(_ block: @escaping (GKNavigationBarConfigure) -> Void) {
        block(self)
    }
    
    open func visibleViewController() -> UIViewController? {
        return self.getKeyWindow()?.rootViewController?.gk_visibleViewControllerIfExist()
    }
    
    open func gk_safeAreaInsets() -> UIEdgeInsets {
        var safeAreaInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            let keyWindow = GKConfigure.getKeyWindow()
            if let window = keyWindow {
                safeAreaInsets = window.safeAreaInsets
            }else { // 如果获取到的window是空
                // 对于刘海屏，当window没有创建的时候，可根据状态栏设置安全区域顶部高度
                // iOS14之后顶部安全区域不再是固定的44，所以修改为以下方式获取
                if GKConfigure.gk_isNotchedScreen() {
                    safeAreaInsets = UIEdgeInsets(top: GKConfigure.gk_statusBarFrame().size.height, left: 0, bottom: 34, right: 0)
                }
            }
        }
        return safeAreaInsets
    }
    
    open func gk_statusBarFrame() -> CGRect {
        return UIApplication.shared.statusBarFrame
    }
    
    open func gk_isNotchedScreen() -> Bool {
        if #available(iOS 11.0, *) {
            let keyWinwow = GKConfigure.getKeyWindow()
            if let window = keyWinwow {
                return window.safeAreaInsets.bottom > 0 ? true : false
            }
        }
        // 当iOS11以下或获取不到keyWindow时用以下方案
        let screenSize = UIScreen.main.bounds.size
        return ((UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 375, height:812), screenSize) : false) ||
                (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 812, height:375), screenSize) : false) ||
                (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 414, height:896), screenSize) : false) ||
                (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 896, height:414), screenSize) : false) ||
                (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 390, height:844), screenSize) : false) ||
                (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 844, height:390), screenSize) : false) ||
                (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 428, height:926), screenSize) : false) ||
                (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 926, height:428), screenSize) : false))
    }
    
    /// 获取当前item修复间距
    open func gk_fixedSpace() -> CGFloat {
        let screenSize = UIScreen.main.bounds.size
        // 经测试发现iPhone 12，iPhone 12，默认导航栏间距是16，需要单独处理
        let deviceWidth = min(screenSize.width, screenSize.height)
        let deviceHeight = max(screenSize.width, screenSize.height)
        if deviceWidth == 390.0 && deviceHeight == 844.0 {
            return 16.0
        }
        return deviceWidth > 375.0 ? 20.0 : 16.0
    }
    
    // 内部方法
    open func isVelocityInsensitivity(_ velocity: CGFloat) -> Bool {
        return (abs(velocity) - (1000.0 * (1 - self.gk_snapMovementSensitivity))) > 0;
    }
    
    fileprivate func getKeyWindow() -> UIWindow? {
        var window: UIWindow?
        if #available(iOS 13.0, *) {
            window = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        }
        
        if window == nil {
            window = UIApplication.shared.windows.first { $0.isKeyWindow }
            if window == nil {
                window = UIApplication.shared.keyWindow
            }
        }
        
        return window
    }
}

