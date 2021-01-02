//
//  GKDYViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/26.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import JXSegmentedView
import GKPageScrollView

class GKDYViewController: GKDemoBaseViewController {

    var titleDataSource = JXSegmentedTitleDataSource()
    
    lazy var pageScrollView: GKPageScrollView = {
        let pageScrollView = GKPageScrollView(delegate: self)
        return pageScrollView
    }()
    
    lazy var headerView: GKDYHeaderView = {
        return GKDYHeaderView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kDYHeaderHeight))
    }()
    
    lazy var pageView: UIView = {
        var pageView = UIView()
        pageView.backgroundColor = UIColor.clear
        
        pageView.addSubview(self.segmentedView)
        pageView.addSubview(self.scrollView)
        
        return pageView
    }()
    
    lazy var segmentedView: JXSegmentedView = {
        titleDataSource.titles = self.titles
        titleDataSource.titleNormalColor = UIColor.gray
        titleDataSource.titleSelectedColor = UIColor.white
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 16.0)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 16.0)
        titleDataSource.reloadData(selectedIndex: 0)
        
        let segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 40.0))
        segmentedView.backgroundColor = UIColor.rgbColor(r: 34, g: 33, b: 37)
        segmentedView.delegate = self
        segmentedView.dataSource = titleDataSource
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.indicatorColor = UIColor.yellow
        lineView.indicatorWidth = 80.0
        lineView.indicatorCornerRadius = 0
        lineView.lineStyle = .normal
        segmentedView.indicators = [lineView]
        
        segmentedView.contentScrollView = self.scrollView
        
        // 添加分割线
        let btmLineView = UIView()
        btmLineView.frame = CGRect(x: 0, y: 40 - 0.5, width: kScreenW, height: 0.5)
        btmLineView.backgroundColor = UIColor.grayColor(g: 200)
        segmentedView.addSubview(btmLineView)
        
        return segmentedView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollW = kScreenW
        let scrollH = kScreenH - kNavBar_Height - 40.0
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 40, width: scrollW, height: scrollH))
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.gk_openGestureHandle = true
        
        for (idx, vc) in self.childVCs.enumerated() {
            self.addChild(vc)
            scrollView.addSubview(vc.view)
            
            vc.view.frame = CGRect(x: CGFloat(idx) * scrollW, y: 0, width: scrollW, height: scrollH)
        }
        scrollView.contentSize = CGSize(width: CGFloat(self.childVCs.count) * scrollW, height: 0)
        return scrollView
    }()
    
    let titles = ["作品 129", "动态 129", "喜欢591"]
    
    lazy var childVCs: [GKDYListViewController] = {
        var childVCs = [GKDYListViewController]()
        
        let publishVC = GKDYListViewController()
        let dynamicVC = GKDYListViewController()
        let lovedVC   = GKDYListViewController()
        
        childVCs.append(publishVC)
        childVCs.append(dynamicVC)
        childVCs.append(lovedVC)
        
        return childVCs
    }()
    
    lazy var titleView: UILabel = {
        var titleView = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: 44))
        titleView.font = UIFont.systemFont(ofSize: 18.0)
        titleView.textColor = UIColor.white
        titleView.text = "❤️会说话的刘二豆❤️"
        titleView.alpha = 0
        return titleView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gk_navBarAlpha = 0
        self.gk_navBackgroundColor = UIColor.rgbColor(r: 34, g: 33, b: 37)
        self.gk_navTitleView = self.titleView
        self.gk_statusBarStyle = .lightContent
        self.gk_navLineHidden = true
        
        self.view.addSubview(self.pageScrollView)
        self.pageScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.pageScrollView.reloadData()
    }
}

extension GKDYViewController: GKPageScrollViewDelegate {
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        return headerView
    }
    
    func pageView(in pageScrollView: GKPageScrollView) -> UIView {
        return pageView
    }
    
    func listView(in pageScrollView: GKPageScrollView) -> [GKPageListViewDelegate] {
        return self.childVCs
    }
    
    func mainTableViewDidScroll(_ scrollView: UIScrollView, isMainCanScroll: Bool) {
        // 导航栏显隐
        let offsetY = scrollView.contentOffset.y
        
        // 0-200 0
        // 200 - KDYHeaderHeight - kNavbarHeight 渐变从0-1
        // > kDYHeaderHeight - kNavBarHeight 1
        var alpha: CGFloat = 0
        if offsetY < 200 {
            alpha = 0
        }else if offsetY > (kDYHeaderHeight - kNavBar_Height) {
            alpha = 1
        }else {
            alpha = (offsetY - 200) / (kDYHeaderHeight - kNavBar_Height - 200)
        }
        self.gk_navBarAlpha = alpha
        self.titleView.alpha = alpha
        
        self.headerView.scrollViewDidScroll(offsetY: offsetY)
    }
}

extension GKDYViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        print("刷新数据")
    }
}

extension GKDYViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.pageScrollView.horizonScrollViewWillBeginScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageScrollView.horizonScrollViewDidEndedScroll()
    }
}
