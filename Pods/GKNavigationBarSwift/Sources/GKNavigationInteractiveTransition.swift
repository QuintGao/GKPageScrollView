//
//  GKNavigationInteractiveTransition.swift
//  GKNavigationBarSwift
//
//  Created by gaokun on 2020/11/27.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

class GKNavigationInteractiveTransition: NSObject {
    var isGesturePush: Bool = false
    var pushTransition: UIPercentDrivenInteractiveTransition?
    var popTransition: UIPercentDrivenInteractiveTransition?
    weak var navigationController: UINavigationController!
    weak var visibleVC: UIViewController?
    var systemTarget: Any?
    var systemAction: Selector?
    
    // MARK: - 滑动手势处理
    @objc public func panGestureAction(_ gesture: UIPanGestureRecognizer) {
        // 进度
        guard let width = gesture.view?.bounds.size.width else { return }
        if width == 0 { return }
        
        var progress = gesture.translation(in: gesture.view).x / width
        let velocity = gesture.velocity(in: gesture.view)
        
        // 在手势开始的时候判断是push操作还是pop操作
        if gesture.state == .began {
            self.isGesturePush = velocity.x < 0 ? true : false
            self.visibleVC = self.navigationController.visibleViewController
        }
        
        // push时progress < 0 需要做处理
        if self.isGesturePush {
            progress = -progress
        }
        
        progress = min(1.0, max(0.0, progress))
        
        if gesture.state == .began {
            if self.isGesturePush { // push
                if self.navigationController.gk_openScrollLeftPush {
                    if let visibleVC = self.visibleVC {
                        if visibleVC.gk_pushDelegate != nil {
                            self.pushTransition = UIPercentDrivenInteractiveTransition()
                            visibleVC.gk_pushDelegate?.pushToNextViewController?()
                        }
                        if visibleVC.gk_pushDelegate != nil {
                            visibleVC.gk_pushDelegate?.viewControllerPushScrollBegan?()
                        }
                    }
                }
            }else { // pop
                if self.navigationController.gk_transitionScale {
                    self.popTransition = UIPercentDrivenInteractiveTransition()
                    self.navigationController.popViewController(animated: true)
                }
                if let visibleVC = self.visibleVC {
                    if visibleVC.gk_popDelegate != nil {
                        visibleVC.gk_popDelegate?.viewControllerPopScrollBegan?()
                    }
                }
            }
        }else if gesture.state == .changed {
            if self.isGesturePush {
                if self.pushTransition != nil {
                    self.pushTransition?.update(progress)
                }
                if let visibleVC = self.visibleVC {
                    if visibleVC.gk_pushDelegate != nil {
                        visibleVC.gk_pushDelegate?.viewControllerPushScrollUpdate?(progress: progress)
                    }
                }
            }else {
                if self.navigationController.gk_transitionScale {
                    self.popTransition?.update(progress)
                }
                if let visibleVC = self.visibleVC {
                    if visibleVC.gk_popDelegate != nil {
                        visibleVC.gk_popDelegate?.viewControllerPopScrollUpdate?(progress: progress)
                    }
                }
            }
        }else if gesture.state == .ended || gesture.state == .cancelled {
            if self.isGesturePush {
                var pushFinished: Bool = false
                if self.pushTransition != nil {
                    if progress > GKConfigure.gk_pushTransitionCriticalValue {
                        pushFinished = true
                        self.pushTransition?.finish()
                    }else {
                        pushFinished = false
                        self.pushTransition?.cancel()
                    }
                }
                if let visibleVC = self.visibleVC {
                    if visibleVC.gk_pushDelegate != nil {
                        visibleVC.gk_pushDelegate?.viewControllerPushScrollEnded?(finished: pushFinished)
                    }
                }
            }else {
                var popFinished: Bool = false
                if self.navigationController.gk_transitionScale {
                    if progress > GKConfigure.gk_popTransitionCriticalValue {
                        popFinished = true
                        self.popTransition?.finish()
                    }else {
                        popFinished = false
                        self.popTransition?.cancel()
                    }
                }else {
                    popFinished = progress > 0.5
                }
                if let visibleVC = self.visibleVC {
                    if visibleVC.gk_popDelegate != nil {
                        visibleVC.gk_popDelegate?.viewControllerPopScrollEnded?(finished: popFinished)
                    }
                }
            }
            self.pushTransition = nil
            self.popTransition  = nil
            self.visibleVC      = nil
            self.isGesturePush  = false
        }
    }
}

extension GKNavigationInteractiveTransition: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC.gk_pushTransition != nil && operation == .push {
            return fromVC.gk_pushTransition
        }
        if fromVC.gk_popTransition != nil && operation == .pop {
            return fromVC.gk_popTransition
        }
        let isScale = self.navigationController.gk_transitionScale
        if (isScale || self.pushTransition != nil) && operation == .push {
            return GKPushAnimatedTransition(scale: isScale)
        }
        if (isScale || self.popTransition != nil) && operation == .pop {
            return GKPopAnimatedTransition(scale: isScale)
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.pushTransition != nil && animationController.isKind(of: GKPushAnimatedTransition.classForCoder()) {
            return self.pushTransition
        }
        if self.popTransition != nil && animationController.isKind(of: GKPopAnimatedTransition.classForCoder()) {
            return self.popTransition
        }
        return nil
    }
}

extension GKNavigationInteractiveTransition: UIGestureRecognizerDelegate {
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
        
        // 当前VC禁止滑动返回
        if visibleVC.gk_interactivePopDisabled {
            return false
        }
        
        // 根据transition判断是左滑还是右滑
        let transition = panGesture.translation(in: gestureRecognizer.view)
        
        // 如果开启缩放，则移除系统处理
        if self.navigationController.gk_transitionScale {
            gestureRecognizer.removeTarget(self.systemTarget, action: self.systemAction)
        }
        
        if transition.x < 0 { // 左滑
            // 开启了左滑push并设置了代理
            if self.navigationController.gk_openScrollLeftPush && visibleVC.gk_pushDelegate != nil {
                gestureRecognizer.removeTarget(self.systemTarget, action: self.systemAction)
            }else {
                return false
            }
        }else { // 右滑
            // 解决跟控制器右滑时出现的卡死情况
            var shouldPop = true
            if visibleVC.responds(to: #selector(GKGesturePopHandlerProtocol.navigationShouldPopOnGesture)) {
                shouldPop = (visibleVC.perform(#selector(GKGesturePopHandlerProtocol.navigationShouldPopOnGesture)) != nil)
            }
            
            if shouldPop == false {
                return false
            }
            
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
            }
        }
        
        // 忽略导航控制器正在做转场动画
        if self.navigationController.value(forKey: "_isTransitioning") as? Bool == true {
            return false
        }
        
        return true
    }
}
