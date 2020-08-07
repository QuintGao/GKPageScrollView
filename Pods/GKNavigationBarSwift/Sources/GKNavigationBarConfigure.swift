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
    
    /// 左滑push过渡临界值，默认0.3，大于此值完成push操作
    open var gk_pushTransitionCriticalValue: CGFloat = 0.0
    
    /// 右滑pop过渡临界值，默认0.5，大于此值完成pop操作
    open var gk_popTransitionCriticalValue: CGFloat = 0.0
    
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
    
    /// 获取当前item修复间距
    open func gk_fixedSpace() -> CGFloat {
        let screenSize = UIScreen.main.bounds.size
        return min(screenSize.width, screenSize.height) > 375.0 ? 20.0 : 16.0
    }
}

