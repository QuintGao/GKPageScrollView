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
    
    /// 导航栏背景图片，默认nil，优先级高于backgroundColor
    open var backgroundImage: UIImage?
    
    /// 暗黑模式下的背景图片，默认nil，优先级高于backgroundColor
    open var darkBackgroundImage: UIImage?
    
    /// 导航栏分割线颜色，默认nil，使用系统颜色
    open var lineColor: UIColor?
    
    /// 导航栏分割线图片，默认nil，优先级高于lineColor
    open var lineImage: UIImage?
    
    /// 暗黑模式下的分割线图片，默认nil，优先级高于lineColor
    open var darkLineImage: UIImage?
    
    /// 导航栏分割线是否隐藏，默认NO
    open var lineHidden: Bool = false
    
    /// 导航栏标题颜色，默认黑色
    open var titleColor: UIColor?
    
    /// 导航栏标题字体，默认系统字体17
    open var titleFont: UIFont?
    
    /// 返回按钮图片，默认nil，优先级高于backStyle
    open var backImage: UIImage?
    
    /// 暗黑模式下的返回图片，mornil，优先级高于backStyle
    open var darkBackImage: UIImage?
    
    /// backStyle为GKNavigationBarBackStyle.black时对应的图片，默认btn_back_black
    open var blackBackImage: UIImage?
    
    /// backStyle为GKNavigationBarBackStyle.white时对应的图片，默认btn_black_white
    open var whiteBackImage: UIImage?
    
    /// 返回按钮样式
    open var backStyle: GKNavigationBarBackStyle = .none
    
    /// 是否禁止导航栏左右item间距调整，默认是NO
    /// 1.4.0版本之后，只对带有GKNavigationBar的控制器有效
    open var gk_disableFixSpace: Bool = false
    
    /// 是否开启普通控制器的导航栏item间距调整，只能在对应的控制器中开启
    open var gk_openSystemFixSpace: Bool = false
    
    /// 导航栏左侧按钮距屏幕左边间距，默认是0，可自行调整
    open var gk_navItemLeftSpace: CGFloat = 0.0
    
    /// 导航栏右侧按钮距屏幕右边间距，默认是0，可自行调整
    open var gk_navItemRightSpace: CGFloat = 0.0
    
    /// 是否隐藏状态栏，默认NO
    open var statusBarHidden: Bool = false
    
    /// 状态栏类型，默认UIStatusBarStyleDefault
    open var statusBarStyle: UIStatusBarStyle = .default
    
    /// 用于恢复系统导航栏的显示，默认NO
    open var gk_restoreSystemNavBar: Bool = false
    
    /// 快速滑动时的灵敏度，默认0.7
    open var gk_snapMovementSensitivity: CGFloat = 0.7
    
    /// 左滑push过渡临界值，默认0.3，大于此值完成push操作
    open var gk_pushTransitionCriticalValue: CGFloat = 0.3
    
    /// 右滑pop过渡临界值，默认0.5，大于此值完成pop操作
    open var gk_popTransitionCriticalValue: CGFloat = 0.5

    /// 控制x、y轴的缩放程度，默认（0.95，0.97）
    open var gk_scaleX: CGFloat = 0.95
    open var gk_scaleY: CGFloat = 0.97
    
    /// 需要屏蔽手势处理的VC，默认nil，支持UIViewController和String
    open var shiledGuestureVCs: [Any]?
    
    /// 全局开启UIScrollView手势处理，默认false
    /// 如果设置为YES，可在单个UIScrollView中通过gk_openGestureHandle关闭
    open var gk_openScrollViewGestureHandle: Bool = false
    
    /// 设置push时是否隐藏tabbar，默认NO
    open var gk_hidesBottomBarWhenPushed: Bool = false
    
    /// 导航栏左右间距，内部使用
    open var disableFixSpace: Bool = false
    open var navItemLeftSpace: CGFloat = 0
    open var navItemRightSpace: CGFloat = 0
    
    /// 单例，设置一次全局使用
    public static let shared: GKNavigationBarConfigure = {
        let instance = GKNavigationBarConfigure()
        // setup code
        return instance
    }()
    
    private static let awake: Void = {
        UIViewController.gkAwake()
        UINavigationController.gkChildAwake()
        UINavigationItem.gkAwake()
        NSObject.gkObjectAwake()
        UIScrollView.gkAwake()
        UIViewController.gkGestureAwake()
        UINavigationController.gkGestureChildAwake()
    }()
    
    /// 设置默认配置
    open func setupDefault() {
        GKNavigationBarConfigure.awake
        backgroundColor = .white
        titleColor = .black
        titleFont = UIFont.boldSystemFont(ofSize: 17.0)
        blackBackImage = UIImage.gk_image(with: "btn_back_black")
        whiteBackImage = UIImage.gk_image(with: "btn_back_white")
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
        gk_scaleX = 0.95
        gk_scaleY = 0.97
    }
    
    open func awake() {
        GKNavigationBarConfigure.awake
    }

    /// 设置自定义配置，此方法只需调用一次
    /// @param block 配置回调
    open func setupCustom(_ block: @escaping (GKNavigationBarConfigure) -> Void) {
        setupDefault()
        
        block(self)
        
        disableFixSpace = gk_disableFixSpace
        navItemLeftSpace = gk_navItemLeftSpace
        navItemRightSpace = gk_navItemRightSpace
    }

    /// 更新配置
    /// @param block 配置回调
    open func update(_ block: @escaping (GKNavigationBarConfigure) -> Void) {
        block(self)
    }
    
    open func visibleViewController() -> UIViewController? {
        return GKDevice.keyWindow()?.rootViewController?.gk_findCurrentViewController(true)
    }
    
    /// 获取当前item修复间距
    open func gk_fixedSpace() -> CGFloat {
        // 经测试发现iPhone 12，iPhone 12 Pro，iPhone 14 Pro默认导航栏间距是16，需要单独处理
        if GKDevice.is61InchScreenAndiPhone12Later || GKDevice.is61InchScreenAndiPhone14Pro { return 16 }
        return GKDevice.width > 375.0 ? 20 : 16
    }
    
    open func fixNavItemSpaceDisabled() -> Bool {
        return self.gk_disableFixSpace && !self.gk_openSystemFixSpace
    }
    
    // 内部方法
    open func isVelocityInsensitivity(_ velocity: CGFloat) -> Bool {
        return (abs(velocity) - (1000.0 * (1 - self.gk_snapMovementSensitivity))) > 0;
    }
    
    /// 获取某个view的截图
    open func getCapture(with view: UIView) -> UIImage? {
        if view == nil { return nil }
        if view.bounds.size.width <= 0 || view.bounds.size.height <= 0 { return nil }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

open class GKDevice {
    public static let deviceModel: String = {
        if isSimulator, let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return identifier
        }
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()
    
    public static func isZoomedMode() -> Bool {
        if !isIPhone { return false }
        let nativeScale = UIScreen.main.nativeScale
        var scale = UIScreen.main.scale
        
        // 对于所有的Plus系列iPhone，屏幕物理像素低于软件层面的渲染像素，不管标准模式还是放大模式，nativeScale均小于scale，所以需要特殊处理才能准确区分放大模式
        let shouldBeDownsampledDevice = __CGSizeEqualToSize(UIScreen.main.nativeBounds.size, CGSize(width: 1080, height: 1920))
        if shouldBeDownsampledDevice {
            scale /= 1.15
        }
        return nativeScale > scale
    }
    
    public static let isIPad: Bool = {
        return UIDevice.current.userInterfaceIdiom == .pad
    }()
    
    public static let isIPod: Bool = {
        let model = UIDevice.current.model as NSString
        return model.range(of: "iPod touch").location != NSNotFound
    }()
    
    public static let isIPhone: Bool = {
        let model = UIDevice.current.model as NSString
        return model.range(of: "iPhone").location != NSNotFound
    }()
    
    public static let isSimulator: Bool = {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }()
    
    public static let isMac: Bool = {
#if IOS14_SDK_ALLOWED
        if #available(iOS 14.0, *) {
            return ProcessInfo.processInfo.isiOSAppOnMac || ProcessInfo.processInfo.isMacCatalystApp
        }
#endif
        if #available(iOS 13.0, *) {
            return ProcessInfo.processInfo.isMacCatalystApp
        }
        return false
    }()
    
    /// 带物理凹槽的刘海屏或使用 Home Indicator 类型的设备
    public static let isNotchedScreen: Bool = {
        if #available(iOS 11.0, *) {
            var window = keyWindow()
            if window == nil {
                // keyWindow还没有创建时，通过创建临时window获取安全区域
                window = UIWindow(frame: UIScreen.main.bounds)
                if window!.safeAreaInsets.bottom <= 0 {
                    let viewController = UIViewController()
                    window?.rootViewController = viewController
                }
            }
            
            if window!.safeAreaInsets.bottom > 0 {
                return true
            }
        } else {
            return false
        }
        return false
    }()
    
    /// 将屏幕分为普通和紧凑两种，这个方法用于判断普通屏幕（也即大屏幕）
    public static func isRegularScreen() -> Bool {
        return isIPad || (!isZoomedMode() && (is67InchScreenAndiPhone14ProMax || is67InchScreen || is65InchScreen || is61InchScreen || is55InchScreen))
    }
    
    /// 是否是横屏
    public static func isLandScape() -> Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    
    public static func statusBarNavBarHeight() -> CGFloat {
        return statusBarFrame().size.height + navBarHeight()
    }
    
    public static func navBarHeight() -> CGFloat {
        if isIPad {
            if let version = version, version >= 12.0 {
                return 50
            }else {
                return 44
            }
        }else {
            if isLandScape() {
                return isRegularScreen() ? 44 : 32
            }else {
                return 44
            }
        }
    }
    
    public static func navBarHeightNonFullScreen() -> CGFloat {
        return 56
    }
    
    public static func tabBarHeight() -> CGFloat {
        var tabBarHeight: CGFloat = 0
        if isIPad {
            if isNotchedScreen {
                tabBarHeight = 65
            }else {
                if let version = version, version >= 12.0 {
                    tabBarHeight = 50
                }else {
                    tabBarHeight = 49
                }
            }
        }else {
            if isLandScape() {
                if isRegularScreen() {
                    tabBarHeight = 49
                }else {
                    tabBarHeight = 32
                }
            }else {
                tabBarHeight = 49
            }
            tabBarHeight += safeAreaInsertsForDeviceWithNotch().bottom
        }
        return tabBarHeight
    }
    
    public static func safeAreaInsets() -> UIEdgeInsets {
        var safeAreaInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            var window = keyWindow()
            if window == nil {
                // keyWindow还没有创建时，通过创建临时window获取安全区域
                window = UIWindow(frame: UIScreen.main.bounds)
                if window!.safeAreaInsets.bottom <= 0 {
                    let viewController = UIViewController()
                    window?.rootViewController = viewController
                }
            }
            safeAreaInsets = window!.safeAreaInsets
        }
        return safeAreaInsets
    }
    
    public static func statusBarFrame() -> CGRect {
        var statusBarFrame = CGRect.zero
        if #available(iOS 13.0, *) {
            statusBarFrame = keyWindow()?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
        }
        
        if statusBarFrame == .zero {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        
        if statusBarFrame == .zero {
            let statusBarH = isNotchedScreen ? 44 : 20
            statusBarFrame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.size.width), height: statusBarH)
        }
        
        return statusBarFrame
    }
    
    public static func keyWindow() -> UIWindow? {
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
        
        if window == nil {
            window = UIApplication.shared.delegate?.window ?? nil
        }
        
        return window
    }
    
    public static func safeAreaInsertsForDeviceWithNotch() -> UIEdgeInsets {
        if !isNotchedScreen {
            return .zero
        }
        
        if isIPad {
            return UIEdgeInsets(top: 24, left: 0, bottom: 20, right: 0)
        }
        
        let dict = [
            // iPhone 14
            "iPhone14,7": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 47, bottom: 21, right: 47)],
            "iPhone14,7-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 48, left: 0, bottom: 28, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 48, bottom: 21, right: 48)],
            // iPhone 14 Plus
            "iPhone14,8": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 47, bottom: 21, right: 47)],
            "iPhone14,8-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 41, left: 0, bottom: 30, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 41, bottom: 21, right: 41)],
            // iPhone 14 Pro
            "iPhone15,2": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 59, bottom: 21, right: 59)],
            "iPhone15,2-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 48, left: 0, bottom: 28, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 48, bottom: 21, right: 48)],
            // iPhone 14 Pro Max
            "iPhone15,3": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 59, bottom: 21, right: 59)],
            "iPhone15,3-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 51, left: 0, bottom: 31, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 51, bottom: 21, right: 51)],
            // iPhone 13 mini
            "iPhone14,4": [UIInterfaceOrientation.portrait : UIEdgeInsets(top: 50, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 50, bottom: 21, right: 50)],
            "iPhone14,4-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 43, left: 0, bottom: 29, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 43, bottom: 21, right: 43)],
            // iPhone 13
            "iPhone14,5": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 47, bottom: 21, right: 47)],
            "iPhone14,5-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 39, left: 0, bottom: 28, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 39, bottom: 2, right: 39)],
            // iPhone 13 Pro
            "iPhone14,2": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
                            UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 47, bottom: 21, right: 47)],
            "iPhone14,2-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 39, left: 0, bottom: 28, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 39, bottom: 21, right: 39)],
            // iPhone 13 Pro Max
            "iPhone14,3": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 47, bottom: 21, right: 47)],
            "iPhone14,3-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 41, left: 0, bottom: 29 + 2.0 / 3.0, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 41, bottom: 21, right: 41)],
            // iPhone 12 mini
            "iPhone13,1": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 50, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 50, bottom: 21, right: 50)],
            "iPhone13,1-Zoom": [.portrait: UIEdgeInsets(top: 43, left: 0, bottom: 29, right: 0),
                                .landscapeLeft: UIEdgeInsets(top: 0, left: 43, bottom: 21, right: 43)],
            // iPhone 12
            "iPhone13,2": [.portrait: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
                           .landscapeLeft: UIEdgeInsets(top: 0, left: 47, bottom: 21, right: 47)],
            "iPhone13,2-Zoom": [.portrait: UIEdgeInsets(top: 39, left: 0, bottom: 28, right: 0),
                                .landscapeLeft: UIEdgeInsets(top: 0, left: 39, bottom: 21, right: 39)],
            // iPhone 12 Pro
            "iPhone13,3": [.portrait: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
                           .landscapeLeft: UIEdgeInsets(top: 0, left: 47, bottom: 21, right: 47)],
            "iPhone13,3-Zoom": [.portrait: UIEdgeInsets(top: 39, left: 0, bottom: 28, right: 0),
                                .landscapeLeft: UIEdgeInsets(top: 0, left: 39, bottom: 21, right: 39)],
            // iPhone 12 Pro Max
            "iPhone13,4": [.portrait: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
                           .landscapeLeft: UIEdgeInsets(top: 0, left: 47, bottom: 21, right: 47)],
            "iPhone13,4-Zoom": [.portrait: UIEdgeInsets(top: 41, left: 0, bottom: 29 + 2.0 / 3.0, right: 0),
                                .landscapeLeft: UIEdgeInsets(top: 0, left: 41, bottom: 21, right: 41)],
            // iPhone 11
            "iPhone12,1": [.portrait: UIEdgeInsets(top: 48, left: 0, bottom: 34, right: 0),
                           .landscapeLeft: UIEdgeInsets(top: 0, left: 48, bottom: 21, right: 48)],
            "iPhone12,1-Zoom": [.portrait: UIEdgeInsets(top: 44, left: 0, bottom: 31, right: 0),
                                .landscapeLeft: UIEdgeInsets(top: 0, left: 44, bottom: 21, right: 44)],
            // iPhone 11 Pro Max
            "iPhone12,5": [.portrait: UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0),
                           .landscapeLeft: UIEdgeInsets(top: 0, left: 44, bottom: 21, right: 44)],
            "iPhone12,5-Zoom": [.portrait: UIEdgeInsets(top: 40, left: 0, bottom: 30 + 2.0 / 3.0, right: 0),
                                .landscapeLeft: UIEdgeInsets(top: 0, left: 40, bottom: 21, right: 40)]
        ]
        var deviceKey = deviceModel
        if dict[deviceKey] == nil {
            deviceKey = "iPhone15,2" // 默认按最新的机型处理，因为新出的设备肯定更大概率与上一代设备相似
        }
        if isZoomedMode() {
            deviceKey = deviceKey + "-Zoom"
        }
        
        var orientationKey = UIInterfaceOrientation.unknown
        let orientation = UIApplication.shared.statusBarOrientation
        switch orientation {
        case .landscapeLeft:
            orientationKey = .landscapeLeft
            break
        case .landscapeRight:
            orientationKey = .landscapeLeft
            break
        default:
            orientationKey = .portrait
        }
        
        let value = dict[deviceKey]
        var insets = value![orientationKey]!
        if orientation == .portraitUpsideDown {
            insets = UIEdgeInsets(top: insets.bottom, left: insets.left, bottom: insets.top, right: insets.right)
        }else if orientation == .landscapeRight {
            insets = UIEdgeInsets(top: insets.top, left: insets.right, bottom: insets.bottom, right: insets.left)
        }
        return insets
    }
}

