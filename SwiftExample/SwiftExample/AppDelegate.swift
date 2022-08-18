//
//  AppDelegate.swift
//  SwiftExample
//
//  Created by gaokun on 2020/12/29.
//

import UIKit
import GKNavigationBarSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GKConfigure.setupCustom {
            $0.titleColor = .black
            $0.titleFont = UIFont.systemFont(ofSize: 18.0)
            $0.gk_navItemLeftSpace = 4.0
            $0.gk_navItemRightSpace = 4.0
            $0.backStyle = .white
            if #available(iOS 13.0, *) {
                $0.statusBarStyle = .darkContent
            }else {
                $0.statusBarStyle = .default
            }
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = UINavigationController(rootVC: ViewController())
        window?.makeKeyAndVisible()
        
        return true
    }
}

