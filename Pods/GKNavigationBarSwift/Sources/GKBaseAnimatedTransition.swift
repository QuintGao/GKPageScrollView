//
//  GKBaseAnimatedTransition.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/24.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

class GKBaseAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    public var isScale = false
    public var shadowView: UIView!
    public var transitionContext: UIViewControllerContextTransitioning!
    public var containerView: UIView!
    public var fromViewController: UIViewController!
    public var toViewController: UIViewController!
    
    // MARK - UIViewControllerAnimatedTransitioning
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(UINavigationController.hideShowBarDuration)
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        
        self.containerView = containerView
        self.fromViewController = fromVC
        self.toViewController = toVC
        self.transitionContext = transitionContext
        
        animateTransition()
    }
    
    public class func transition(with scale: Bool) -> GKBaseAnimatedTransition {
        return self.init(scale: scale)
    }
    
    required public init(scale: Bool) {
        self.isScale = scale
    }
    
    public func animateTransition() {
        // SubClass Implementation
    }
    
    public func completeTransition() {
        guard let transitionContext = self.transitionContext else { return }
        
        transitionContext .completeTransition(!transitionContext.transitionWasCancelled)
    }
    
    public func getCapture(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIViewController {
    fileprivate struct AssociatedKeys {
        static var defCaptureImage: UIImage?
    }
    
    open var gk_captureImage: UIImage? {
        get {
            guard let obj = objc_getAssociatedObject(self, &AssociatedKeys.defCaptureImage) else { return nil }
            return obj as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.defCaptureImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
