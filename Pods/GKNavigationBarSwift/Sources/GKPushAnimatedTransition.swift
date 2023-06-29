//
//  GKPushAnimatedTransition.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/24.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

open class GKPushAnimatedTransition: GKBaseAnimatedTransition {
    public override func animateTransition() {
        // 解决UITabBarController左滑push时的显示问题
        self.isHideTabBar = (self.fromViewController.tabBarController != nil) && (self.toViewController.hidesBottomBarWhenPushed == true)
        
        let tabBar = self.fromViewController.tabBarController?.tabBar
        if (tabBar == nil) {
            self.isHideTabBar = false
        }
        
        // tabBar位置不对或隐藏
        if (tabBar?.frame.origin.x != 0 || tabBar?.isHidden == true) {
            self.isHideTabBar = false
        }
        // 非根控制器
        if (self.fromViewController.navigationController?.children.first != self.fromViewController) {
            self.isHideTabBar = false
        }
        
        let screenW = self.containerView.bounds.size.width
        let screenH = self.containerView.bounds.size.height
        
        let fromView = UIView(frame: self.containerView.bounds)
        fromView.addSubview(fromViewController.view)
        
        var captureView: UIView? = nil
        
        if self.isHideTabBar {
            // 截取tabBar
            let captureImage = GKConfigure.getCapture(with: tabBar!)
            self.fromViewController.gk_captureImage = captureImage
            captureView = UIImageView(image: captureImage)
            var frame = tabBar!.frame;
            frame.origin.x = 0
            captureView?.frame = frame
            fromView.addSubview(captureView!)
            tabBar?.isHidden = true
        }
        
        if self.isScale {
            self.shadowView = UIView(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH))
            self.shadowView.backgroundColor = UIColor.black.withAlphaComponent(0)
            fromView.addSubview(self.shadowView)
            fromView.transform = .identity
        }
        self.containerView.addSubview(fromView)
        
        // 设置toViewController
        self.toViewController.view.frame = CGRect(x: screenW, y: 0, width: screenW, height: screenH)
        self.toViewController.view.layer.shadowColor = UIColor.black.cgColor
        self.toViewController.view.layer.shadowOpacity = 0.15
        self.toViewController.view.layer.shadowRadius = 3.0
        self.containerView.addSubview(self.toViewController.view)
        
        UIView.animate(withDuration: animationDuration(), animations: {
            if self.isScale {
                self.shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                fromView.transform = CGAffineTransform(scaleX: GKConfigure.gk_scaleX, y: GKConfigure.gk_scaleY)
            }else {
                var frame = fromView.frame
                frame.origin.x = -0.3 * frame.size.width
                fromView.frame = frame
            }
            
            self.toViewController.view.frame = CGRect(x: 0, y: 0, width: screenW, height: screenH)
        }) { (finished) in
            if self.isHideTabBar {
                if (self.transitionContext.transitionWasCancelled) {
                    self.containerView.addSubview(self.fromViewController.view)
                }else {
                    self.fromViewController.view.removeFromSuperview()
                }
                fromView.transform = .identity
                fromView.removeFromSuperview()
                
                if (captureView != nil) {
                    captureView?.removeFromSuperview()
                    captureView = nil
                }
            }
            if self.isScale {
                self.shadowView.removeFromSuperview()
            }
            self.completeTransition()
        }
    }
}
