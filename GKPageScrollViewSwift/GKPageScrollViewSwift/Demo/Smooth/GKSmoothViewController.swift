//
//  GKSmoothViewController.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2020/5/12.
//  Copyright © 2020 gaokun. All rights reserved.
//

import UIKit
import JXSegmentedView

class GKSmoothViewController: GKDemoBaseViewController {

    lazy var smoothView: GKPageSmoothView = {
        let smoothView = GKPageSmoothView(delegate: self)
        smoothView.isControlVerticalIndicator = true
        return smoothView
    }()
    
    lazy var headerView: UIImageView = {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kBaseHeaderHeight))
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.image = UIImage(named: "test")
        return imgView
    }()
    
    var titleDataSource = JXSegmentedTitleDataSource()
    
    lazy var categoryView: JXSegmentedView = {
        let categoryView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kBaseSegmentHeight))
        categoryView.backgroundColor = .white
        
        titleDataSource.titles = ["UITableView", "UICollectionView", "UIScrollView"]
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 14.0)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 16.0)
        titleDataSource.titleNormalColor = .black
        titleDataSource.titleSelectedColor = .black
        titleDataSource.isTitleZoomEnabled = true
        titleDataSource.reloadData(selectedIndex: 0)
        categoryView.dataSource = titleDataSource
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .lengthen
        categoryView.indicators = [lineView]
        
        categoryView.contentScrollView = self.smoothView.listCollectionView
        
        return categoryView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navBarAlpha = 0.0
        self.gk_statusBarStyle = .lightContent
        self.gk_navTitleColor = .white
        self.gk_navTitle = "滑动延续"
        
        self.view.addSubview(self.smoothView)
        self.smoothView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        self.smoothView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.25) {
            self.headerView.frame.size.height = 300.0
            self.smoothView.refreshHeaderView()
        }
    }
}

extension GKSmoothViewController: GKPageSmoothViewDelegate {
    func headerView(in smoothView: GKPageSmoothView) -> UIView {
        return self.headerView
    }
    
    func segmentedView(in smoothView: GKPageSmoothView) -> UIView {
        return self.categoryView
    }
    
    func numberOfLists(in smoothView: GKPageSmoothView) -> Int {
        return self.titleDataSource.titles.count
    }
    
    func smoothView(_ smoothView: GKPageSmoothView, initListAtIndex index: Int) -> GKPageSmoothListViewDelegate {
        let listType: GKSmoothListType = GKSmoothListType(rawValue: index)!
        
        return GKSmoothListView(listType: listType)
    }
}
