//
//  GKBasePageViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import JXSegmentedView
import GKPageScrollView

public let kRefreshDuration  = 0.5
public let kBaseHeaderHeight = kScreenW * 385.0 / 704.0
public let kBaseSegmentHeight: CGFloat = 40.0

class GKBasePageViewController: GKDemoBaseViewController {

    lazy var headerView: UIImageView! = {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kBaseHeaderHeight))
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.image = UIImage(named: "test")
        
        return imgView
    }()
    
    lazy var pageView: UIView! = {
        let pageView = UIView()
        pageView.addSubview(self.segmentedView)
        pageView.addSubview(self.contentScrollView)
        
        return pageView
    }()
    
    lazy var childVCs: [GKBaseListViewController] = {
        var childVCs = [GKBaseListViewController]()
        
        childVCs.append(GKBaseListViewController(listType: .UITableView))
        childVCs.append(GKBaseListViewController(listType: .UICollectionView))
        childVCs.append(GKBaseListViewController(listType: .UIScrollView))
        childVCs.append(GKBaseListViewController(listType: .WKWebView))
        
        return childVCs
    }()
    
    var titleDataSource = JXSegmentedTitleDataSource()
    
    public var pageScrollView: GKPageScrollView!
    public lazy var segmentedView: JXSegmentedView = {
        titleDataSource.titles = ["TableView", "CollectionView", "ScrollView", "WebView"]
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
        
        segmentedView.contentScrollView = self.contentScrollView
        
        let btmLineView = UIView()
        btmLineView.backgroundColor = UIColor.grayColor(g: 110)
        segmentedView.addSubview(btmLineView)
        btmLineView.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalTo(segmentedView)
            make.height.equalTo(ADAPTATIONRATIO * 2.0)
        })
        
        return segmentedView
    }()
   
    lazy var contentScrollView: UIScrollView = {
        let scrollW = kScreenW
        let scrollH = kScreenH - kNavBar_Height - kBaseSegmentHeight
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: kBaseSegmentHeight, width: scrollW, height: scrollH))
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.gk_openGestureHandle = true
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        for (index, vc) in self.childVCs.enumerated() {
            self.addChild(vc)
            scrollView.addSubview(vc.view)
            
            vc.view.frame = CGRect(x: CGFloat(index) * scrollW, y: 0, width: scrollW, height: scrollH)
        }
        scrollView.contentSize = CGSize(width: CGFloat(self.childVCs.count) * scrollW, height: 0)
        
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navTitleColor = UIColor.white
        self.gk_navTitleFont = UIFont.boldSystemFont(ofSize: 18)
        self.gk_navBackgroundColor = UIColor.clear
        self.gk_statusBarStyle = .lightContent
        
        pageScrollView = GKPageScrollView(delegate: self)
        
        self.view.addSubview(pageScrollView)
        
        pageScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}

extension GKBasePageViewController: JXSegmentedViewDelegate {
    
}

extension GKBasePageViewController: GKPageScrollViewDelegate {
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        return headerView
    }
    
    func pageView(in pageScrollView: GKPageScrollView) -> UIView {
        return pageView
    }
    
    func listView(in pageScrollView: GKPageScrollView) -> [GKPageListViewDelegate] {
        return childVCs
    }
}

extension GKBasePageViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.pageScrollView.horizonScrollViewWillBeginScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageScrollView.horizonScrollViewDidEndedScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.pageScrollView.horizonScrollViewDidEndedScroll()
    }
}
