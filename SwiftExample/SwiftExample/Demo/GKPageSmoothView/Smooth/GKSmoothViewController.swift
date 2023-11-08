//
//  GKSmoothViewController.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2020/5/12.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit
import JXSegmentedViewExt
import GKNavigationBarSwift
import GKPageSmoothView

class GKSmoothViewController: GKDemoBaseViewController {

    lazy var smoothView: GKPageSmoothView = {
        let smoothView = GKPageSmoothView(dataSource: self)
        smoothView.delegate = self
        smoothView.ceilPointHeight = GKDevice.statusBarNavBarHeight()
        smoothView.isControlVerticalIndicator = true
        smoothView.listCollectionView.gk_openGestureHandle = true
        smoothView.defaultSelectedIndex = 1
        return smoothView
    }()
    
    lazy var headerView: GKDYHeaderView = {
        let headerView = GKDYHeaderView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 500))
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
        categoryView.defaultSelectedIndex = 1
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .lengthen
        categoryView.indicators = [lineView]
        
        return categoryView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navBarAlpha = 0.0
        self.gk_navBackgroundColor = UIColor.rgbColor(r: 34, g: 33, b: 37)
        self.gk_statusBarStyle = .lightContent
        self.gk_navTitleColor = .white
        self.gk_navTitle = "滑动延续"
        gk_navRightBarButtonItem = UIBarButtonItem.gk_item(image: UIImage(named: "wb_more"), target: self, action: #selector(moreAction))
        
        self.view.addSubview(self.smoothView)
        self.smoothView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var frame = self.headerView.frame
            frame.size.height = 800
            self.headerView.frame = frame
            
            self.categoryView.contentScrollView = self.smoothView.listCollectionView
            self.smoothView.refreshHeaderView()
            self.smoothView.reloadData()
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            var frame = self.headerView.frame
//            frame.size.height = kDYHeaderHeight + 100
//            self.headerView.frame = frame
//
//            self.smoothView.refreshHeaderView()
//        }
    }
    
    @objc func moreAction() {
        smoothView.snp.remakeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(100)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if headerView.frame.width != view.bounds.width {
            headerView.frame.size.width = view.bounds.width
//            smoothView.refreshHeaderView()
//            smoothView.reloadData()
        }
        
        if categoryView.frame.width != view.bounds.width {
            categoryView.frame.size.width = view.bounds.width
            categoryView.reloadData()
        }
    }
}

extension GKSmoothViewController: GKPageSmoothViewDataSource, GKPageSmoothViewDelegate, GKSmoothListViewDelegate {
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
//        let listView = GKSmoothListView(listType: GKSmoothListType(rawValue: index)!, delegate: self)
        let listView = GKSmoothListView(listType: .tableView, delegate: self, index: index)
        listView.requestData()
        return listView
    }
    
    func smoothViewListScrollViewDidScroll(_ smoothView: GKPageSmoothView, scrollView: UIScrollView, contentOffset: CGPoint) {
        // 导航栏显隐
        let offsetY = contentOffset.y
        // 0-200 0
        // 200 - KDYHeaderHeigh - kNavBarheight 渐变从0-1
        // > KDYHeaderHeigh - kNavBarheight 1
        var alpha: CGFloat = 0;
        if (offsetY < 200) {
            alpha = 0;
        }else if (offsetY > (kDYHeaderHeight - kNavBar_Height)) {
            alpha = 1;
        }else {
            alpha = (offsetY - 200) / (kDYHeaderHeight - kNavBar_Height - 200);
        }
        self.gk_navBarAlpha = alpha;
        
        self.headerView.scrollViewDidScroll(offsetY: offsetY);
    }
    
    func smoothViewHeaderContainerHeight() -> CGFloat {
        return self.smoothView.headerContainerHeight
    }
}
