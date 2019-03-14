//
//  GKCommon.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/22.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit

let isIPhoneX: Bool = (
        (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 375, height:812), UIScreen.main.bounds.size) : false) ||
        (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 812, height:375), UIScreen.main.bounds.size) : false) ||
        (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 414, height:896), UIScreen.main.bounds.size) : false) ||
        (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 896, height:414), UIScreen.main.bounds.size) : false))

let kScreenW = UIScreen.main.bounds.size.width
let kScreenH = UIScreen.main.bounds.size.height

let kNavBar_Height: CGFloat = isIPhoneX ? 88.0 : 64.0
let kStatusBar_Height: CGFloat = isIPhoneX ? 44.0 : 20.0

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
