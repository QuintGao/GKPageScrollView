//
//  GKWBHeaderView.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit

let kWBHeaderHeight = kScreenW * 385.0 / 704.0

class GKWBHeaderView: UIView {

    lazy var bgImgView: UIImageView! = {
        let bgImgView = UIImageView()
        bgImgView.image = UIImage(named: "wb_bg")
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.clipsToBounds = true
        return bgImgView
    }()

    lazy var coverView: UIView! = {
        let coverView = UIView()
        coverView.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        coverView.contentMode = .scaleAspectFill
        return coverView
    }()
    
    lazy var iconImgView: UIImageView! = {
        let iconImgView = UIImageView()
        iconImgView.image = UIImage(named: "wb_icon")
        iconImgView.layer.cornerRadius = 40.0
        iconImgView.layer.masksToBounds = true
        return iconImgView
    }()
    
    lazy var nameLabel: UILabel! = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        nameLabel.text = "广文博见V"
        nameLabel.textColor = UIColor.white
        return nameLabel
    }()
    
    var bgImgFrame: CGRect = .zero
    var bgImgH: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.bgImgView)
        self.bgImgView.addSubview(self.coverView)
        self.addSubview(self.iconImgView)
        self.addSubview(self.nameLabel)
        
        self.bgImgFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        self.bgImgView.frame = self.bgImgFrame
        
        let bgImg = self.bgImgView.image
        self.bgImgH = kScreenW * (bgImg?.size.height)! / (bgImg?.size.width)!
        
        self.coverView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.bgImgView)
        }
        
        self.nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-20.0)
        }
        
        self.iconImgView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo((self.nameLabel.snp.top)).offset(-10.0)
            make.width.height.equalTo(80.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func scrollViewDidScroll(offsetY: CGFloat) {
        // headerView下拉放大
        var frame = self.bgImgFrame
        frame.size.height -= offsetY
        
        if frame.size.height >= self.bgImgH {
            frame.size.height = self.bgImgH
            frame.origin.y = -(self.bgImgH - kWBHeaderHeight)
        }else {
            frame.origin.y = offsetY
        }
        self.bgImgView.frame = frame
    }
}
