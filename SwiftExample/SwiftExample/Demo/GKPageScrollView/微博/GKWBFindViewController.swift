//
//  GKWBFindViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/25.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import MJRefresh
import JXSegmentedView
import GKNavigationBarSwift
import GKPageScrollView

class GKWBFindViewController: GKDemoBaseViewController {

    var titleDataSource = JXSegmentedTitleDataSource()
    
    lazy var topView: UIView = {
        let topView = UIView()
        topView.backgroundColor = UIColor.white
        topView.alpha = 0
        topView.isUserInteractionEnabled = false
        return topView
    }()
    
    lazy var pageScrollView: GKPageScrollView = {
        let pageScrollView = GKPageScrollView(delegate: self)
        pageScrollView.ceilPointHeight = CGFloat(kStatusBar_Height)
        pageScrollView.isAllowListRefresh = true
        pageScrollView.isDisableMainScrollInCeil = true
        return pageScrollView
    }()
    
    lazy var headerView: UIView = {
        let headerImg = UIImage(named: "wb_find")
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: (kScreenW * (headerImg?.size.height)! / (headerImg?.size.width)!) + GK_STATUSBAR_HEIGHT))
        
        let imgView = UIImageView(frame: CGRect(x: 0, y: GK_STATUSBAR_HEIGHT, width: kScreenW, height: kScreenW * (headerImg?.size.height)! / (headerImg?.size.width)!))
        imgView.image = headerImg
        headerView.addSubview(imgView)
        return headerView
    }()
    
    let titles = ["话题", "榜单", "北京", "超话"]
    
    lazy var childVCs: [GKWBListViewController] = {
        var childVCs = [GKWBListViewController]()
        
        let homeVC = GKWBListViewController()
        homeVC.isCanScroll = true
        
        let wbVC = GKWBListViewController()
        wbVC.isCanScroll = true
        
        let videoVC = GKWBListViewController()
        videoVC.isCanScroll = true
        
        let storyVC = GKWBListViewController()
        storyVC.isCanScroll = true
        
        childVCs.append(homeVC)
        childVCs.append(wbVC)
        childVCs.append(videoVC)
        childVCs.append(storyVC)
        return childVCs
    }()
    
    lazy var pageView: UIView = {
        let pageView = UIView()
        pageView.backgroundColor = UIColor.clear
        
        pageView.addSubview(self.segmentedView)
        pageView.addSubview(self.contentScrollView)
        
        return pageView
    }()
    
    lazy var segmentedView: UIView = {
        titleDataSource.titles = self.titles
        titleDataSource.titleNormalColor = UIColor.grayColor(g: 157)
        titleDataSource.titleSelectedColor = UIColor.black
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 17.0)
        titleDataSource.titleSelectedFont = UIFont.boldSystemFont(ofSize: 18.0)
        titleDataSource.reloadData(selectedIndex: 0)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 44.0))
        
        let segmentedView = JXSegmentedView(frame: CGRect(x: ADAPTATIONRATIO * 100.0, y: 0, width: kScreenW - ADAPTATIONRATIO * 200.0, height: 44.0))
        segmentedView.dataSource = titleDataSource
        view.addSubview(segmentedView)
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.indicatorWidth = ADAPTATIONRATIO * 60.0
        lineView.indicatorHeight = ADAPTATIONRATIO * 6.0
        lineView.verticalOffset = ADAPTATIONRATIO * 4
        lineView.lineStyle = .lengthenOffset
        segmentedView.indicators = [lineView]
        
        segmentedView.contentScrollView = self.contentScrollView;
        
        view.addSubview(self.backBtn)
        
        let btmLineView = UIView()
        btmLineView.backgroundColor = UIColor.grayColor(g: 226.0)
        segmentedView.addSubview(btmLineView)
        btmLineView.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalTo(segmentedView)
            make.height.equalTo(0.5)
        })
        
        return view
    }()
    
    lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.gk_image(with: "btn_back_black"), for: .normal)
        btn.frame = CGRect(x: 12, y: 0, width: 44, height: 44)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var contentScrollView: UIScrollView = {
        let scrollW = kScreenW
        let scrollH = kScreenH - kNavBar_Height
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 44.0, width: scrollW, height: scrollH))
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.gk_openGestureHandle = true
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        for (idx, vc) in self.childVCs.enumerated() {
//            self.addChild(vc)
            scrollView.addSubview(vc.view)
            
            vc.view.frame = CGRect(x: CGFloat(idx) * scrollW, y: 0, width: scrollW, height: scrollH)
        }
        scrollView.contentSize = CGSize(width: CGFloat(self.childVCs.count) * scrollW, height: 0)
        
        return scrollView
    }()
    
    var isMainCanScroll = false
    var shouldPop = true
    
    var backItem: UIBarButtonItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_statusBarStyle = .default
        self.gk_popDelegate = self
        
        self.view.addSubview(self.pageScrollView)
        self.view.addSubview(self.topView)
        
        self.pageScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        self.topView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.height.equalTo(kStatusBar_Height)
        }
        
        self.pageScrollView.mainTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self?.pageScrollView.mainTableView.mj_header?.endRefreshing()
            })
        })
        
        self.pageScrollView.reloadData()
    }
    
    @objc func backAction() {
        if self.isMainCanScroll {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.pageScrollView.scrollToOriginalPoint()
            self.backBtn.isHidden = true
            self.topView.alpha = 0
        }
    }
}

extension GKWBFindViewController: GKPageScrollViewDelegate {
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.headerView
    }
    
    func pageView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.pageView
    }
    
    func listView(in pageScrollView: GKPageScrollView) -> [GKPageListViewDelegate] {
        return self.childVCs
    }
    
    func mainTableViewDidScroll(_ scrollView: UIScrollView, isMainCanScroll: Bool) {
        self.isMainCanScroll = isMainCanScroll
        
        if self.isMainCanScroll {
            self.backBtn.isHidden = true
            self.shouldPop = true
            self.gk_systemGestureHandleDisabled = false
        }else {
            self.backBtn.isHidden = false
            self.shouldPop = false
            self.gk_systemGestureHandleDisabled = true
        }
        
        // topView透明度渐变
        // contentOffsetY GK_STATUSBAR_HEIGHT-64  topView的alpha 0-1
        let offsetY = scrollView.contentOffset.y;
        
        var alpha: CGFloat = 0;
        
        let statusBarH = GK_STATUSBAR_HEIGHT
        
        if (offsetY <= statusBarH) { // alpha: 0
            alpha = 0;
        }else if (offsetY >= 64) { // alpha: 1
            alpha = 1;
        }else { // alpha: 0-1
            alpha = (offsetY - statusBarH) / (64 - statusBarH);
        }
        
        self.topView.alpha = alpha;
    }
}

extension GKWBFindViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.pageScrollView.horizonScrollViewWillBeginScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageScrollView.horizonScrollViewDidEndedScroll()
    }
}

extension GKWBFindViewController: GKViewControllerPopDelegate {
    func viewControllerPopScrollEnded(finished: Bool) {
        if (!self.shouldPop) {
            backAction()
        }
    }
    
    override func navigationShouldPopOnGesture() -> Bool {
        return self.shouldPop
    }
}