extension GKDevice {
    public static let version: Double? = {
       return Double(UIDevice.current.systemVersion)
    }()
    
    public static let width: CGFloat = {
        min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    }()
    
    public static let height: CGFloat = {
        max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    }()
    
    // MARK - Screen
    /// iPhone 14 Pro Max
    public static let is67InchScreenAndiPhone14ProMax: Bool = {
        return width == _67InchAndiPhone14ProMax.width && height == _67InchAndiPhone14ProMax.height
    }()
    
    /// iPhone 12 Pro Max
    public static let is67InchScreen: Bool = {
        return width == _67Inch.width && height == _67Inch.height
    }()
    
    /// iPhone XS Max / 11 Pro Max
    public static let is65InchScreen: Bool = {
        // 由于 iPhone XS Max、iPhone 11 Pro Max 这两款机型和 iPhone XR 的屏幕宽高是一致的，我们通过机器的 Identifier 加以区别
        return (width == _65Inch.width && height == _65Inch.height && (deviceModel == "iPhone11,4" || deviceModel == "iPhone11,6" || deviceModel == "iPhone12,5"))
    }()
    
    /// iPhone 14 Pro
    public static let is61InchScreenAndiPhone14Pro: Bool = {
        return width == _61InchAndiPhone14Pro.width && height == _61InchAndiPhone14Pro.height
    }()
    
