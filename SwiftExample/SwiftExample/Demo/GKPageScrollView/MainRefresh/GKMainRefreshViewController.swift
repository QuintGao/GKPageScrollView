//
//  GKMainRefreshViewController.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2019/2/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

import UIKit
import MJRefresh

class GKMainRefreshViewController: GKBasePageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navTitle = "MainRefresh"
        self.gk_navTitleColor = .white
        self.gk_navLineHidden = true
        
        self.pageScrollView.mainTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + kRefreshDuration, execute: {
                self?.pageScrollView.mainTableView.mj_header?.endRefreshing()
                
                // 取出当前显示的listView
                let currentListVC = self?.childVCs[self?.segmentedView.selectedIndex ?? 0]
                
                // 模拟下拉刷新
                currentListVC?.count += 10
                currentListVC?.tableView.reloadData()
            })
        })
        
        self.pageScrollView.reloadData()
    }
}
