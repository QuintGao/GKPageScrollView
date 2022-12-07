//
//  GKAllRefreshViewController.swift
//  SwiftExample
//
//  Created by QuintGao on 2022/12/7.
//

import UIKit
import MJRefresh

class GKAllRefreshViewController: GKBasePageViewController {

    lazy var listRefreshBtn: UIButton = {
       let btn = UIButton()
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage(systemName: "arrow.clockwise.circle.fill"), for: .normal)
        }
        btn.addTarget(self, action: #selector(listRefreshClick), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navTitle = "AllRefresh";
        self.gk_navLineHidden = true;
        self.gk_navTitleColor = .white
        
        view.addSubview(listRefreshBtn)
        
        self.pageScrollView.mainTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + kRefreshDuration, execute: {
                self?.pageScrollView.mainTableView.mj_header?.endRefreshing()
                self?.pageScrollView.reloadData()
                
                self?.childVCs.forEach {
                    $0.addHeaderRefresh()
                }
                
                // 取出当前显示的listView
                let currentListVC = self?.childVCs[self?.segmentedView.selectedIndex ?? 0]
                
                // 模拟下拉刷新
                currentListVC?.count = 30;
                currentListVC?.reloadData()
            })
        })
        
        self.pageScrollView.mainTableView.mj_header?.beginRefreshing()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let screenWidth = UIScreen.main.bounds.size.width;
        let screenHeight = UIScreen.main.bounds.size.height;
        self.listRefreshBtn.frame = CGRectMake(screenWidth - 44 - 15, screenHeight - 44 - 15, 44, 44);
    }
    
    @objc func listRefreshClick() {
        self.pageScrollView.isAllowListRefresh = true;
        self.pageScrollView.isDisableMainScrollInCeil = true;
        
        let currentListVC = self.childVCs[self.segmentedView.selectedIndex]
        currentListVC.refresh { [weak self] in
            self?.pageScrollView.isAllowListRefresh = false
            self?.pageScrollView.isDisableMainScrollInCeil = false
        }
    }
    
    func mainTableViewDidScroll(_ scrollView: UIScrollView, isMainCanScroll: Bool) {
        self.listRefreshBtn.isHidden = isMainCanScroll
    }
}
