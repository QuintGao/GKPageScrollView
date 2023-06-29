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
        // 是否隐藏tabBar
        self.isHideTabBar = (self.toViewController.tabBarController != nil) && (self.fromViewController.hidesBottomBarWhenPushed == true) && (self.toViewController.gk_captureImage != nil)
        if (self.toViewController.navigationController?.children.first != self.toViewController) {
            self.isHideTabBar = false
        }
        let tabBar = self.toViewController.tabBarController?.tabBar
        if (tabBar == nil) {
            self.isHideTabBar = false
        }
        
        let screenW = self.containerView.bounds.size.width
        let screenH = self.containerView.bounds.size.height
        
        let toView = UIView(frame: self.containerView.bounds)
        var captureView: UIView? = nil
        
        toView.addSubview(self.toViewController.view)
        
        if self.isHideTabBar {
            captureView = UIImageView(image: self.toViewController.gk_captureImage!)
            var frame = tabBar!.frame
            frame.origin.x = 0
            captureView?.frame = frame
            toView.addSubview(captureView!)
            tabBar?.isHidden = true
        }
        
        if self.isScale {
            self.shadowView = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH))
            self.shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toView.addSubview(self.shadowView)
            toView.transform = CGAffineTransform(scaleX: GKConfigure.gk_scaleX, y: GKConfigure.gk_scaleY)
        }else {
            var frame = toView.frame
            frame.origin.x = -0.3 * frame.size.width
            toView.frame = frame
        }
        self.containerView.insertSubview(toView, belowSubview: self.fromViewController.view)
        
        self.fromViewController.view.layer.shadowColor = UIColor.black.cgColor
        self.fromViewController.view.layer.shadowOpacity = 0.15
        self.fromViewController.view.layer.shadowRadius = 3.0
        
        UIView.animate(withDuration: animationDuration(), animations: {
            self.fromViewController.view.frame = CGRect(x: screenW, y: 0, width: screenW, height: screenH)
            if self.isScale {
                self.shadowView.backgroundColor = UIColor.black.withAlphaComponent(0)
                toView.transform = .identity
            }else {
                var frame = toView.frame
                frame.origin.x = 0
                toView.frame = frame
            }
        }) { (finished) in
            if self.isHideTabBar {
                self.toViewController.gk_captureImage = nil
                if (self.transitionContext.transitionWasCancelled) {
                    self.toViewController.view.removeFromSuperview()
                }else {
                    self.containerView.addSubview(self.toViewController.view)
                }
                toView.transform = .identity
                toView.removeFromSuperview()
                
                if (captureView != nil) {
                    captureView?.removeFromSuperview()
                    captureView = nil
                }
                if (self.toViewController.navigationController?.children.count == 1) {
                    tabBar?.isHidden = false
                }
            }
            
            if self.isScale {
                self.shadowView.removeFromSuperview()
            }
            self.completeTransition()
        }
    }
}
