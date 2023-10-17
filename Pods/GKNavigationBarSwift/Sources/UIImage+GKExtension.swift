//
//  UIImage+GKExtension.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

extension UIImage {
    
    public class func gk_image(with name: String) -> UIImage? {
        var image: UIImage?
        if let bundle = Bundle.gk_bundle {
            image = UIImage(named: name, in: bundle, compatibleWith: nil)
        }
        if image == nil {
            image = UIImage(named: name)
        }
        return image
    }
    
    public class func gk_image(with color: UIColor) -> UIImage? {
        return self.gk_image(with: color, size: CGSize(width: 1, height: 1))
    }
    
    public class func gk_image(with color: UIColor, size: CGSize) -> UIImage? {
        if size.width <= 0 || size.height <= 0 { return nil }
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public class func gk_change(with image: UIImage?, color: UIColor) -> UIImage? {
        guard let image = image else { return nil }
        if image.size.width <= 0 || image.size.height <= 0 { return nil }
        let drawRect = CGRectMake(0, 0, image.size.width, image.size.height)
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setBlendMode(.normal)
        context.clip(to: drawRect, mask: image.cgImage!)
        color.setFill()
        context.fill(drawRect)
        guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return resultImage
    }
}
