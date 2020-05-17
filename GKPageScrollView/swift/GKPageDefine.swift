//
//  GKPageDefine.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2020/5/10.
//  Copyright © 2020 gaokun. All rights reserved.
//

import UIKit

// 是否是iPhone X系列
let GKPage_IS_iPhoneX: Bool = (
    (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 375, height:812), UIScreen.main.bounds.size) : false) ||
    (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 812, height:375), UIScreen.main.bounds.size) : false) ||
    (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 414, height:896), UIScreen.main.bounds.size) : false) ||
    (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 896, height:414), UIScreen.main.bounds.size) : false))

// 导航栏+状态栏高度
let GKPage_NavBar_Height: CGFloat = GKPage_IS_iPhoneX ? 88.0 : 64.0

// 屏幕宽高
let GKPage_Screen_Width = UIScreen.main.bounds.size.width
let GKPage_Screen_Height = UIScreen.main.bounds.size.height
