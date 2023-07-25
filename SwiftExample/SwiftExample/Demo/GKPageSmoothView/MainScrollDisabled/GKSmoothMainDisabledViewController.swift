//
//  GKSmoothMainDisabledViewController.swift
//  SwiftExample
//
//  Created by QuintGao on 2021/7/16.
//

import UIKit
import GKPageSmoothView
import JXSegmentedViewExt

class GKSmoothMainDisabledViewController: GKDemoBaseViewController {

    lazy var smoothView: GKPageSmoothView = {
        let smoothView = GKPageSmoothView(dataSource: self)
        smoothView.delegate = self
        smoothView.isMainScrollDisabled = true;   // 禁止主页滑动，只允许列表滑动
        smoothView.listCollectionView.gk_openGestureHandle = true;
        return smoothView
    }()
    
    lazy var headerView: UIImageView = {
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: ADAPTATIONRATIO * 400.0))
        headerView.image = UIImage(named: "test")
        return headerView
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
        
        return categoryView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navBarAlpha = 0;
        self.gk_navTitle = "禁止主页滑动"
        self.gk_navTitleColor = .white
        self.gk_statusBarStyle = .lightContent;
        
        self.view.addSubview(self.smoothView)
        self.smoothView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.categoryView.contentScrollView = self.smoothView.listCollectionView
            self.smoothView.refreshHeaderView()
            self.smoothView.reloadData()
        }
    }
}

extension GKSmoothMainDisabledViewController: GKPageSmoothViewDataSource, GKPageSmoothViewDelegate, GKSmoothListViewDelegate {
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
        let listVC = GKBaseListViewController(listType: GKBaseListType(rawValue: index) ?? .UITableView)
        listVC.shouldLoadData = true
        return listVC
    }
    
    func smoothViewHeaderContainerHeight() -> CGFloat {
        return self.smoothView.headerContainerHeight
    }
}
