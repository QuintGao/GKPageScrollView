//
//  GKPushAnimatedTransition.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/24.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

class GKPushAnimatedTransition: GKBaseAnimatedTransition {
    public override func animateTransition() {
        // 解决UITabBarController左滑push时的显示问题
        let isHideTabBar = (self.fromViewController.tabBarController != nil) && (self.toViewController.hidesBottomBarWhenPushed == true)
        
        var fromView = self.fromViewController.view
        if isHideTabBar {
            // 获取fromViewController的截图
            let view: UIView?
            if self.fromViewController.view.window != nil {
                view = self.fromViewController.view.window
            }else {
                view = self.fromViewController.view
            }
            
            if view != nil {
                let captureImage = getCapture(with: view!)
                let captureView = UIImageView(image: captureImage)
                captureView.frame = CGRect(x: 0, y: 0, width: GK_SCREEN_WIDTH, height: GK_SCREEN_HEIGHT)
                containerView.addSubview(captureView)
                fromView = captureView
                self.fromViewController.gk_captureImage = captureImage
                self.fromViewController.view.isHidden = true
                self.fromViewController.tabBarController?.tabBar.isHidden = true
            }
        }
        
        self.containerView.addSubview(self.toViewController.view)
        
        if self.isScale {
            self.shadowView = UIView(frame: CGRect(x: 0, y: 0, width: GK_SCREEN_WIDTH, height: GK_SCREEN_HEIGHT))
            self.shadowView.backgroundColor = UIColor.black.withAlphaComponent(0)
            fromView?.addSubview(self.shadowView)
        }
        
        // 设置toViewController
        self.toViewController.view.frame = CGRect(x: GK_SCREEN_WIDTH, y: 0, width: GK_SCREEN_WIDTH, height: GK_SCREEN_HEIGHT)
        self.toViewController.view.layer.shadowColor = UIColor.black.cgColor
        self.toViewController.view.layer.shadowOpacity = 0.2
        self.toViewController.view.layer.shadowRadius = 4.0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            let fromRect = CGRect(x: -(0.3 * GK_SCREEN_WIDTH), y: 0, width: GK_SCREEN_WIDTH, height: GK_SCREEN_HEIGHT)
            if self.isScale {
                self.shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                if #available(iOS 11.0, *) {
                    var frame = fromView?.frame
                    frame?.origin.x = GKConfigure.gk_translationX
                    frame?.origin.y = GKConfigure.gk_translationY
                    frame?.size.height -= 2 * GKConfigure.gk_translationY
                    fromView?.frame = frame ?? fromRect
                } else {
                    fromView?.transform = CGAffineTransform(scaleX: GKConfigure.gk_scaleX, y: GKConfigure.gk_scaleY)
                }
            }else {
                fromView?.frame = fromRect
            }
            
            self.toViewController.view.frame = CGRect(x: 0, y: 0, width: GK_SCREEN_WIDTH, height: GK_SCREEN_HEIGHT)
        }) { (finished) in
            self.completeTransition()
            if isHideTabBar {
                fromView?.removeFromSuperview()
                fromView = nil
                self.fromViewController.view.isHidden = false
                
                if self.fromViewController.navigationController?.children.count == 1 {
                    self.fromViewController.tabBarController?.tabBar.isHidden = false
                }
            }
            if self.isScale {
                self.shadowView.removeFromSuperview()
            }
        }
    }
}
