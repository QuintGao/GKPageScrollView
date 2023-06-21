//
//  GKPageView.swift
//  SwiftUIExample
//
//  Created by QuintGao on 2023/6/21.
//

import UIKit
import GKPageScrollView
import JXSegmentedViewExt
import SnapKit

class GKPageView: UIView {
    var dataSource = JXSegmentedTitleDataSource()
    
    lazy var headerView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: 300))
        headerView.backgroundColor = .red
        return headerView
    }()
    
    lazy var segmentedView: JXSegmentedView = {
        let segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: 40))
        
        dataSource.titleNormalFont = .systemFont(ofSize: 14)
        dataSource.titleSelectedFont = .boldSystemFont(ofSize: 15)
        dataSource.titleNormalColor = .gray
        dataSource.titleSelectedColor = .black
        dataSource.isItemSpacingAverageEnabled = true
        segmentedView.dataSource = dataSource
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.indicatorWidth = 20
        lineView.indicatorHeight = 3
        lineView.indicatorColor = .red
        lineView.lineStyle = .lengthen
        segmentedView.indicators = [lineView]
        
        segmentedView.listContainer = pageScrollView.listContainerView
        
        return segmentedView
    }()
    
    lazy var pageScrollView: GKPageScrollView = {
        let pageScrollView = GKPageScrollView(delegate: self)
        pageScrollView.isLazyLoadList = true
        
        return pageScrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
        
        dataSource.titles = ["关注", "推荐", "视频", "直播"]
        segmentedView.defaultSelectedIndex = 1
        segmentedView.reloadData()
        pageScrollView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        addSubview(pageScrollView)
        pageScrollView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
}

extension GKPageListContainerView: JXSegmentedViewListContainer {}

extension GKPageView: GKPageScrollViewDelegate {
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        headerView
    }
    
    func segmentedView(in pageScrollView: GKPageScrollView) -> UIView {
        segmentedView
    }
    
    func numberOfLists(in pageScrollView: GKPageScrollView) -> Int {
        dataSource.titles.count
    }
    
    func pageScrollView(_ pageScrollView: GKPageScrollView, initListAtIndex index: Int) -> GKPageListViewDelegate {
        GKPageListView()
    }
}
