//
//  GKMainRefreshViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/27.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import MJRefresh

class GKMainRefreshViewController: GKBasePageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navTitle = "MainRefresh"
        self.gk_navTitleColor = .white
        self.gk_navLineHidden = true
        
        self.pageScrollView.mainTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + kRefreshDuration, execute: {
                self.pageScrollView.mainTableView.mj_header?.endRefreshing()
                
                // 取出当前显示的listView
                let currentListVC = self.childVCs[self.segmentedView.selectedIndex]
                
                // 模拟下拉刷新
                currentListVC.count += 10
                currentListVC.tableView.reloadData()
            })
        })
        
        self.pageScrollView.reloadData()
    }
}
