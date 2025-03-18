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
        awake()
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
    /// param block 配置回调
    open func setupCustom(_ block: @escaping (GKNavigationBarConfigure) -> Void) {
        setupDefault()
        
        block(self)
        
        disableFixSpace = gk_disableFixSpace
        navItemLeftSpace = gk_navItemLeftSpace
        navItemRightSpace = gk_navItemRightSpace
    }

    /// 更新配置
    /// param block 配置回调
    open func update(_ block: @escaping (GKNavigationBarConfigure) -> Void) {
        block(self)
    }
    
    open func visibleViewController() -> UIViewController? {
        return UIDevice.keyWindow()?.rootViewController?.gk_findCurrentViewController(true)
    }
    
    /// 获取当前item修复间距
    open func gk_fixedSpace() -> CGFloat {
        // 经测试发现iPhone 12 和 12 Pro 到 16 和 16 Pro，默认导航栏间距都是16，所以做下处理
        // 12 / 13 / 14 / 12 Pro / 13 Pro
        if (UIDevice.is61InchScreenAndiPhone12Later) {
            return 16;
        }
        // 14 Pro / 15 / 16 / 15 Pro
        if (UIDevice.is61InchScreenAndiPhone14ProLater) {
            return 16;
        }
        // 16 Pro
        if (UIDevice.is63InchScreen) {
            return 16;
        }
        return UIDevice.width > 375.0 ? 20 : 16
    }
    
    open func fixNavItemSpaceDisabled() -> Bool {
        return self.gk_disableFixSpace && !self.gk_openSystemFixSpace
    }
    
    // 内部方法
    open func isVelocityInsensitivity(_ velocity: CGFloat) -> Bool {
        return (abs(velocity) - (1000.0 * (1 - self.gk_snapMovementSensitivity))) > 0;
    }
    
    /// 获取某个view的截图
    open func getCapture(with view: UIView?) -> UIImage? {
        guard let view else { return nil }
        if view.bounds.size.width <= 0 || view.bounds.size.height <= 0 { return nil }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIDevice {
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
    
    public static let deviceName: String = {
        let model = deviceModel
        var name: String?
        let dict = [
            // See https://gist.github.com/adamawolf/3048717
            "iPhone1,1" : "iPhone 1G",
            "iPhone1,2" : "iPhone 3G",
            "iPhone2,1" : "iPhone 3GS",
            "iPhone3,1" : "iPhone 4 (GSM)",
            "iPhone3,2" : "iPhone 4",
            "iPhone3,3" : "iPhone 4 (CDMA)",
            "iPhone4,1" : "iPhone 4S",
            "iPhone5,1" : "iPhone 5",
            "iPhone5,2" : "iPhone 5",
            "iPhone5,3" : "iPhone 5c",
            "iPhone5,4" : "iPhone 5c",
            "iPhone6,1" : "iPhone 5s",
            "iPhone6,2" : "iPhone 5s",
            "iPhone7,1" : "iPhone 6 Plus",
            "iPhone7,2" : "iPhone 6",
            "iPhone8,1" : "iPhone 6s",
            "iPhone8,2" : "iPhone 6s Plus",
            "iPhone8,4" : "iPhone SE",
            "iPhone9,1" : "iPhone 7",
            "iPhone9,2" : "iPhone 7 Plus",
            "iPhone9,3" : "iPhone 7",
            "iPhone9,4" : "iPhone 7 Plus",
            "iPhone10,1" : "iPhone 8",
            "iPhone10,2" : "iPhone 8 Plus",
            "iPhone10,3" : "iPhone X",
            "iPhone10,4" : "iPhone 8",
            "iPhone10,5" : "iPhone 8 Plus",
            "iPhone10,6" : "iPhone X",
            "iPhone11,2" : "iPhone XS",
            "iPhone11,4" : "iPhone XS Max",
            "iPhone11,6" : "iPhone XS Max CN",
            "iPhone11,8" : "iPhone XR",
            "iPhone12,1" : "iPhone 11",
            "iPhone12,3" : "iPhone 11 Pro",
            "iPhone12,5" : "iPhone 11 Pro Max",
            "iPhone12,8" : "iPhone SE (2nd generation)",
            "iPhone13,1" : "iPhone 12 mini",
            "iPhone13,2" : "iPhone 12",
            "iPhone13,3" : "iPhone 12 Pro",
            "iPhone13,4" : "iPhone 12 Pro Max",
            "iPhone14,4" : "iPhone 13 mini",
            "iPhone14,5" : "iPhone 13",
            "iPhone14,2" : "iPhone 13 Pro",
            "iPhone14,3" : "iPhone 13 Pro Max",
            "iPhone14,7" : "iPhone 14",
            "iPhone14,8" : "iPhone 14 Plus",
            "iPhone15,2" : "iPhone 14 Pro",
            "iPhone15,3" : "iPhone 14 Pro Max",
            "iPhone15,4" : "iPhone 15",
            "iPhone15,5" : "iPhone 15 Plus",
            "iPhone16,1" : "iPhone 15 Pro",
            "iPhone16,2" : "iPhone 15 Pro Max",
            "iPhone17,1" : "iPhone 16 Pro",
            "iPhone17,2" : "iPhone 16 Pro Max",
            "iPhone17,3" : "iPhone 16",
            "iPhone17,4" : "iPhone 16 Plus",
            
            "iPad1,1" : "iPad 1",
            "iPad2,1" : "iPad 2 (WiFi)",
            "iPad2,2" : "iPad 2 (GSM)",
            "iPad2,3" : "iPad 2 (CDMA)",
            "iPad2,4" : "iPad 2",
            "iPad2,5" : "iPad mini 1",
            "iPad2,6" : "iPad mini 1",
            "iPad2,7" : "iPad mini 1",
            "iPad3,1" : "iPad 3 (WiFi)",
            "iPad3,2" : "iPad 3 (4G)",
            "iPad3,3" : "iPad 3 (4G)",
            "iPad3,4" : "iPad 4",
            "iPad3,5" : "iPad 4",
            "iPad3,6" : "iPad 4",
            "iPad4,1" : "iPad Air",
            "iPad4,2" : "iPad Air",
            "iPad4,3" : "iPad Air",
            "iPad4,4" : "iPad mini 2",
            "iPad4,5" : "iPad mini 2",
            "iPad4,6" : "iPad mini 2",
            "iPad4,7" : "iPad mini 3",
            "iPad4,8" : "iPad mini 3",
            "iPad4,9" : "iPad mini 3",
            "iPad5,1" : "iPad mini 4",
            "iPad5,2" : "iPad mini 4",
            "iPad5,3" : "iPad Air 2",
            "iPad5,4" : "iPad Air 2",
            "iPad6,3" : "iPad Pro (9.7 inch)",
            "iPad6,4" : "iPad Pro (9.7 inch)",
            "iPad6,7" : "iPad Pro (12.9 inch)",
            "iPad6,8" : "iPad Pro (12.9 inch)",
            "iPad6,11": "iPad 5 (WiFi)",
            "iPad6,12": "iPad 5 (Cellular)",
            "iPad7,1" : "iPad Pro (12.9 inch, 2nd generation)",
            "iPad7,2" : "iPad Pro (12.9 inch, 2nd generation)",
            "iPad7,3" : "iPad Pro (10.5 inch)",
            "iPad7,4" : "iPad Pro (10.5 inch)",
            "iPad7,5" : "iPad 6 (WiFi)",
            "iPad7,6" : "iPad 6 (Cellular)",
            "iPad7,11": "iPad 7 (WiFi)",
            "iPad7,12": "iPad 7 (Cellular)",
            "iPad8,1" : "iPad Pro (11 inch)",
            "iPad8,2" : "iPad Pro (11 inch)",
            "iPad8,3" : "iPad Pro (11 inch)",
            "iPad8,4" : "iPad Pro (11 inch)",
            "iPad8,5" : "iPad Pro (12.9 inch, 3rd generation)",
            "iPad8,6" : "iPad Pro (12.9 inch, 3rd generation)",
            "iPad8,7" : "iPad Pro (12.9 inch, 3rd generation)",
            "iPad8,8" : "iPad Pro (12.9 inch, 3rd generation)",
            "iPad8,9" : "iPad Pro (11 inch, 2nd generation)",
            "iPad8,10" : "iPad Pro (11 inch, 2nd generation)",
            "iPad8,11" : "iPad Pro (12.9 inch, 4th generation)",
            "iPad8,12" : "iPad Pro (12.9 inch, 4th generation)",
            "iPad11,1" : "iPad mini (5th generation)",
            "iPad11,2" : "iPad mini (5th generation)",
            "iPad11,3" : "iPad Air (3rd generation)",
            "iPad11,4" : "iPad Air (3rd generation)",
            "iPad11,6" : "iPad (WiFi)",
            "iPad11,7" : "iPad (Cellular)",
            "iPad13,1" : "iPad Air (4th generation)",
            "iPad13,2" : "iPad Air (4th generation)",
            "iPad13,4" : "iPad Pro (11 inch, 3rd generation)",
            "iPad13,5" : "iPad Pro (11 inch, 3rd generation)",
            "iPad13,6" : "iPad Pro (11 inch, 3rd generation)",
            "iPad13,7" : "iPad Pro (11 inch, 3rd generation)",
            "iPad13,8" : "iPad Pro (12.9 inch, 5th generation)",
            "iPad13,9" : "iPad Pro (12.9 inch, 5th generation)",
            "iPad13,10" : "iPad Pro (12.9 inch, 5th generation)",
            "iPad13,11" : "iPad Pro (12.9 inch, 5th generation)",
            "iPad14,1" : "iPad mini (6th generation)",
            "iPad14,2" : "iPad mini (6th generation)",
            "iPad14,3" : "iPad Pro 11 inch 4th Gen",
            "iPad14,4" : "iPad Pro 11 inch 4th Gen",
            "iPad14,5" : "iPad Pro 12.9 inch 6th Gen",
            "iPad14,6" : "iPad Pro 12.9 inch 6th Gen",
            "iPad14,8" : "iPad Air 6th Gen",
            "iPad14,9" : "iPad Air 6th Gen",
            "iPad14,10" : "iPad Air 7th Gen",
            "iPad14,11" : "iPad Air 7th Gen",
            "iPad16,3" : "iPad Pro 11 inch 5th Gen",
            "iPad16,4" : "iPad Pro 11 inch 5th Gen",
            "iPad16,5" : "iPad Pro 12.9 inch 7th Gen",
            "iPad16,6" : "iPad Pro 12.9 inch 7th Gen",
            
            "iPod1,1" : "iPod touch 1",
            "iPod2,1" : "iPod touch 2",
            "iPod3,1" : "iPod touch 3",
            "iPod4,1" : "iPod touch 4",
            "iPod5,1" : "iPod touch 5",
            "iPod7,1" : "iPod touch 6",
            "iPod9,1" : "iPod touch 7",
            
            "i386" : "Simulator x86",
            "x86_64" : "Simulator x64",
            
            "Watch1,1" : "Apple Watch 38mm",
            "Watch1,2" : "Apple Watch 42mm",
            "Watch2,3" : "Apple Watch Series 2 38mm",
            "Watch2,4" : "Apple Watch Series 2 42mm",
            "Watch2,6" : "Apple Watch Series 1 38mm",
            "Watch2,7" : "Apple Watch Series 1 42mm",
            "Watch3,1" : "Apple Watch Series 3 38mm",
            "Watch3,2" : "Apple Watch Series 3 42mm",
            "Watch3,3" : "Apple Watch Series 3 38mm (LTE)",
            "Watch3,4" : "Apple Watch Series 3 42mm (LTE)",
            "Watch4,1" : "Apple Watch Series 4 40mm",
            "Watch4,2" : "Apple Watch Series 4 44mm",
            "Watch4,3" : "Apple Watch Series 4 40mm (LTE)",
            "Watch4,4" : "Apple Watch Series 4 44mm (LTE)",
            "Watch5,1" : "Apple Watch Series 5 40mm",
            "Watch5,2" : "Apple Watch Series 5 44mm",
            "Watch5,3" : "Apple Watch Series 5 40mm (LTE)",
            "Watch5,4" : "Apple Watch Series 5 44mm (LTE)",
            "Watch5,9" : "Apple Watch SE 40mm",
            "Watch5,10" : "Apple Watch SE 44mm",
            "Watch5,11" : "Apple Watch SE 40mm",
            "Watch5,12" : "Apple Watch SE 44mm",
            "Watch6,1"  : "Apple Watch Series 6 40mm",
            "Watch6,2"  : "Apple Watch Series 6 44mm",
            "Watch6,3"  : "Apple Watch Series 6 40mm",
            "Watch6,4"  : "Apple Watch Series 6 44mm",
            "Watch6,6" : "Apple Watch Series 7 41mm case (GPS)",
            "Watch6,7" : "Apple Watch Series 7 45mm case (GPS)",
            "Watch6,8" : "Apple Watch Series 7 41mm case (GPS+Cellular)",
            "Watch6,9" : "Apple Watch Series 7 45mm case (GPS+Cellular)",
            "Watch6,10" : "Apple Watch SE 40mm case (GPS)",
            "Watch6,11" : "Apple Watch SE 44mm case (GPS)",
            "Watch6,12" : "Apple Watch SE 40mm case (GPS+Cellular)",
            "Watch6,13" : "Apple Watch SE 44mm case (GPS+Cellular)",
            "Watch6,14" : "Apple Watch Series 8 41mm case (GPS)",
            "Watch6,15" : "Apple Watch Series 8 45mm case (GPS)",
            "Watch6,16" : "Apple Watch Series 8 41mm case (GPS+Cellular)",
            "Watch6,17" : "Apple Watch Series 8 45mm case (GPS+Cellular)",
            "Watch6,18" : "Apple Watch Ultra",
            "Watch7,1" : "Apple Watch Series 9 41mm case (GPS)",
            "Watch7,2" : "Apple Watch Series 9 45mm case (GPS)",
            "Watch7,3" : "Apple Watch Series 9 41mm case (GPS+Cellular)",
            "Watch7,4" : "Apple Watch Series 9 45mm case (GPS+Cellular)",
            "Watch7,5" : "Apple Watch Ultra 2",
            
            "AudioAccessory1,1" : "HomePod",
            "AudioAccessory1,2" : "HomePod",
            "AudioAccessory5,1" : "HomePod mini",
            
            "AirPods1,1" : "AirPods (1st generation)",
            "AirPods2,1" : "AirPods (2nd generation)",
            "iProd8,1"   : "AirPods Pro",
            
            "AppleTV2,1" : "Apple TV 2",
            "AppleTV3,1" : "Apple TV 3",
            "AppleTV3,2" : "Apple TV 3",
            "AppleTV5,3" : "Apple TV 4",
            "AppleTV6,2" : "Apple TV 4K",
        ]
        name = dict[model]
        if name == nil || name == "" {
            name = model
        }
        guard var name else { return "Unknown Device" }
        if isSimulator {
            name = name + " Simulator"
        }
        return name
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
    
    // 是否是带灵动岛的屏幕
    //"iPhone15,2" : "iPhone 14 Pro",
    //"iPhone15,3" : "iPhone 14 Pro Max",
    //"iPhone15,4" : "iPhone 15",
    //"iPhone15,5" : "iPhone 15 Plus",
    //"iPhone16,1" : "iPhone 15 Pro",
    //"iPhone16,2" : "iPhone 15 Pro Max",
    //"iPhone17,1" : "iPhone 16 Pro",
    //"iPhone17,2" : "iPhone 16 Pro Max",
    //"iPhone17,3" : "iPhone 16",
    //"iPhone17,4" : "iPhone 16 Plus",
    public static func isDynamicIslandScreen() -> Bool {
        if !isIPhone { return false }
        let models = ["iPhone 14 Pro", "iPhone 15", "iPhone 16"]
        return models.contains { deviceName.hasPrefix($0) }
    }
    
    /// 将屏幕分为普通和紧凑两种，这个方法用于判断普通屏幕（也即大屏幕）
    public static func isRegularScreen() -> Bool {
        if isDynamicIslandScreen() { return true }
        return isIPad || (!isZoomedMode() && (is67InchScreenAndiPhone14Later || is67InchScreen || is65InchScreen || is61InchScreen || is55InchScreen))
    }
    
    /// 是否是横屏
    public static func isLandScape() -> Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    
    public static func statusBarNavBarHeight() -> CGFloat {
        return navBarFullHeight()
    }
    
    /// 导航栏高度（无状态栏）
    public static func navBarHeight() -> CGFloat {
        if isIPad {
            return version >= 12.0 ? 50 : 44
        }else {
            if isLandScape() {
                return isRegularScreen() ? 44 : 32
            }else {
                return 44
            }
        }
    }
    
    /// 导航栏竖屏高度（无状态栏）
    public static func navBarHeightForPortrait() -> CGFloat {
        if isIPad {
            return version >= 12.0 ? 50 : 44
        }else {
            return 44
        }
    }
    
    /// 非全屏时的导航栏高度
    public static func navBarHeightNonFullScreen() -> CGFloat {
        return 56
    }
    
    /// 导航栏完整高度（状态栏+导航栏），状态栏隐藏时只有导航栏高度
    public static func navBarFullHeight() -> CGFloat {
        let deviceModel = deviceModel
        let pixelOne = 1.0 / UIScreen.main.scale
        var result = statusBarFullHeight()
        if isIPad {
            result += 50
        }else if isLandScape() {
            result += isRegularScreen() ? 44 : 32
        }else {
            result += 44
            if deviceModel == "iPhone17,1" || deviceModel == "iPhone17,2" { // 16 Pro / 16 Pro Max
                result += (2 + pixelOne) // 56.333
            }else if isDynamicIslandScreen() {
                result -= pixelOne // 53.667
            }
        }
        return result
    }
    
    /// 竖屏导航栏完整高度（状态栏+导航栏）
    public static func navBarFullHeightForPortrait() -> CGFloat {
        let deviceModel = deviceModel
        let pixelOne = 1.0 / UIScreen.main.scale
        var result = statusBarHeightForPortrait()
        if isIPad {
            result += 50
        }else {
            result += 44
            if deviceModel == "iPhone17,1" || deviceModel == "iPhone17,2" { // 16 Pro / 16 Pro Max
                result += (2 + pixelOne) // 56.333
            }else if isDynamicIslandScreen() {
                result -= pixelOne // 53.667
            }
        }
        return result
    }
    
    /// 状态栏完整高度，隐藏时为0
    public static func statusBarFullHeight() -> CGFloat {
        if !UIApplication.shared.isStatusBarHidden {
            return statusBarFrame().height
        }
        if isIPad {
            return isNotchedScreen ? 24 : 20
        }
        if !isNotchedScreen {
            return 20
        }
        if isLandScape() {
            return 0
        }
        return statusBarHeightForPortrait()
    }
    
    /// 竖屏状态栏高度
    public static func statusBarHeightForPortrait() -> CGFloat {
        if isIPad {
            return isNotchedScreen ? 24 : 20
        }
        if !isNotchedScreen {
            return 20
        }
        if deviceModel == "iPhone12,1" { // iPhone 13 Mini
            return 48
        }
        if isDynamicIslandScreen() {
            return 54
        }
        if is61InchScreenAndiPhone12Later || is67InchScreen {
            return 47
        }
        // iPhone XR/11 在iOS14之后状态栏高度为48，之前为44
        if is61InchScreen {
            if #available(iOS 14.0, *) {
                return 48
            }else {
                return 44
            }
        }
        return (is54InchScreen && version >= 15.0) ? 50 : 44
    }
    
    public static func tabBarHeight() -> CGFloat {
        var tabBarHeight: CGFloat = 0
        if isIPad {
            if isNotchedScreen {
                tabBarHeight = 65
            }else {
                if version >= 12.0 {
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
            // iPhone 16 Pro
            "iPhone17,1": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 62, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 62, bottom: 21, right: 62)],
            // iPhone 16 Pro Max
            "iPhone17,2": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 62, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 62, bottom: 21, right: 62)],
            // iPhone 16
            "iPhone17,3": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 59, bottom: 21, right: 59)],
            // iPhone 16 Plus
            "iPhone17,4": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 59, bottom: 21, right: 59)],
            // iPhone 15
            "iPhone15,4": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 47, bottom: 21, right: 47)],
            "iPhone15,4-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 48, left: 0, bottom: 28, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 48, bottom: 21, right: 48)],
            // iPhone 15 Plus
            "iPhone15,5": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 47, bottom: 21, right: 47)],
            "iPhone15,5-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 41, left: 0, bottom: 30, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 41, bottom: 21, right: 41)],
            // iPhone 15 Pro
            "iPhone16,1": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 59, bottom: 21, right: 59)],
            "iPhone16,1-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 48, left: 0, bottom: 28, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 48, bottom: 21, right: 48)],
            // iPhone 15 Pro Max
            "iPhone16,2": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
                           UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 59, bottom: 21, right: 59)],
            "iPhone16,2-Zoom": [UIInterfaceOrientation.portrait: UIEdgeInsets(top: 51, left: 0, bottom: 31, right: 0),
                                UIInterfaceOrientation.landscapeLeft: UIEdgeInsets(top: 0, left: 51, bottom: 21, right: 51)],
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

