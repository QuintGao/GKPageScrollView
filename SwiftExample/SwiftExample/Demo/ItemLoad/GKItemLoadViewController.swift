//
//  GKItemLoadViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/3/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import JXSegmentedView
import MJRefresh
import GKPageScrollView

class GKItemLoadViewController: GKDemoBaseViewController {

    var titleDataSource = JXSegmentedTitleDataSource()
    
    lazy var pageScrollView: GKPageScrollView! = {
        let pageScrollView = GKPageScrollView(delegate: self)
        pageScrollView.horizontalScrollViewList = [self.scrollView]
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
        
        self.gk_navTitleFont = UIFont.boldSystemFont(ofSize: 18)
        self.gk_navBackgroundColor = UIColor.clear
        self.gk_statusBarStyle = .lightContent
        self.gk_navTitle = "item加载"
        self.gk_navTitleColor = UIColor.white
        self.gk_navLineHidden = true
        
        self.view.addSubview(pageScrollView)
        
        pageScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        pageScrollView.mainTableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                guard let self = self else { return }
                
                self.pageScrollView.mainTableView.mj_header?.endRefreshing()
                
                // 此时标题获取成功
                self.titleDataSource.titles = self.titles;
                self.titleDataSource.reloadData(selectedIndex: 0)

                // 根据标题创建控制器并添加到scrollView
                for i in 0..<self.titles.count {
                    let vc = GKBaseListViewController(listType: GKBaseListType(rawValue: i)!)
                    self.childVCs.append(vc)
                    
                    self.scrollView.addSubview(vc.view)
                    vc.view.frame = CGRect(x: CGFloat(i) * kScreenW, y: 0, width: kScreenW, height: kScreenH - kBaseSegmentHeight - kNavBar_Height)
                }
                self.scrollView.contentSize = CGSize(width: CGFloat(self.titles.count) * kScreenW, height: 0)
                
                // 刷新
                self.pageScrollView.reloadData()
            }
        })
        
        self.pageScrollView.mainTableView.mj_header?.beginRefreshing()
    }
}

extension GKItemLoadViewController: GKPageScrollViewDelegate {
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

extension GKItemLoadViewController: JXSegmentedViewDelegate {
    
}
