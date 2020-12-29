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
        
        GKConfigure.setupCustom { (configure) in
            configure.titleColor = .black
            configure.titleFont = UIFont.systemFont(ofSize: 18.0)
            configure.gk_navItemLeftSpace = 4.0
            configure.gk_navItemRightSpace = 4.0
            configure.backStyle = .white
        }
        GKConfigure.awake()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = UINavigationController(rootVC: ViewController())
        window?.makeKeyAndVisible()
        
        return true
    }
}

