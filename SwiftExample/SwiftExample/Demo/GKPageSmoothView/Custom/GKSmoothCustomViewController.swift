//
//  GKSmoothCustomViewController.swift
//  SwiftExample
//
//  Created by QuintGao on 2025/3/18.
//

import UIKit
import GKPageSmoothView

class GKSmoothCustomViewController: GKDemoBaseViewController {

    lazy var smoothView: GKPageSmoothView = {
        let smoothView = GKPageSmoothView(dataSource: self)
        smoothView.delegate = self;
        smoothView.ceilPointHeight = kNavBar_Height
        smoothView.listCollectionView.gk_openGestureHandle = true
        return smoothView
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
        
        view.addSubview(smoothView)
        smoothView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1) {
            self.smoothView.reloadData()
        }
    }
}

extension GKSmoothCustomViewController: GKPageSmoothViewDataSource, GKPageSmoothViewDelegate {
    func headerView(in smoothView: GKPageSmoothView) -> UIView {
        headerView
    }
    
    func segmentedView(in smoothView: GKPageSmoothView) -> UIView {
        segmentedView
    }
    
    func numberOfLists(in smoothView: GKPageSmoothView) -> Int {
        3
    }
    
    func smoothView(_ smoothView: GKPageSmoothView, initListAtIndex index: Int) -> any GKPageSmoothListViewDelegate {
        GKBaseListViewController(listType: GKBaseListType(rawValue: index) ?? .UITableView)
    }
    
    func smoothViewListDidAppear(_ smoothView: GKPageSmoothView, at index: Int) {
        segmentedView.scrollSelect(with: index)
    }
}

extension GKSmoothCustomViewController: GKCustomSegmentedViewDelegate {
    func didClickSelect(at index: Int) {
        smoothView.selectList(with: index, animated: true)
    }
}
