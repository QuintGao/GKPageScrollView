//
//  GKNavigationBarConfigure.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/24.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

public let GKConfigure = GKNavigationBarConfigure.shared
let GK_DEVICE_WIDTH = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
let GK_DEVICE_HEIGHT = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
let GK_SYSTEM_VERSION = Double(UIDevice.current.systemVersion)

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
    
    // 以下属性需要设置导航栏转场缩放为YES
    /// 手机系统大于11.0，使用下面的值控制x、y轴的位移距离，默认（5，5）
    open var gk_translationX: CGFloat = 5.0
    open var gk_translationY: CGFloat = 5.0

    /// 手机系统小于11.0，使用下面的值控制x、y周的缩放程度，默认（0.95，0.97）
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
    
    /// 设置默认配置
    open func setupDefault() {
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
        UIScrollView.gkAwake()
        UIViewController.gkGestureAwake()
        UINavigationController.gkGestureChildAwake()
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
        // 经测试发现iPhone 12，iPhone 12，默认导航栏间距是16，需要单独处理
        if GKDevice.is61InchScreenAndiPhone12Later() {
            return 16
        }
        return GK_DEVICE_WIDTH > 375.0 ? 20 : 16
    }
    
    /// 获取Bundle
    public func gk_libraryBundle() -> Bundle? {
        let bundle = Bundle(for: self.classForCoder)
        let bundleURL = bundle.url(forResource: "GKNavigationBarSwift", withExtension: "bundle")
        guard let url = bundleURL else { return nil }
        return Bundle(url: url)
    }
    
    public func fixNavItemSpaceDisabled() -> Bool {
        return self.gk_disableFixSpace && !self.gk_openSystemFixSpace
    }
    
    // 内部方法
    open func isVelocityInsensitivity(_ velocity: CGFloat) -> Bool {
        return (abs(velocity) - (1000.0 * (1 - self.gk_snapMovementSensitivity))) > 0;
    }
    
    /// 获取某个view的截图
    open func getCapture(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

open class GKDevice {
    class public func deviceModel() -> String {
        if self.isSimulator() {
            // 模拟器不返回物理机器信息，但会通过环境变量的方式返回
            return String(describing: getenv("SIMULATOR_MODEL_IDENTIFIER"))
        }
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    class public func isZoomedMode() -> Bool {
        if !self.isIPhone() {
            return false
        }
        let nativeScale = UIScreen.main.nativeScale
        var scale = UIScreen.main.scale
        
        // 对于所有的Plus系列iPhone，屏幕物理像素低于软件层面的渲染像素，不管标准模式还是放大模式，nativeScale均小于scale，所以需要特殊处理才能准确区分放大模式
        let shouldBeDownsampledDevice = __CGSizeEqualToSize(UIScreen.main.nativeBounds.size, CGSize(width: 1080, height: 1920))
        if shouldBeDownsampledDevice {
            scale /= 1.15
        }
        return nativeScale > scale
    }
    
    class public func isIPad() -> Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }
    
    class public func isIPod() -> Bool {
        let model = UIDevice.current.model as NSString
        return model.range(of: "iPod touch").location != NSNotFound
    }
    
    class public func isIPhone() -> Bool {
        let model = UIDevice.current.model as NSString
        return model.range(of: "iPhone").location != NSNotFound
    }
    
    class public func isSimulator() -> Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }
    
    class public func isMac() -> Bool {
#if IOS14_SDK_ALLOWED
        if #available(iOS 14.0, *) {
            return ProcessInfo.processInfo.isiOSAppOnMac || ProcessInfo.processInfo.isMacCatalystApp
        }
#endif
        if #available(iOS 13.0, *) {
            return ProcessInfo.processInfo.isMacCatalystApp
        }
        return false
    }
    
    /// 带物理凹槽的刘海屏或使用 Home Indicator 类型的设备
    class public func isNotchedScreen() -> Bool {
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
    }
    
    /// 将屏幕分为普通和紧凑两种，这个方法用于判断普通屏幕（也即大屏幕）
    class public func isRegularScreen() -> Bool {
        return isIPad() || (!isZoomedMode() && (is67InchScreen() || is65InchScreen() || is61InchScreen() || is55InchScreen()))
    }
    
    /// 是否是横屏
    class public func isLandScape() -> Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    
    // MARK - Screen
    /// iPhone 12 Pro Max
    class public func is67InchScreen() -> Bool {
        return GK_DEVICE_WIDTH == screenSizeFor67Inch().width && GK_DEVICE_HEIGHT == screenSizeFor67Inch().height
    }
    
    /// iPhone XS Max / 11 Pro Max
    class public func is65InchScreen() -> Bool {
        // 由于 iPhone XS Max、iPhone 11 Pro Max 这两款机型和 iPhone XR 的屏幕宽高是一致的，我们通过机器的 Identifier 加以区别
        return (GK_DEVICE_HEIGHT == screenSizeFor65Inch().width && GK_DEVICE_HEIGHT == screenSizeFor65Inch().height && (deviceModel() == "iPhone11,4" || deviceModel() == "iPhone11,6" || deviceModel() == "iPhone12,5"))
    }
    
    /// iPhone 12 / 12 Pro
    public class func is61InchScreenAndiPhone12Later() -> Bool {
        return GK_DEVICE_WIDTH == screenSizeFor61InchAndiPhone12Later().width && GK_DEVICE_HEIGHT == screenSizeFor61InchAndiPhone12Later().height
    }
    
    /// iPhone XR / 11
    class public func is61InchScreen() -> Bool {
        return (GK_DEVICE_WIDTH == screenSizeFor61Inch().width && GK_DEVICE_HEIGHT == screenSizeFor61Inch().height && (deviceModel() == "iPhone11,8" || deviceModel() == "iPhone12,1"))
    }
    
    /// iPhone X / XS / 11 Pro
    class public func is58InchScreen() -> Bool {
        // iPhone XS 和 iPhone X 的物理尺寸是一致的，因此无需比较机器 Identifier
        return GK_DEVICE_WIDTH == screenSizeFor58Inch().width && GK_DEVICE_HEIGHT == screenSizeFor58Inch().height
    }
    
    /// iPhone 6，6s，7，8 Plus
    class public func is55InchScreen() -> Bool {
        return GK_DEVICE_WIDTH == screenSizeFor55Inch().width && GK_DEVICE_HEIGHT == screenSizeFor55Inch().height
    }
    
    /// iPhone 12 mini
    class public func is54InchScreen() -> Bool {
        return GK_DEVICE_WIDTH == screenSizeFor54Inch().width && GK_DEVICE_HEIGHT == screenSizeFor54Inch().height
    }
    
    /// iPhone 6，6s，7，8，SE2
    class public func is47InchScreen() -> Bool {
        return GK_DEVICE_WIDTH == screenSizeFor47Inch().width && GK_DEVICE_HEIGHT == screenSizeFor47Inch().height
    }
    
    /// iPhone 5，5s，5c，SE
    class public func is40InchScreen() -> Bool {
        return GK_DEVICE_WIDTH == screenSizeFor40Inch().width && GK_DEVICE_HEIGHT == screenSizeFor40Inch().height
    }
    
    /// iPhone 4
    class public func is35InchScreen() -> Bool {
        return GK_DEVICE_WIDTH == screenSizeFor35Inch().width && GK_DEVICE_HEIGHT == screenSizeFor35Inch().height
    }
    
    // MARK - ScreenSize
    class public func screenSizeFor67Inch() -> CGSize {
        return CGSize(width: 428, height: 926)
    }
    
    class public func screenSizeFor65Inch() -> CGSize {
        return CGSize(width: 414, height: 896)
    }
    
    class public func screenSizeFor61InchAndiPhone12Later() -> CGSize {
        return CGSize(width: 390, height: 844)
    }
    
    class public func screenSizeFor61Inch() -> CGSize {
        return CGSize(width: 414, height: 896)
    }
    
    class public func screenSizeFor58Inch() -> CGSize {
        return CGSize(width: 375, height: 812)
    }
    
    class public func screenSizeFor55Inch() -> CGSize {
        return CGSize(width: 414, height: 736)
    }
    
    class public func screenSizeFor54Inch() -> CGSize {
        return CGSize(width: 375, height: 812)
    }
    
    class public func screenSizeFor47Inch() -> CGSize {
        return CGSize(width: 375, height: 667)
    }
    
    class public func screenSizeFor40Inch() -> CGSize {
        return CGSize(width: 320, height: 568)
    }
    
    class public func screenSizeFor35Inch() -> CGSize {
        return CGSize(width: 320, height: 480)
    }
    
    class public func statusBarNavBarHeight() -> CGFloat {
        return statusBarFrame().size.height + navBarHeight()
    }
    
    class public func navBarHeight() -> CGFloat {
        if isIPad() {
            if let version = GK_SYSTEM_VERSION, version >= 12.0 {
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
    
    class public func navBarHeightNonFullScreen() -> CGFloat {
        return 56
    }
    
    class public func tabBarHeight() -> CGFloat {
        var tabBarHeight: CGFloat = 0
        if self.isIPad() {
            if self.isNotchedScreen() {
                tabBarHeight = 65
            }else {
                if let version = GK_SYSTEM_VERSION, version >= 12.0 {
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
    
    class public func safeAreaInsets() -> UIEdgeInsets {
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
    
    class public func statusBarFrame() -> CGRect {
        var statusBarFrame = CGRect.zero
        if #available(iOS 13.0, *) {
            statusBarFrame = keyWindow()?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
        }
        
        if statusBarFrame == .zero {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        
        if statusBarFrame == .zero {
            let statusBarH = isNotchedScreen() ? 44 : 20
            statusBarFrame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.size.width), height: statusBarH)
        }
        
        return statusBarFrame
    }
    
    class public func keyWindow() -> UIWindow? {
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
            window = (UIApplication.shared.delegate?.window)!
        }
        
        return window
    }
    
    class public func safeAreaInsertsForDeviceWithNotch() -> UIEdgeInsets {
        if !self.isNotchedScreen() {
            return .zero
        }
        
        if self.isIPad() {
            return UIEdgeInsets(top: 24, left: 0, bottom: 20, right: 0)
        }
        
        let dict = [
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
        var deviceKey = self.deviceModel()
        if dict[deviceKey] == nil {
            deviceKey = "iPhone14,2" // 默认按最新的 iPhone 13 Pro处理，因为新出的设备肯定更大概率与上一代设备相似
        }
        if self.isZoomedMode() {
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
