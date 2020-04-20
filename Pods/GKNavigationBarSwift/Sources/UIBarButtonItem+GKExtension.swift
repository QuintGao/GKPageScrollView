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
        return self.gk_item(title: title, image: nil, target: target, action: action)
    }
    
    public class func gk_item(image: UIImage?, target: Any, action: Selector) -> UIBarButtonItem {
        return self.gk_item(title: nil, image: image, target: target, action: action)
    }
    
    public class func gk_item(title: String?, image: UIImage?, target: Any, action: Selector) -> UIBarButtonItem {
        return self.gk_item(title: title, image: image, highLightImage: nil, target: target, action: action)
    }
    
    public class func gk_item(image: UIImage?, highLightImage: UIImage, target: Any, action: Selector) -> UIBarButtonItem{
        return self.gk_item(title: nil, image: image, highLightImage: highLightImage, target: target, action: action)
    }
    
    public class func gk_item(title: String?, image: UIImage?, highLightImage: UIImage?, target: Any, action: Selector) -> UIBarButtonItem {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
        button.setImage(highLightImage, for: .highlighted)
        button.sizeToFit()
        button.addTarget(target, action: action, for: .touchUpInside)
        if button.bounds.size.width < 44.0 {
            button.bounds = CGRect(x: 0, y: 0, width: 44.0, height: 44.0)
        }
        return UIBarButtonItem(customView: button)
    }
}
