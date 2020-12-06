//
//  GKCommon.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/22.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import GKNavigationBarSwift

let isIPhoneX: Bool = GKConfigure.gk_isNotchedScreen()

let kScreenW = UIScreen.main.bounds.size.width
let kScreenH = UIScreen.main.bounds.size.height

let kStatusBar_Height: CGFloat = GKConfigure.gk_statusBarFrame().size.height
let kNavBar_Height: CGFloat = kStatusBar_Height + 44.0

let ADAPTATIONRATIO = kScreenW / 750.0

extension UIColor {
    public class func rgbaColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    public class func rgbColor(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor.rgbaColor(r: r, g: g, b: b, a: 1.0)
    }
    
    public class func grayColor(g: CGFloat) -> UIColor {
        return UIColor.rgbColor(r: g, g: g, b: g)
    }
}

public func changeColor(image: UIImage, color: UIColor) -> UIImage {
    UIGraphicsBeginImageContext(image.size)
    color.setFill()
    let bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    UIRectFill(bounds)
    image.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resultImage!
}