    /// iPhone 12 / 12 Pro
    public static let is61InchScreenAndiPhone12Later: Bool = {
        return width == _61InchAndiPhone12Later.width && height == _61InchAndiPhone12Later.height
    }()
    
    /// iPhone XR / 11
    public static let is61InchScreen: Bool = {
        return (width == _61Inch.width && height == _61Inch.height && (deviceModel == "iPhone11,8" || deviceModel == "iPhone12,1"))
    }()
    
    /// iPhone X / XS / 11 Pro
    public static let is58InchScreen: Bool = {
        // iPhone XS 和 iPhone X 的物理尺寸是一致的，因此无需比较机器 Identifier
        return width == _58Inch.width && height == _58Inch.height
    }()
    
    /// iPhone 6，6s，7，8 Plus
    public static let is55InchScreen: Bool = {
        return width == _55Inch.width && height == _55Inch.height
    }()
    
    /// iPhone 12 mini
    public static let is54InchScreen: Bool = {
        return width == _54Inch.width && height == _54Inch.height
    }()
    
    /// iPhone 6，6s，7，8，SE2
    public static let is47InchScreen: Bool = {
        return width == _47Inch.width && height == _47Inch.height
    }()
    
    /// iPhone 5，5s，5c，SE
    public static let is40InchScreen: Bool = {
        return width == _40Inch.width && height == _40Inch.height
    }()
    
