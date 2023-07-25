//
//  GKListRefreshViewController.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2019/2/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

import UIKit

class GKListRefreshViewController: GKBasePageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navTitle = "listRefresh"
        self.gk_navTitleColor = .white
        self.gk_navLineHidden = true
        
        self.pageScrollView.isAllowListRefresh = true
        self.pageScrollView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 列表添加下拉刷新
        for vc in self.childVCs {
            vc.addHeaderRefresh()
        }
    }
}
