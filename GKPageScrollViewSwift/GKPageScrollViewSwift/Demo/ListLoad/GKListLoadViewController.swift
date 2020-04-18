//
//  GKListLoadViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/3/14.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import JXSegmentedView

class GKListLoadViewController: GKDemoBaseViewController {
    var titleDataSource = JXSegmentedTitleDataSource()
    
    lazy var pageScrollView: GKPageScrollView! = {
        let pageScrollView = GKPageScrollView(delegate: self)
        pageScrollView.isLazyLoadList = true
        return pageScrollView
    }()
    
    lazy var headerView: UIImageView = {
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kBaseHeaderHeight))
        headerView.contentMode = .scaleAspectFill
        headerView.clipsToBounds = true
        headerView.image = UIImage(named: "test")
        return headerView
    }()
    
    let titles = ["动态", "文章", "更多"]
    
    lazy var segmentedView: JXSegmentedView = {
        titleDataSource.titles = self.titles
        titleDataSource.titleNormalColor = UIColor.gray
        titleDataSource.titleSelectedColor = UIColor.red
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 15.0)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 15.0)
        titleDataSource.reloadData(selectedIndex: 0)
        
        var segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kBaseSegmentHeight))
        segmentedView.delegate = self
        segmentedView.dataSource = titleDataSource
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .normal
        lineView.indicatorHeight = ADAPTATIONRATIO * 4.0
        lineView.verticalOffset = ADAPTATIONRATIO * 2.0
        segmentedView.indicators = [lineView]
        
        segmentedView.contentScrollView = self.pageScrollView.listContainerView.collectionView
        
        let btmLineView = UIView()
        btmLineView.backgroundColor = UIColor.grayColor(g: 110)
        segmentedView.addSubview(btmLineView)
        btmLineView.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalTo(segmentedView)
            make.height.equalTo(ADAPTATIONRATIO * 2.0)
        })
        
        return segmentedView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navTitle = "列表懒加载"
        self.gk_navTitleColor = UIColor.white
        self.gk_navTitleFont = UIFont.boldSystemFont(ofSize: 18)
        self.gk_navBackgroundColor = UIColor.clear
        self.gk_statusBarStyle = .lightContent
        self.gk_navLineHidden = true
        
        self.view.addSubview(pageScrollView)
        
        pageScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        pageScrollView.reloadData()
    }
}

extension GKListLoadViewController: GKPageScrollViewDelegate {
    func shouldLazyLoadList(in pageScrollView: GKPageScrollView) -> Bool {
        return true
    }
    
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.headerView
    }
    
    func segmentedView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.segmentedView
    }
    
    func numberOfLists(in pageScrollView: GKPageScrollView) -> Int {
        return self.titles.count
    }
    
    func pageScrollView(_ pageScrollView: GKPageScrollView, initListAtIndex index: Int) -> GKPageListViewDelegate {
        let listVC = GKBaseListViewController()
        listVC.shouldLoadData = true
        return listVC
    }
}

extension GKListLoadViewController: JXSegmentedViewDelegate {
    
}
