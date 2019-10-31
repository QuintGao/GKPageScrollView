//
//  GKNest1ViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/10/18.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import JXSegmentedView

class GKNest1ViewController: GKDemoBaseViewController {

    var titleDataSource = JXSegmentedTitleDataSource()
    
    var nestView = GKNestView()
    
    lazy var pageScrollView: GKPageScrollView = {
        let pageScrollView = GKPageScrollView(delegate: self)
        pageScrollView.isLazyLoadList = true
        return pageScrollView
    }()
    
    lazy var headerView: UIImageView = {
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: ADAPTATIONRATIO * 400.0))
        headerView.image = UIImage(named: "test")
        return headerView
    }()
    
    lazy var segmentedView: JXSegmentedView = {
        titleDataSource.titleNormalColor = UIColor.black
        titleDataSource.titleSelectedColor = UIColor.black
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 15.0)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 16.0)
        titleDataSource.titles = ["精选", "时尚", "电器", "超市", "生活", "运动", "饰品", "数码", "家装", "手机"]
        
        var segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 50.0))
        segmentedView.delegate = self
        segmentedView.dataSource = titleDataSource
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .normal
        lineView.indicatorHeight = ADAPTATIONRATIO * 4.0
        lineView.verticalOffset = ADAPTATIONRATIO * 2.0
        segmentedView.indicators = [lineView]
        
        segmentedView.contentScrollView = self.pageScrollView.listContainerView.collectionView
        
        let bottomLineView = UIView()
        bottomLineView.backgroundColor = UIColor.gray
        segmentedView.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(segmentedView)
            make.height.equalTo(0.5)
        }
        
        return segmentedView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navBackgroundColor = UIColor.clear
        self.gk_navLineHidden = true
        self.gk_statusBarStyle = .lightContent
        
        self.view.addSubview(self.pageScrollView)
        
        self.pageScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        self.pageScrollView.reloadData()
        self.pageScrollView.listContainerView.collectionView.gestureDelegate = self
    }
}

extension GKNest1ViewController: GKPageScrollViewDelegate {
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        return headerView
    }
    
    func segmentedView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.segmentedView
    }
    
    func numberOfLists(in pageScrollView: GKPageScrollView) -> Int {
        return titleDataSource.titles.count
    }
    
    func pageScrollView(_ pageScrollView: GKPageScrollView, initListAtIndex index: Int) -> GKPageListViewDelegate {
        let nestView = GKNestView()
        nestView.delegate = self
        return nestView
    }
}

extension GKNest1ViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        nestView = self.pageScrollView.validListDict[index] as! GKNestView
    }
}

extension GKNest1ViewController: GKNestViewDelegate {
    func nestViewWillScroll() {
        self.pageScrollView.horizonScrollViewWillBeginScroll()
    }
    
    func nestViewEndScroll() {
        self.pageScrollView.horizonScrollViewDidEndedScroll()
    }
}

extension GKNest1ViewController: GKPageListContainerViewGestureDelegate {
    func pageListContainerCollectionView(_ collectionView: GKPageListContainerCollectionView, gestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if self.panBack(scrollView: collectionView, gestureRecognizer: gestureRecognizer) {
            return false
        }
        
        let listScrollView = self.nestView.contentScrollView
        
        if listScrollView.isTracking || listScrollView.isDragging {
            if gestureRecognizer.isMember(of: NSClassFromString("UIScrollViewPanGestureRecognizer")!) {
                let panGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
                
                let velocityX = panGestureRecognizer.velocity(in: gestureRecognizer.view).x
                
                if velocityX > 0 {
                    if listScrollView.contentOffset.x != 0 {
                        return false
                    }
                }else if velocityX < 0 {
                    if listScrollView.contentOffset.x + listScrollView.bounds.size.width != listScrollView.contentSize.width {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    func pageListContainerCollectionView(_ collectionView: GKPageListContainerCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func panBack(scrollView: UIScrollView, gestureRecognizer: UIGestureRecognizer) -> Bool{
        if gestureRecognizer == scrollView.panGestureRecognizer {
            let point = scrollView.panGestureRecognizer.translation(in: scrollView)
            let state = gestureRecognizer.state

            let locationDistance = UIScreen.main.bounds.size.width

            if state == .began || state == .possible {
                let location = gestureRecognizer.location(in: scrollView)
                if point.x > 0 && location.x < locationDistance && scrollView.contentOffset.x <= 0 {
                    return true
                }
            }
        }
        return false
    }
}
