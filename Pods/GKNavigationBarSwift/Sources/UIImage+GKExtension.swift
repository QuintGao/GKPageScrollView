//
//  UIImage+GKExtension.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

extension UIImage {
    
    public class func gk_image(with name: String) -> UIImage {
        let bundleName = NSString("GKNavigationBarSwift.bundle").appendingPathComponent(name)
        let frameworkName = NSString("Frameworks/GKNavigationBarSwift.framework/GKNavigationBarSwift.bundle").appendingPathComponent(name)
        
        var image = UIImage(named: bundleName)
        if image == nil {
            image = UIImage(named: frameworkName)
        }
        return image!
    }
    
    public class func gk_image(with color: UIColor) -> UIImage{
        return self.gk_image(with: color, size: CGSize(width: 1, height: 1))
    }
    
    public class func gk_image(with color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    public class func gk_change(with image: UIImage, color: UIColor) -> UIImage {
        let drawRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setBlendMode(.normal)
        context?.clip(to: drawRect, mask: image.cgImage!)
        color.setFill()
        context?.fill(drawRect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage ?? UIImage()
    }
}
