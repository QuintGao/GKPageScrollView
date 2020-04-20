//
//  GKPopAnimatedTransition.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/24.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

class GKPopAnimatedTransition: GKBaseAnimatedTransition {
    public override func animateTransition() {
        self.containerView.insertSubview(self.toViewController.view, belowSubview: self.fromViewController.view)
        
        // 是否隐藏tabBar
        let isHideTabBar = (self.toViewController.tabBarController != nil) && (self.fromViewController.hidesBottomBarWhenPushed == true) && (self.toViewController.gk_captureImage != nil)
        
        var toView = self.toViewController.view
        
        if isHideTabBar {
            let captureView = UIImageView(image: self.toViewController.gk_captureImage!)
            captureView.frame = CGRect(x: 0, y: 0, width: GK_SCREEN_WIDTH, height: GK_SCREEN_HEIGHT)
            self.containerView.insertSubview(captureView, belowSubview: self.fromViewController.view)
            toView = captureView
            self.toViewController.view.isHidden = true
            self.toViewController.tabBarController?.tabBar.isHidden = true
        }
        
        let toRect = CGRect(x: -(0.3 * GK_SCREEN_WIDTH), y: 0, width: GK_SCREEN_WIDTH, height: GK_SCREEN_HEIGHT)
        
        if self.isScale {
            self.shadowView = UIView(frame: CGRect(x: 0, y: 0, width: GK_SCREEN_WIDTH, height: GK_SCREEN_HEIGHT))
            self.shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toView?.addSubview(self.shadowView)
            
            if #available(iOS 11.0, *) {
                var frame = toView?.frame
                frame?.origin.x = GKConfigure.gk_translationX
                frame?.origin.y = GKConfigure.gk_translationY
                frame?.size.height -= 2 * GKConfigure.gk_translationY
                toView?.frame = frame ?? toRect
            }else {
                toView?.transform = CGAffineTransform(scaleX: GKConfigure.gk_scaleX, y: GKConfigure.gk_scaleY)
            }
        }else {
            self.fromViewController.view.frame = toRect
        }
        
        self.fromViewController.view.layer.shadowColor = UIColor.black.cgColor
        self.fromViewController.view.layer.shadowOpacity = 0.2
        self.fromViewController.view.layer.shadowRadius = 4.0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            self.fromViewController.view.frame = CGRect(x: GK_SCREEN_WIDTH, y: 0, width: GK_SCREEN_WIDTH, height: GK_SCREEN_HEIGHT)
            if self.isScale {
                self.shadowView.backgroundColor = UIColor.black.withAlphaComponent(0)
            }
            
            if #available(iOS 11.0, *) {
                toView?.frame = CGRect(x: 0, y: 0, width: GK_SCREEN_WIDTH, height: GK_SCREEN_HEIGHT)
            }else {
                toView?.transform = .identity
            }
            
        }) { (finished) in
            self.completeTransition()
            
            if isHideTabBar {
                toView?.removeFromSuperview()
                toView = nil
                self.toViewController.view.isHidden = false
                if self.toViewController.navigationController?.children.count == 1 {
                    self.toViewController.tabBarController?.tabBar.isHidden = false
                }
            }
            
            if self.isScale {
                self.shadowView.removeFromSuperview()
            }
        }
    }
}
