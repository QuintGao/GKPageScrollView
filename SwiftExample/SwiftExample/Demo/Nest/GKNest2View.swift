//
//  GKNest2View.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/10/22.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import JXSegmentedView
import GKPageScrollView

class GKNest2View: UIView {

    public lazy var pageScrollView: GKPageScrollView = {
        let pageScrollView = GKPageScrollView(delegate: self)
        pageScrollView.isLazyLoadList = true
        pageScrollView.ceilPointHeight = 0
        pageScrollView.mainTableView.gestureDelegate = self
        return pageScrollView
    }()
    
    public weak var mainScrollView: UIScrollView?
    
    lazy var headerView: UIImageView = {
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: ADAPTATIONRATIO * 400.0))
        headerView.image = UIImage(named: "test")
        return headerView
    }()
    
    var titleDataSource = JXSegmentedTitleDataSource()
    
    lazy var segmentedView: JXSegmentedView = {
        titleDataSource.titleNormalColor = UIColor.gray
        titleDataSource.titleSelectedColor = UIColor.gray
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 14.0)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 14.0)
        titleDataSource.titles = ["综合", "销量", "价格"]
        
        var segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kBaseSegmentHeight))
        segmentedView.delegate = self
        segmentedView.dataSource = titleDataSource
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .lengthen
        segmentedView.indicators = [lineView]
        
        segmentedView.contentScrollView = self.pageScrollView.listContainerView.collectionView
        
        return segmentedView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.pageScrollView)
        
        self.pageScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        self.pageScrollView.reloadData()
        self.pageScrollView.listContainerView.collectionView.isNestEnabled = true;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GKNest2View: GKPageScrollViewDelegate {
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.headerView
    }
    
    func segmentedView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.segmentedView
    }
    
    func numberOfLists(in pageScrollView: GKPageScrollView) -> Int {
        return self.titleDataSource.titles.count
    }
    
    func pageScrollView(_ pageScrollView: GKPageScrollView, initListAtIndex index: Int) -> GKPageListViewDelegate {
        return GKNestListView()
    }
}

extension GKNest2View: JXSegmentedViewDelegate {
    
}

extension GKNest2View: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}

extension GKNest2View: GKPageTableViewGestureDelegate {
    func pageTableView(_ tableView: GKPageTableView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.view == self.mainScrollView || otherGestureRecognizer.view == self.mainScrollView {
            return false
        }
        
        // 特殊处理，解决返回手势与GKPageTableView手势的冲突
        let internalTargets: [AnyObject] = otherGestureRecognizer.value(forKey: "targets") as! [AnyObject]
        let internalTarget: AnyObject = (internalTargets.first?.value(forKey: "target"))! as AnyObject
        if internalTarget.isKind(of: NSClassFromString("_UINavigationInteractiveTransition")!) {
            return false
        }
        
        return true
    }
}
