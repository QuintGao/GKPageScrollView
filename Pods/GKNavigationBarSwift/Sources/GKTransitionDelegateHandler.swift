//
//  GKTransitionDelegateHandler.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

class GKNavigationControllerDelegateHandler: NSObject {
    var isGesturePush: Bool = false
    var pushTransition: UIPercentDrivenInteractiveTransition?
    var popTransition: UIPercentDrivenInteractiveTransition?
    var navigationController: UINavigationController!
    
    // MARK: - 滑动手势处理
    @objc public func panGestureAction(_ gesture: UIPanGestureRecognizer) {
        guard let visibleVC = self.navigationController.visibleViewController else { return }
        
        // 进度
        guard let width = gesture.view?.bounds.size.width else { return }
        
        if width == 0 {
            return
        }
        
        var progress = gesture.translation(in: gesture.view).x / width
        let velocity = gesture.velocity(in: gesture.view)
        
        // 在手势开始的时候判断是push操作还是pop操作
        if gesture.state == .began {
            self.isGesturePush = velocity.x < 0 ? true : false
        }
        
        // push时progress < 0 需要做处理
        if self.isGesturePush {
            progress = -progress
        }
        
        progress = min(1.0, max(0.0, progress))
        
        if gesture.state == .began {
            if self.isGesturePush { // push
                if self.navigationController.gk_openScrollLeftPush {
                    if visibleVC.gk_pushDelegate != nil {
                        self.pushTransition = UIPercentDrivenInteractiveTransition()
                        self.pushTransition?.completionCurve = .easeOut
                        self.pushTransition?.update(0)
                        
                        visibleVC.gk_pushDelegate?.pushToNextViewController()
                    }
                }
            }else { // pop
                if visibleVC.gk_popDelegate != nil {
                    visibleVC.gk_popDelegate?.viewControllerPopScrollBegan?()
                }else {
                    self.popTransition = UIPercentDrivenInteractiveTransition()
                    self.navigationController.popViewController(animated: true)
                }
            }
        }else if gesture.state == .changed {
            if self.isGesturePush {
                if self.pushTransition != nil {
                    self.pushTransition?.update(progress)
                }
            }else {
                if visibleVC.gk_popDelegate != nil {
                    visibleVC.gk_popDelegate?.viewControllerPopScrollUpdate?(progress: progress)
                }else {
                    self.popTransition?.update(progress)
                }
            }
        }else if gesture.state == .ended || gesture.state == .cancelled {
            if self.isGesturePush {
                if self.pushTransition != nil {
                    if progress > GKConfigure.gk_pushTransitionCriticalValue {
                        self.pushTransition?.finish()
                    }else {
                        self.pushTransition?.cancel()
                    }
                }
            }else {
                if visibleVC.gk_popDelegate != nil {
                    visibleVC.gk_popDelegate?.viewControllerPopScrollEnded?()
                }else {
                    if progress > GKConfigure.gk_popTransitionCriticalValue {
                        self.popTransition?.finish()
                    }else {
                        self.popTransition?.cancel()
                    }
                }
            }
            self.pushTransition = nil
            self.popTransition = nil
            self.isGesturePush = false
        }
    }
}

extension GKNavigationControllerDelegateHandler: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if self.navigationController.gk_transitionScale || (self.navigationController.gk_openScrollLeftPush && self.pushTransition != nil) {
            if operation == .push {
                return GKPushAnimatedTransition(scale: self.navigationController.gk_transitionScale)
            }else if operation == .pop {
                return GKPopAnimatedTransition(scale: self.navigationController.gk_transitionScale)
            }
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.navigationController.gk_transitionScale || (self.navigationController.gk_openScrollLeftPush && self.pushTransition != nil) {
            if animationController.isKind(of: GKPushAnimatedTransition.classForCoder()) {
                return self.pushTransition
            }else if animationController.isKind(of: GKPopAnimatedTransition.classForCoder()) {
                return self.popTransition
            }
        }
        return nil
    }
}

class GKGestureRecognizerDelegateHandler: NSObject {
    var navigationController: UINavigationController!
    var systemTarget: Any?
    var customTarget: GKNavigationControllerDelegateHandler?
}

extension GKGestureRecognizerDelegateHandler: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 不是UIPanGestureRecognizer，不作处理
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) == false {
            return true
        }
        
        // 转为UIPanGestureRecognizer
        let panGesture = gestureRecognizer as! UIPanGestureRecognizer
        
        // 如果没有visibleViewController，不作处理
        guard let visibleVC = self.navigationController.visibleViewController else {
            return true
        }
        
        if self.navigationController.gk_openScrollLeftPush {
            // 开启了左滑push功能
        }else if (visibleVC.gk_popDelegate != nil) {
            // 设置了gk_popDelegate
        }else {
            // 忽略根控制器
            if self.navigationController.viewControllers.count <= 1 {
                return false
            }
        }
        
        // 忽略禁用手势
        if visibleVC.gk_interactivePopDisabled {
            return false
        }
        
        let transition = panGesture.translation(in: gestureRecognizer.view)
        let action = NSSelectorFromString("handleNavigationTransition:")
        
        if transition.x < 0 { // 左滑处理
            // 开启了左滑push并设置了代理
            if self.navigationController.gk_openScrollLeftPush && visibleVC.gk_pushDelegate != nil {
                gestureRecognizer.removeTarget(self.systemTarget, action: action)
                gestureRecognizer.addTarget(self.customTarget!, action: #selector(self.customTarget?.panGestureAction(_:)))
            }else {
                return false
            }
        }else { // 右滑处理
            // 解决跟控制器右滑时出现的卡死情况
            if visibleVC.gk_popDelegate != nil {
                // 实现了gk_popDelegate，不作处理
            }else {
                if self.navigationController.viewControllers.count <= 1 {
                    return false
                }
            }
            
            // 全屏滑动时起作用
            if !visibleVC.gk_fullScreenPopDisabled {
                // 上下滑动
                if transition.x == 0 {
                    return false
                }
            }
            
            // 忽略超出手势区域
            let beginningLocation = gestureRecognizer.location(in: gestureRecognizer.view)
            let maxAllowDistance = visibleVC.gk_maxPopDistance
            
            if maxAllowDistance > 0 && beginningLocation.x > maxAllowDistance {
                return false
            }else if visibleVC.gk_popDelegate != nil {
                gestureRecognizer.removeTarget(self.systemTarget, action: action)
                gestureRecognizer.addTarget(self.customTarget!, action: #selector(self.customTarget?.panGestureAction(_:)))
            }else if !self.navigationController.gk_transitionScale { // 非缩放，系统处理
                gestureRecognizer.removeTarget(self.customTarget, action: #selector(self.customTarget?.panGestureAction(_:)))
                gestureRecognizer.addTarget(self.systemTarget!, action: action)
            }else {
                gestureRecognizer.removeTarget(self.systemTarget, action: action)
                gestureRecognizer.addTarget(self.customTarget!, action: #selector(self.customTarget?.panGestureAction(_:)))
            }
        }
        
        // 忽略导航控制器正在做转场动画
        if self.navigationController.value(forKey: "_isTransitioning") as? Bool == true {
            return false
        }
        
        return true
    }
}
