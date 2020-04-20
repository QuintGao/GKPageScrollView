//
//  GKNest2ViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/10/22.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import JXSegmentedView

class GKNest2ViewController: GKDemoBaseViewController {

    var titleDataSource = JXSegmentedTitleDataSource()
    
    var currentNestView = GKNest2View()
    
    lazy var segmentedView: JXSegmentedView = {
        titleDataSource.titleNormalColor = UIColor.black
        titleDataSource.titleSelectedColor = UIColor.black
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 15.0)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 16.0)
        titleDataSource.titles = ["精选", "时尚", "电器", "超市", "生活", "运动", "饰品", "数码", "家装", "手机"]
        
        var segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 50.0))
        segmentedView.delegate = self
        segmentedView.dataSource = titleDataSource
        segmentedView.contentEdgeInsetLeft = 0;
        segmentedView.contentEdgeInsetRight = 0;
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .normal
        lineView.indicatorHeight = ADAPTATIONRATIO * 4.0
        lineView.verticalOffset = ADAPTATIONRATIO * 2.0
        segmentedView.indicators = [lineView]
        
        segmentedView.contentScrollView = self.contentScrollView
        
        return segmentedView
    }()
    
    lazy var contentScrollView: GKNestScrollView = {
        let scrollView = GKNestScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.gestureDelegate = self
        
        let width = kScreenW
        let height = kScreenH - kStatusBar_Height - 50.0
        
        for (i, value) in self.titleDataSource.titles.enumerated() {
            let nestView = GKNest2View()
            nestView.mainScrollView = scrollView
            nestView.frame = CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height)
            scrollView.addSubview(nestView)
        }
        scrollView.contentSize = CGSize(width: CGFloat(self.titleDataSource.titles.count) * width, height: 0)
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_backStyle = .black
        
        self.view.addSubview(self.segmentedView)
        self.view.addSubview(self.contentScrollView)
        
        self.segmentedView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: 44.0)
        self.gk_navTitleView = self.segmentedView
        
        self.contentScrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.gk_navigationBar.snp_bottom)
        }
        
        self .segmentedView(self.segmentedView, didSelectedItemAt: 0)
    }
}

extension GKNest2ViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        self.currentNestView = self.contentScrollView.subviews[index] as! GKNest2View
    }
}

extension GKNest2ViewController: UIScrollViewDelegate {}
extension GKNest2ViewController: GKNestScrollViewDelegate {
    func nestScrollViewGestureRecognizerShouldBegin(_ scrollView: GKNestScrollView, gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.panBack(scrollView: scrollView, gestureRecognizer: gestureRecognizer) {
            return false
        }
        
        if let listScrollView = self.currentNestView.pageScrollView.listContainerView.collectionView {
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
        }
        
        return true
    }
    
    func nestScrollGestureRecognizer(_ scrollView: GKNestScrollView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
