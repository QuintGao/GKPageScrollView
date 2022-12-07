//
//  UIBarButtonItem+GKExtension.swift
//  GKNavigationBarSwift
//
//  Created by QuintGao on 2020/3/25.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    public class func gk_item(title: String?, target: Any, action: Selector) -> UIBarButtonItem {
        gk_item(title: title, image: nil, target: target, action: action)
    }
    
    public class func gk_item(title: String?, font: UIFont?, target: Any, action: Selector) -> UIBarButtonItem {
        gk_item(title: title, color: nil, font: font, target: target, action: action)
    }
    
    public class func gk_item(title: String?, color: UIColor?, target: Any, action: Selector) -> UIBarButtonItem {
        gk_item(title: title, color: color, font: nil, target: target, action: action)
    }
    
    public class func gk_item(title: String?, color: UIColor?, font: UIFont?, target: Any, action: Selector) -> UIBarButtonItem {
        gk_item(title: title, titleColor: color, font: font, image: nil, imageColor: nil, highLightImage: nil, target: target, action: action)
    }
    
    public class func gk_item(image: UIImage?, target: Any, action: Selector) -> UIBarButtonItem {
        gk_item(title: nil, image: image, target: target, action: action)
    }
    
    public class func gk_item(image: UIImage?, color: UIColor?, target: Any, action: Selector) -> UIBarButtonItem {
        gk_item(title: nil, titleColor: nil, font: nil, image: image, imageColor: color, highLightImage: nil, target: target, action: action)
    }
    
    public class func gk_item(image: UIImage?, highLightImage: UIImage?, target: Any, action: Selector) -> UIBarButtonItem {
        gk_item(title: nil, titleColor: nil, font: nil, image: image, imageColor: nil, highLightImage: highLightImage, target: target, action: action)
    }
    
    public class func gk_item(title: String?, image: UIImage?, target: Any, action: Selector) -> UIBarButtonItem {
        gk_item(title: title, titleColor: nil, font: nil, image: image, imageColor: nil, highLightImage: nil, target: target, action: action)
    }
    
    public class func gk_item(title: String?, titleColor: UIColor?, font: UIFont?, image: UIImage?, imageColor: UIColor?, highLightImage: UIImage?, target: Any, action: Selector) -> UIBarButtonItem {
        let button = UIButton()
        if let title = title {
            button.setTitle(title, for: .normal)
        }
        if let titleColor = titleColor {
            button.setTitleColor(titleColor, for: .normal)
        }
        if let font = font {
            button.titleLabel?.font = font
        }
        var buttonImage = image
        if let image = image, let imageColor = imageColor {
            buttonImage = UIImage.gk_change(with: image, color: imageColor)
        }
        if let buttonImage = buttonImage {
            button.setImage(buttonImage, for: .normal)
        }
        
        if let highLightImage = highLightImage {
            button.setImage(highLightImage, for: .highlighted)
        }
        button.sizeToFit()
        if button.bounds.size.width < 44.0 {
            button.bounds = CGRect(x: 0, y: 0, width: 44.0, height: 44.0)
        }
        button.addTarget(target, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
}