    /// iPhone 4
    public static let is35InchScreen: Bool = {
        return width == _35Inch.width && height == _35Inch.height
    }()
    
    public static let _67InchAndiPhone14ProMax: CGSize = {
       return CGSize(width: 430, height: 932)
    }()
    
    public static let _67Inch: CGSize = {
        return CGSize(width: 428, height: 926)
    }()
    
    public static let _65Inch: CGSize = {
        return CGSize(width: 414, height: 896)
    }()
    
    public static let _61InchAndiPhone14Pro: CGSize = {
        return CGSize(width: 393, height: 852)
    }()
    
    public static let _61InchAndiPhone12Later: CGSize = {
        return CGSize(width: 390, height: 844)
    }()
    
    public static let _61Inch: CGSize = {
        return CGSize(width: 414, height: 896)
    }()
    
    public static let _58Inch: CGSize = {
        return CGSize(width: 375, height: 812)
    }()
    
    public static let _55Inch: CGSize = {
        return CGSize(width: 414, height: 736)
    }()
    
    public static let _54Inch: CGSize = {
        return CGSize(width: 375, height: 812)
    }()
    
    public static let _47Inch: CGSize = {
        return CGSize(width: 375, height: 667)
    }()
    
    public static let _40Inch: CGSize = {
        return CGSize(width: 320, height: 568)
    }()
    
    public static let _35Inch: CGSize = {
        return CGSize(width: 320, height: 480)
    }()
}
