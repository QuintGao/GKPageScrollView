//
//  GKWYHeaderView.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/22.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import GKPageScrollView

public let kWYHeaderHeight = (kScreenW * 500.0 / 750.0 - kNavBar_Height)

class GKWYHeaderView: UIView {
    lazy var nameLabel: UILabel! = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        nameLabel.textColor = UIColor.white
        nameLabel.text = "展展与罗罗"
        return nameLabel
    }()
    
    lazy var countLabel: UILabel! = {
        let countLabel = UILabel()
        countLabel.font = UIFont.systemFont(ofSize: 13.0)
        countLabel.textColor = UIColor.white
        countLabel.text = "被收藏了60182次"
        return countLabel
    }()
    
    lazy var tagLabel: UILabel! = {
        let tagLabel = UILabel()
        tagLabel.font = UIFont.systemFont(ofSize: 13.0)
        tagLabel.textColor = UIColor.white
        tagLabel.text = "网易音乐人"
        return tagLabel
    }()
    
    lazy var personalBtn: UIButton! = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        btn.setTitle("个人主页", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.layer.cornerRadius = ADAPTATIONRATIO * 25.0
        btn.layer.masksToBounds = true
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 0.5
        return btn
    }()
    
    lazy var collectBtn: UIButton! = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.red
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        btn.setTitle("收藏", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.layer.cornerRadius = ADAPTATIONRATIO * 22.0
        btn.layer.masksToBounds = true
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.addSubview(nameLabel)
        self.addSubview(countLabel)
        self.addSubview(tagLabel)
        self.addSubview(personalBtn)
        self.addSubview(collectBtn)
        
        tagLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-ADAPTATIONRATIO * 26.0)
            make.left.equalTo(self).offset(ADAPTATIONRATIO * 15.0)
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.tagLabel)
            make.bottom.equalTo(self.tagLabel.snp.top).offset(-ADAPTATIONRATIO * 12.0)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.tagLabel)
            make.bottom.equalTo(self.countLabel.snp.top).offset(-20)
        }
        
        collectBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.tagLabel.snp.bottom)
            make.right.equalTo(self).offset(-ADAPTATIONRATIO * 20.0)
            make.width.equalTo(ADAPTATIONRATIO * 150.0)
            make.height.equalTo(ADAPTATIONRATIO * 50.0)
        }
        
        personalBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.tagLabel.snp.bottom)
            make.right.equalTo(self.collectBtn.snp.left).offset(-ADAPTATIONRATIO * 20.0)
            make.width.equalTo(ADAPTATIONRATIO * 150.0)
            make.height.equalTo(ADAPTATIONRATIO * 50.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
