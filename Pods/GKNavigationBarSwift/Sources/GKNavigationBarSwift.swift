//
//  GKNavigationBarSwift.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//  Custom navigation bar

import UIKit

open class GKNavigationBar: UINavigationBar {

    /// 当前所在的控制器是否隐藏状态栏
    public var gk_statusBarHidden: Bool = false
    
    /// 导航栏透明度
    public var gk_navBarBackgroundAlpha: CGFloat = 1 {
        willSet {
            for obj in self.subviews {
                if let cls = NSClassFromString("_UIBarBackground") {
                    if #available(iOS 10.0, *), obj.isKind(of: cls) {
                        DispatchQueue.main.async {
                            if obj.alpha != newValue {
                                obj.alpha = newValue
                            }
                        }
                    }else {
                        if let navBarBackgroundCls = NSClassFromString("_UINavigationBarBackground") {
                            if obj.isKind(of: navBarBackgroundCls) {
                                DispatchQueue.main.async {
                                    if obj.alpha != newValue {
                                        obj.alpha = newValue
                                    }
                                }
                            }
                        }
                    }
                }
            }
            let isClipsToBounds = (newValue == 0.0)
            if self.clipsToBounds != isClipsToBounds {
                self.clipsToBounds = isClipsToBounds
            }
        }
    }
    
    /// 导航栏分割线是否隐藏
    public var gk_navLineHidden: Bool = false

    public override init(frame: CGRect) {
        super.init(frame:frame)
        self.gk_navBarBackgroundAlpha = 1.0
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        /// 适配iOS11及以上，遍历所有子控件，向下移动状态栏高度
        if #available(iOS 11.0, *) {
            for obj in self.subviews {
                if let cls = NSClassFromString("_UIBarBackground") {
                    if obj.isKind(of: cls) {
                        var frame = obj.frame
                        frame.size.height = self.frame.size.height
                        obj.frame = frame
                    }else {
                        let screenW = UIScreen.main.bounds.size.width
                        let screenH = UIScreen.main.bounds.size.height
                        
                        var y: CGFloat = 0
                        if screenW > screenH {
                            if GK_NOTCHED_SCREEN {
                                y = 0
                            }else {
                                y = self.gk_statusBarHidden ? 0 : GK_STATUSBAR_HEIGHT
                            }
                        }else {
                            y = self.gk_statusBarHidden ? GK_SAFEAREA_TOP : GK_STATUSBAR_HEIGHT
                        }

                        var frame = obj.frame
                        frame.origin.y = y
                        obj.frame = frame
                    }
                }
            }
        }
        
        // 重新设置透明度
        let alpha = self.gk_navBarBackgroundAlpha
        self.gk_navBarBackgroundAlpha = alpha
        
        // 分割线处理
        self.gk_navLineHideOrShow()
    }
    
    fileprivate func gk_navLineHideOrShow() {
        guard let backgroundView = self.subviews.first else { return }
        
        for view in backgroundView.subviews {
            if view.frame.size.height > 0 && view.frame.size.height <= 1.0 {
                view.isHidden = self.gk_navLineHidden
            }
        }
    }
}

