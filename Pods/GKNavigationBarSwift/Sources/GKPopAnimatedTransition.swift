//
//  GKPopAnimatedTransition.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/24.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

open class GKPopAnimatedTransition: GKBaseAnimatedTransition {
    public override func animateTransition() {
        self.containerView.insertSubview(self.toViewController.view, belowSubview: self.fromViewController.view)
        
        // 是否隐藏tabBar
        self.isHideTabBar = (self.toViewController.tabBarController != nil) && (self.fromViewController.hidesBottomBarWhenPushed == true) && (self.toViewController.gk_captureImage != nil)
        
        let screenW = self.containerView.bounds.size.width
        let screenH = self.containerView.bounds.size.height
        
        var toView = self.toViewController.view
        
        if self.isHideTabBar {
            let captureView = UIImageView(image: self.toViewController.gk_captureImage!)
            captureView.frame = CGRect(x: 0, y: 0, width: screenW, height: screenH)
            self.containerView.insertSubview(captureView, belowSubview: self.fromViewController.view)
            toView = captureView
            self.toViewController.view.isHidden = true
            self.toViewController.tabBarController?.tabBar.isHidden = true
        }
        self.contentView = toView
        
        let toRect = CGRect(x: -(0.3 * screenW), y: 0, width: screenW, height: screenH)
        if self.isScale {
            self.shadowView = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH))
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
            toView!.frame = toRect
        }
        
        self.fromViewController.view.layer.shadowColor = UIColor.black.cgColor
        self.fromViewController.view.layer.shadowOpacity = 0.15
        self.fromViewController.view.layer.shadowRadius = 3.0
        
        UIView.animate(withDuration: animationDuration(), animations: {
            self.fromViewController.view.frame = CGRect(x: screenW, y: 0, width: screenW, height: screenH)
            if self.isScale {
                self.shadowView.backgroundColor = UIColor.black.withAlphaComponent(0)
            }
            
            if #available(iOS 11.0, *) {
                toView?.frame = CGRect(x: 0, y: 0, width: screenW, height: screenH)
            }else {
                toView?.transform = .identity
            }
            
        }) { (finished) in
            self.completeTransition()
            if self.isHideTabBar {
                if self.contentView != nil {
                    self.contentView!.removeFromSuperview()
                    self.contentView = nil
                }
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
