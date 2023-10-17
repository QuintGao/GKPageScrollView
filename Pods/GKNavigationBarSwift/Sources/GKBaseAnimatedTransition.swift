//
//  GKBaseAnimatedTransition.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/24.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

open class GKBaseAnimatedTransition: NSObject {
    open var isScale = false
    open var shadowView: UIView!
    open var transitionContext: UIViewControllerContextTransitioning!
    open var containerView: UIView!
    open var fromViewController: UIViewController!
    open var toViewController: UIViewController!
    open var isHideTabBar = false
    
    open class func transition(with scale: Bool) -> GKBaseAnimatedTransition {
        return self.init(scale: scale)
    }
    
    required public init(scale: Bool) {
        self.isScale = scale
    }
}

extension GKBaseAnimatedTransition: UIViewControllerAnimatedTransitioning {
    // MARK - UIViewControllerAnimatedTransitioning
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(UINavigationController.hideShowBarDuration)
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        
        self.containerView = containerView
        self.fromViewController = fromVC
        self.toViewController = toVC
        self.transitionContext = transitionContext
        
        animateTransition()
    }
    
    public func animationDuration() -> TimeInterval {
        return self.transitionDuration(using: self.transitionContext)
    }
    
    @objc open func animateTransition() {
        // SubClass Implementation
    }
    
    public func completeTransition() {
        guard let transitionContext = self.transitionContext else { return }
        transitionContext .completeTransition(!transitionContext.transitionWasCancelled)
    }
}

extension UIViewController {
    fileprivate struct AssociatedKeys {
        static var defCaptureImage: Void?
    }
    
    public var gk_captureImage: UIImage? {
        get {
            guard let obj = gk_getAssociatedObject(self, &AssociatedKeys.defCaptureImage) else { return nil }
            return obj as? UIImage
        }
        set {
            gk_setAssociatedObject(self, &AssociatedKeys.defCaptureImage, newValue)
        }
    }
}
