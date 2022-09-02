//
//  GKPageDefine.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2020/5/10.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

// 是否是iPhone X系列
public let GKPage_IS_iPhoneX: Bool = GKPageDefine.gk_isNotchedScreen()

// 状态栏高度
public let GKPage_StatusBar_Height: CGFloat = GKPageDefine.gk_statusBarFrame().size.height

// 导航栏+状态栏高度
public let GKPage_NavBar_Height: CGFloat = (GKPage_StatusBar_Height + 44.0)

// 屏幕宽高
public let GKPage_Screen_Width = UIScreen.main.bounds.size.width
public let GKPage_Screen_Height = UIScreen.main.bounds.size.height

open class GKPageDefine {
    
    
//    public static let isNotchedScreen: Bool = {
//        if #available(iOS 11.0, *) {
//            var window = keyWindow()
//            if window == nil {
//                // keyWindow还没有创建时，通过创建临时window获取安全区域
//                window = UIWindow(frame: UIScreen.main.bounds)
//                if window!.safeAreaInsets.bottom <= 0 {
//                    let viewController = UIViewController()
//                    window?.rootViewController = viewController
//                }
//            }
//
//            if window!.safeAreaInsets.bottom > 0 {
//                return true
//            }
//        } else {
//            return false
//        }
//        return false
//    }()
    
    open class func gk_isNotchedScreen() -> Bool {
        if #available(iOS 11.0, *) {
            var window = getKeyWindow()
            if window == nil {
                // keyWindow还没有创建，通过创建临时window获取安全区域
                window = UIWindow(frame: UIScreen.main.bounds)
                if window!.safeAreaInsets.bottom <= 0 {
                    let viewController = UIViewController()
                    window?.rootViewController = viewController
                }
            }
            
            if window!.safeAreaInsets.bottom > 0 {
                return true
            }
        }
        return false
    }
    
    open class func gk_statusBarFrame() -> CGRect {
        var statusBarFrame = CGRect.zero
        if #available(iOS 13.0, *) {
            statusBarFrame = GKPageDefine.getKeyWindow()?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
        }
        
        if statusBarFrame == .zero {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        
        if statusBarFrame == .zero {
            let statusBarH: CGFloat = GKPageDefine.gk_isNotchedScreen() ? 44.0 : 20.0
            statusBarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: statusBarH)
        }
        return statusBarFrame
    }
    
    fileprivate class func getKeyWindow() -> UIWindow? {
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
