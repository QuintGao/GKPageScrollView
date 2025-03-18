//
//  GKCustomViewController.swift
//  SwiftExample
//
//  Created by QuintGao on 2025/3/18.
//

import UIKit
import GKPageScrollView

class GKCustomViewController: GKDemoBaseViewController {

    lazy var pageScrollView: GKPageScrollView = {
        let pageScrollView = GKPageScrollView(delegate: self)
        pageScrollView.isLazyLoadList = true
        return pageScrollView
    }()
    
    lazy var headerView: UIImageView = {
        let imageView = UIImageView(frame: CGRectMake(0, 0, view.frame.width, kBaseHeaderHeight))
        imageView.image = UIImage(named: "test")
        return imageView
    }()
    
    lazy var segmentedView: GKCustomSegmentedView = {
        let view = GKCustomSegmentedView(frame: CGRectMake(0, 0, view.frame.width, kBaseSegmentHeight))
        view.delegate = self;
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gk_navTitleColor = .white
        gk_navTitleFont = .boldSystemFont(ofSize: 18)
        gk_navBackgroundColor = .clear
        gk_navLineHidden = true
        gk_statusBarStyle = .lightContent
        gk_navTitle = "自定义Segmented"
        
        view.addSubview(pageScrollView)
        pageScrollView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        self.pageScrollView.reloadData()
    }
}

extension GKCustomViewController: GKPageScrollViewDelegate {
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        headerView
    }
    
    func segmentedView(in pageScrollView: GKPageScrollView) -> UIView {
        segmentedView
    }
    
    func numberOfLists(in pageScrollView: GKPageScrollView) -> Int {
        3
    }
    
    func pageScrollView(_ pageScrollView: GKPageScrollView, initListAtIndex index: Int) -> any GKPageListViewDelegate {
        GKBaseListViewController(listType: GKBaseListType(rawValue: index) ?? .UITableView)
    }
    
    func pageScrollViewListDidAppear(_ pageScrollView: GKPageScrollView, at index: Int) {
        segmentedView.scrollSelect(with: index)
    }
}

extension GKCustomViewController: GKCustomSegmentedViewDelegate {
    func didClickSelect(at index: Int) {
        pageScrollView.selectList(with: index, animated: true)
    }
}