extension UIDevice {
    public static let version: Double = {
       return Double(UIDevice.current.systemVersion) ?? 0
    }()
    
    public static let width: CGFloat = {
        min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    }()
    
    public static let height: CGFloat = {
        max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    }()
    
    // MARK - Screen
    /// iPhone 16 Pro Max
    public static let is69InchScreen: Bool = {
        return width == _69Inch.width && height == _69Inch.height
    }()
    
    /// iPhone 14 Pro Max
    public static let is67InchScreenAndiPhone14Later: Bool = {
        return width == _67InchAndiPhone14Later.width && height == _67InchAndiPhone14Later.height
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
    
    /// iPhone 16 Pro
    public static let is63InchScreen: Bool = {
        return width == _63Inch.width && height == _63Inch.height
    }()
    
    /// iPhone 14 Pro / 15 Pro
    public static let is61InchScreenAndiPhone14ProLater: Bool = {
        return width == _61InchAndiPhone14ProLater.width && height == _61InchAndiPhone14ProLater.height
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
    
    public static let _69Inch: CGSize = {
        return CGSize(width: 440, height: 956)
    }()
    
    public static let _67InchAndiPhone14Later: CGSize = {
       return CGSize(width: 430, height: 932)
    }()
    
    public static let _67Inch: CGSize = {
        return CGSize(width: 428, height: 926)
    }()
    
    public static let _65Inch: CGSize = {
        return CGSize(width: 414, height: 896)
    }()
    
    public static let _63Inch: CGSize = {
        return CGSize(width: 402, height: 874)
    }()
    
    public static let _61InchAndiPhone14ProLater: CGSize = {
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
