//
//  GKDYHeaderView.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/26.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit

let kDYHeaderHeight = (kScreenW * 375.0 / 345.0)
let kDYBgImgHeight  = (kScreenW * 110.0 / 345.0)

class GKDYHeaderView: UIView {

    var bgImgFrame: CGRect = .zero
    lazy var bgImgView: UIImageView = {
        let bgImgView = UIImageView()
        bgImgView.image = UIImage(named: "dy_bg")
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.clipsToBounds = true
        return bgImgView
    }()
    
    lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = UIColor.rgbColor(r: 34, g: 33, b: 37)
        return contentView
    }()
    
    lazy var iconImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "dy_icon")
        imgView.layer.cornerRadius = 48.0
        imgView.layer.masksToBounds = true
        imgView.layer.borderColor = UIColor.rgbColor(r: 34, g: 33, b: 37).cgColor
        imgView.layer.borderWidth = 3
        return imgView
    }()
    
    lazy var contentImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "dy_content")
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.bgImgView)
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.iconImgView)
        self.contentView.addSubview(self.contentImgView)
        
        self.bgImgFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: kDYBgImgHeight)
        self.bgImgView.frame = self.bgImgFrame
        
        self.contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: kDYBgImgHeight, left: 0, bottom: 0, right: 0))
        }
        
        self.iconImgView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(10.0)
            make.top.equalTo(self.contentView).offset(-15.0)
            make.width.height.equalTo(96.0)
        }
        
        self.contentImgView.snp.makeConstraints { (make) in
            make.top.equalTo(self.iconImgView.snp.bottom)
            make.left.right.bottom.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func scrollViewDidScroll(offsetY: CGFloat) {
        var frame = self.bgImgFrame

        // 上下放大
        frame.size.height -= offsetY
        frame.origin.y = offsetY

        // 左右放大
        if offsetY <= 0 {
            frame.size.width = frame.size.height * self.bgImgFrame.size.width / self.bgImgFrame.size.height
            frame.origin.x = (self.frame.size.width - frame.size.width) / 2
        }

        self.bgImgView.frame = frame
    }
}
