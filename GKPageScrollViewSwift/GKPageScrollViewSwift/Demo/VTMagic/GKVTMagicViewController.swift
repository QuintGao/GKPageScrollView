//
//  GKVTMagicViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/10/18.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import VTMagic

class GKVTMagicController: VTMagicController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.magicView.navigationColor = UIColor.white
        self.magicView.sliderColor = UIColor.red
        self.magicView.layoutStyle = .divide
        self.magicView.switchStyle = .default
        self.magicView.navigationHeight = 40.0
    }
}

class GKVTMagicViewController: GKDemoBaseViewController {

    lazy var pageScrollView: GKPageScrollView! = {
        let pageScrollView = GKPageScrollView(delegate: self)
        pageScrollView.mainTableView.gestureDelegate = self
        return pageScrollView
    }()
    
    lazy var headerView: UIView! = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 200.0))
        headerView.backgroundColor = UIColor(patternImage: UIImage(named: "test")!)
        return headerView
    }()
    
    lazy var magicVC: VTMagicController = {
        let magicVC = VTMagicController()
        magicVC.magicView.navigationColor = UIColor.white
        magicVC.magicView.sliderColor = UIColor.red
        magicVC.magicView.layoutStyle = .divide
        magicVC.magicView.switchStyle = .default
        magicVC.magicView.navigationHeight = 40.0
        magicVC.magicView.dataSource = self
        magicVC.magicView.delegate = self
        return magicVC
    }()
    
    lazy var pageView: UIView! = {
        let pageView = self.magicVC.view
        return pageView
    }()
    
    let titles = ["详情", "热门", "相关", "聊天"]
    lazy var childVCs: [GKBaseListViewController] = {
        var childVCs = [GKBaseListViewController]()
        
        let detailVC = GKBaseListViewController()
        detailVC.shouldLoadData = false
        childVCs.append(detailVC)
        
        let hotVC = GKBaseListViewController()
        hotVC.shouldLoadData = false
        childVCs.append(hotVC)
        
        let aboutVC = GKBaseListViewController()
        aboutVC.shouldLoadData = false
        childVCs.append(aboutVC)
        
        let chatVC = GKBaseListViewController()
        chatVC.shouldLoadData = false
        childVCs.append(chatVC)
        
        return childVCs
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navBarAlpha = 0
        self.gk_navTitle = "VTMagic使用"
        self.gk_statusBarStyle = .lightContent
        self.gk_navTitleColor = UIColor.white
        
        self.view.addSubview(self.pageScrollView)
        
        self.pageScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        self.pageScrollView.reloadData()
        self.magicVC.magicView.reloadData()
    }
}

extension GKVTMagicViewController: GKPageScrollViewDelegate {
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.headerView
    }
    
    func pageView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.pageView
    }
    
    func listView(in pageScrollView: GKPageScrollView) -> [GKPageListViewDelegate] {
        return self.childVCs
    }
}

extension GKVTMagicViewController: VTMagicViewDataSource, VTMagicViewDelegate {
    func menuTitles(for magicView: VTMagicView) -> [String] {
        return self.titles
    }
    
    func magicView(_ magicView: VTMagicView, menuItemAt itemIndex: UInt) -> UIButton {
        let identifier = "itemIdentifier"
        var menuItem = magicView.dequeueReusableItem(withIdentifier: identifier)
        if menuItem == nil {
            menuItem = UIButton(type: .custom)
            menuItem?.setTitleColor(UIColor.gray, for: .normal)
            menuItem?.setTitleColor(UIColor.black, for: .selected)
            menuItem?.titleLabel?.font = UIFont(name: "Helvetica", size: 15.0)
        }
        return menuItem!
    }
    
    func magicView(_ magicView: VTMagicView, viewControllerAtPage pageIndex: UInt) -> UIViewController {
        return self.childVCs[Int(pageIndex)]
    }
}

extension GKVTMagicViewController: GKPageTableViewGestureDelegate {
    func pageTableView(_ tableView: GKPageTableView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let scrollView: UIScrollView = self.magicVC.magicView.value(forKey: "contentView") as! UIScrollView
        
        if otherGestureRecognizer == scrollView.panGestureRecognizer {
            return false
        }
        
        return gestureRecognizer.view?.isKind(of: UIScrollView.classForCoder()) ?? false && otherGestureRecognizer.view?.isKind(of: UIScrollView.classForCoder()) ?? false
    }
}
