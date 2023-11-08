//
//  GKWBFindViewController.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2019/2/25.
//  Copyright © 2019 QuintGao. All rights reserved.
//

import UIKit
import MJRefresh
import JXSegmentedViewExt
import GKNavigationBarSwift
import GKPageScrollView

let kThemeColor = UIColor.rgbColor(r: 243, g: 136, b: 68)

class GKWBFindViewController: GKDemoBaseViewController {

    var titleDataSource = JXSegmentedSubTitleImageDataSource()
    
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
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: (kScreenW * (headerImg?.size.height)! / (headerImg?.size.width)!) + GKDevice.statusBarFrame().size.height))
        
        let imgView = UIImageView()
        imgView.image = headerImg
        headerView.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.edges.equalTo(headerView)
        }
        return headerView
    }()
    
    let titles = ["热点", "种草", "本地", "放映厅", "直播"]
    let subTitles = ["热点资讯", "潮流好物", "同城关注", "宅家必看", "大V在线"]
    
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
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 54.0))
        view.addSubview(self.backBtn)
        view.addSubview(self.categoryView)
        return view
    }()
    
    lazy var categoryView: JXSegmentedView = {
        titleDataSource.titles = self.titles
        titleDataSource.subTitles = self.subTitles
        titleDataSource.titleNormalFont = UIFont.boldSystemFont(ofSize: 15)
        titleDataSource.titleSelectedFont = UIFont.boldSystemFont(ofSize: 15)
        titleDataSource.titleNormalColor = UIColor.black
        titleDataSource.titleSelectedColor = kThemeColor
        titleDataSource.titleLabelVerticalOffset = -10
        titleDataSource.subTitleNormalFont = UIFont.systemFont(ofSize: 11)
        titleDataSource.subTitleSelectedFont = UIFont.systemFont(ofSize: 11)
        titleDataSource.subTitleNormalColor = UIColor.gray
        titleDataSource.subTitleSelectedColor = UIColor.white
        titleDataSource.subTitleWithTitlePositionMargin = 3
        titleDataSource.itemSpacing = 0
        titleDataSource.itemWidthIncrement = 16
        titleDataSource.imageSize = CGSize(width: 12, height: 12)
        titleDataSource.imageTypes = [.none, .left, .none, .left, .left]
        titleDataSource.normalImageInfos = ["", "zhongcao", "", "fangying", "gif"]
        titleDataSource.selectedImageInfos = ["", "zhongcao", "", "fangying", "gif"]
        titleDataSource.isIgnoreImageWidth = true
        titleDataSource.loadImageClosure = { imageView, info in
            if info == "gif" {
                var images = [UIImage]()
                for i in 0..<4 {
                    let imgName = "cm2_list_icn_loading" + "\(i+1)"
                    
                    let img = changeColor(image: UIImage(named: imgName)!, color: UIColor.rgbColor(r: 200, g: 38, b: 39))
                    images.append(img)
                }
                
                for i in (0..<4).reversed() {
                    let imgName = "cm2_list_icn_loading" + "\(i+1)"
                    
                    let img = changeColor(image: UIImage(named: imgName)!, color: UIColor.rgbColor(r: 200, g: 38, b: 39))
                    images.append(img)
                }
                imageView.animationImages = images
                imageView.animationDuration = 0.75
                imageView.startAnimating()
            }else {
                if info != "" {
                    imageView.image = UIImage(named: info)
                }
            }
        }
        
        let categoryView = JXSegmentedView(frame: CGRect(x: ADAPTATIONRATIO * 60.0, y: 0, width: kScreenW - ADAPTATIONRATIO * 80.0, height: 54.0))
        categoryView.dataSource = self.titleDataSource
        categoryView.indicators = [self.lineView]
        categoryView.listContainer = self.pageScrollView.listContainerView
        return categoryView
    }()
    
    lazy var lineView: JXSegmentedIndicatorLineView = {
        let lineView = JXSegmentedIndicatorLineView()
        lineView.indicatorHeight = 16
        lineView.verticalOffset = 10
        lineView.indicatorWidthIncrement = 8
        lineView.lineScrollOffsetX = 0
        lineView.indicatorColor = kThemeColor
        lineView.lineStyle = .lengthen
        return lineView
    }()
    
    lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.gk_image(with: "btn_back_black"), for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
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
    var isScrollTop = false
    
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
        
        self.categoryView.reloadData()
        self.pageScrollView.reloadData()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            self.pageScrollView.snp.remakeConstraints { (make) in
//                make.left.right.top.equalTo(self.view)
//                make.bottom.equalTo(self.view).offset(-ADAPTATIONRATIO * 100)
//            }
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if headerView.bounds.width == view.bounds.width { return }
        
        let headerImg = UIImage(named: "wb_find")
        headerView.frame = CGRectMake(0, 0, view.bounds.width, view.bounds.width * (headerImg?.size.height)! / (headerImg?.size.width)! + GKDevice.statusBarFrame().size.height)
        segmentedView.frame = CGRectMake(0, 0, view.bounds.width, 54.0)
        categoryView.reloadData()
        pageScrollView.reloadData()
        
        let scrollW = view.bounds.width
        let scrollH = view.bounds.height - kNavBar_Height
        contentScrollView.frame = CGRectMake(0, 44.0, scrollW, scrollH)
        contentScrollView.contentSize = CGSize(width: CGFloat(self.childVCs.count) * scrollW, height: 0)
        
        for (idx, vc) in childVCs.enumerated() {
            vc.view.frame = CGRectMake(CGFloat(idx) * scrollW, 0, scrollW, scrollH)
        }
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
        let listVC = GKWBListViewController()
        listVC.isCanScroll = true
        return listVC
    }
    
    func mainTableViewDidScroll(_ scrollView: UIScrollView, isMainCanScroll: Bool) {
        self.isMainCanScroll = isMainCanScroll
        
        if !self.isMainCanScroll {
            self.shouldPop = false
            self.backBtn.isHidden = false
            self.gk_systemGestureHandleDisabled = true
            
            // 到达顶部
            if (self.isScrollTop) { return }
            self.isScrollTop = true
            titleDataSource.subTitles = ["", "", "", "", ""]
            titleDataSource.titleLabelVerticalOffset = 0
            titleDataSource.titleNormalFont = UIFont.boldSystemFont(ofSize: 16)
            titleDataSource.titleSelectedFont = UIFont.boldSystemFont(ofSize: 18)
            self.lineView.indicatorHeight = 3
            self.lineView.verticalOffset = 4
            self.lineView.indicatorWidthIncrement = -8
            self.categoryView.indicators = [self.lineView]
            self.reloadCategory(height: 44)
        }else {
            self.shouldPop = true
            self.backBtn.isHidden = true
            self.gk_systemGestureHandleDisabled = false
            
            if !self.isScrollTop { return }
            self.isScrollTop = false
            titleDataSource.subTitles = self.subTitles
            titleDataSource.titleLabelVerticalOffset = -10
            titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 15)
            titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 15)
            self.lineView.indicatorHeight = 16
            self.lineView.verticalOffset = 10
            self.lineView.indicatorWidthIncrement = 8
            self.categoryView.indicators = [self.lineView]
            self.reloadCategory(height: 54)
        }
        
        // topView透明度渐变
        // contentOffsetY GK_STATUSBAR_HEIGHT-64  topView的alpha 0-1
        let offsetY = scrollView.contentOffset.y;
        
        var alpha: CGFloat = 0;
        
        let statusBarH = GKDevice.statusBarFrame().size.height
        
        if (offsetY <= statusBarH) { // alpha: 0
            alpha = 0;
        }else if (offsetY >= 64) { // alpha: 1
            alpha = 1;
        }else { // alpha: 0-1
            alpha = (offsetY - statusBarH) / (64 - statusBarH);
        }
        
        self.topView.alpha = alpha;
    }
    
    func reloadCategory(height: CGFloat) {
        UIView.animate(withDuration: 0.15) {
            var frame = self.segmentedView.frame
            frame.size.height = height
            self.segmentedView.frame = frame
            self.pageScrollView.refreshSegmentedView()
            
            frame = self.categoryView.frame
            frame.size.height = height
            self.categoryView.frame = frame
            self.categoryView.reloadData()
            self.categoryView.layoutSubviews()
        }
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
    
    func navigationShouldPopOnGesture() -> Bool {
        return self.shouldPop
    }
}
