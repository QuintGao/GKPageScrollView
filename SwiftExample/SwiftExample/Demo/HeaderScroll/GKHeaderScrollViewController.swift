//
//  GKHeaderScrollViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/6/3.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import JXSegmentedView
import MJRefresh
import GKPageScrollView

class GKHeaderScrollViewController: GKDemoBaseViewController {
    
    var titleDataSource = JXSegmentedTitleDataSource()
    
    lazy var pageScrollView: GKPageScrollView! = {
        let pageScrollView = GKPageScrollView(delegate: self)
        pageScrollView.ceilPointHeight = 0
        return pageScrollView
    }()
    
    lazy var headerView: GKHeaderScrollView = {
        var headerH = (kScreenW - 40)/4 + 20;
        
        let headerView = GKHeaderScrollView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: headerH))
        headerView.delegate = self
        
        return headerView
    }()
    
    let titles = ["动态", "文章", "更多"]
    
    lazy var pageView: UIView = {
        let pageView = UIView()
        pageView.addSubview(self.segmentedView);
        pageView.addSubview(self.scrollView)
        
        return pageView
    }()
    
    lazy var segmentedView: JXSegmentedView = {
        titleDataSource.titleNormalColor = UIColor.gray
        titleDataSource.titleSelectedColor = UIColor.red
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 15.0)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 15.0)
        
        var segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kBaseSegmentHeight))
        segmentedView.delegate = self
        segmentedView.dataSource = titleDataSource
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .normal
        lineView.indicatorHeight = ADAPTATIONRATIO * 4.0
        lineView.verticalOffset = ADAPTATIONRATIO * 2.0
        segmentedView.indicators = [lineView]
        
        segmentedView.contentScrollView = self.scrollView
        
        let btmLineView = UIView()
        btmLineView.backgroundColor = UIColor.grayColor(g: 110)
        segmentedView.addSubview(btmLineView)
        btmLineView.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalTo(segmentedView)
            make.height.equalTo(ADAPTATIONRATIO * 2.0)
        })
        
        return segmentedView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: kBaseSegmentHeight, width: kScreenW, height: kScreenH - kBaseSegmentHeight - kNavBar_Height))
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.gk_openGestureHandle = true
        
        return scrollView
    }()
    
    var childVCs = [GKBaseListViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navTitle = "headerScroll";
        self.gk_navTitleColor = .black
        self.gk_navTitleFont = UIFont.boldSystemFont(ofSize: 18);
        self.gk_navBackgroundColor = .white
        self.gk_statusBarStyle = .default;
        self.gk_backStyle = .black;
        self.gk_navLineHidden = true
        
        self.view.addSubview(pageScrollView)
        
        pageScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: kNavBar_Height, left: 0, bottom: 0, right: 0))
        }
        
        // 设置数据
        self.titleDataSource.titles = self.titles;
        self.titleDataSource.reloadData(selectedIndex: 0)
        
        // 根据标题创建控制器并添加到scrollView
        for i in 0..<self.titles.count {
            let vc = GKBaseListViewController(listType: .UITableView)
            self.childVCs.append(vc)
            
            self.scrollView.addSubview(vc.view)
            vc.view.frame = CGRect(x: CGFloat(i) * kScreenW, y: 0, width: kScreenW, height: kScreenH - kBaseSegmentHeight - kNavBar_Height)
        }
        self.scrollView.contentSize = CGSize(width: CGFloat(self.titles.count) * kScreenW, height: 0)
        
        // 刷新
        self.pageScrollView.reloadData()
    }
}

extension GKHeaderScrollViewController: GKPageScrollViewDelegate {
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.headerView
    }
    
    func pageView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.pageView
    }
    
    func listView(in pageScrollView: GKPageScrollView) -> [GKPageListViewDelegate] {
        return self.childVCs
    }
}

extension GKHeaderScrollViewController: JXSegmentedViewDelegate {
    
}

extension GKHeaderScrollViewController: GKHeaderScrollViewDelegate {
    func headerScrollViewWillBeginScroll() {
        self.pageScrollView.horizonScrollViewWillBeginScroll()
    }
    
    func headerScrollViewDidEndScroll() {
        self.pageScrollView.horizonScrollViewDidEndedScroll()
    }
}
