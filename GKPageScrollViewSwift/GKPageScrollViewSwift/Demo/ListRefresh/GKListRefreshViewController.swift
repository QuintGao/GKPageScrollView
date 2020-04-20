//
//  GKListRefreshViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/27.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit

class GKListRefreshViewController: GKBasePageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navTitle = "listRefresh"
        self.gk_navTitleColor = .white
        self.gk_navLineHidden = true
        
        self.pageScrollView.isAllowListRefresh = true
        
        // 列表添加下拉刷新
        for (_, vc) in self.childVCs.enumerated() {
            vc.addHeaderRefresh()
        }
        
        self.pageScrollView.reloadData()
    }
}
