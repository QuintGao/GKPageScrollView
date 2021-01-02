//
//  GKWBViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import WMPageController
import GKNavigationBarSwift
import GKPageScrollView

class GKWBViewController: GKDemoBaseViewController {

    lazy var titleLabel: UILabel! = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.text = "广文博见V"
        titleLabel.alpha = 0
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    lazy var titleView: UIView = {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 44))
        titleView.backgroundColor = UIColor.clear
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints({ (make) in
            make.edges.equalTo(titleView)
        })
        return titleView
    }()
    
    let titles = ["主页", "微博", "视频", "故事"]
    
    lazy var childVCs: [GKWBListViewController] = {
        var childVCs = [GKWBListViewController]()
        let homeVC  = GKWBListViewController()
        let wbVC    = GKWBListViewController()
        let videoVC = GKWBListViewController()
        let storyVC = GKWBListViewController()
        
        childVCs.append(homeVC)
        childVCs.append(wbVC)
        childVCs.append(videoVC)
        childVCs.append(storyVC)
        
        return childVCs
    }()
    
    lazy var headerView: GKWBHeaderView! = {
        return GKWBHeaderView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kWBHeaderHeight))
    }()
    
    lazy var pageView: UIView! = {
        self.addChild(self.pageVC)
        self.pageVC.didMove(toParent: self)
        return self.pageVC.view
    }()
    
    lazy var pageVC: GKWBPageViewController! = {
        let pageVC = GKWBPageViewController()
        pageVC.dataSource = self
        pageVC.delegate = self
        
        // 菜单属性
        pageVC.menuItemWidth = kScreenW / 4.0 - 20
        pageVC.menuViewStyle = .line
        
        pageVC.titleSizeNormal = 16.0
        pageVC.titleSizeSelected = 16.0
        pageVC.titleColorNormal = UIColor.gray
        pageVC.titleColorSelected = UIColor.black
        
        // 进度条属性
        pageVC.progressColor = UIColor.red
        pageVC.progressWidth = 30.0
        pageVC.progressHeight = 3.0
        pageVC.progressViewBottomSpace = 2.0
        pageVC.progressViewCornerRadius = pageVC.progressHeight / 2
        
        // 调皮效果
        pageVC.progressViewIsNaughty = true
        return pageVC
    }()
    
    lazy var pageScrollView: GKPageScrollView! = {
        let pageScrollView = GKPageScrollView(delegate: self)
        pageScrollView.mainTableView.backgroundColor = UIColor.gray
        pageScrollView.isControlVerticalIndicator = true
        return pageScrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gk_navBarAlpha = 0.0
        self.gk_statusBarStyle = .lightContent
        self.gk_navTitleView = titleView
        self.gk_navRightBarButtonItem = UIBarButtonItem.gk_item(image: UIImage(named: "wb_more")!, target: self, action: #selector(moreAction))
        
        self.view.addSubview(self.pageScrollView)
        self.pageScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        self.pageScrollView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.headerView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: kWBHeaderHeight);
        
        if (kScreenH > kScreenW) {
            self.pageScrollView.ceilPointHeight = GK_STATUSBAR_NAVBAR_HEIGHT;
        }else {
            self.pageScrollView.ceilPointHeight = 44.0
        }
        
        self.pageVC.reloadData()
        self.pageVC.scrollView?.gk_openGestureHandle = true
        
        if let scrollView = self.pageVC.scrollView {
            self.pageScrollView.horizontalScrollViewList = [scrollView]
        }
    }
    
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func moreAction() {
        
    }
}

extension GKWBViewController: GKPageScrollViewDelegate {
    func headerView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.headerView
    }
    
    func pageView(in pageScrollView: GKPageScrollView) -> UIView {
        return self.pageView
    }
    
    func listView(in pageScrollView: GKPageScrollView) -> [GKPageListViewDelegate] {
        return self.childVCs
    }
    
    func mainTableViewDidScroll(_ scrollView: UIScrollView, isMainCanScroll: Bool) {
        let offsetY = scrollView.contentOffset.y
        // 偏移量 < 60 0
        // 偏移量 60 - 100 导航栏0-1渐变
        // 偏移量 > 100 1
        var alpha: CGFloat = 0
        if offsetY <= 60.0 {
            alpha = 0
            
            self.titleLabel.alpha = 0
            self.gk_statusBarStyle = .lightContent
            self.gk_navLeftBarButtonItem = UIBarButtonItem.gk_item(image: UIImage(named: "btn_back_white")!, target: self, action: #selector(backAction))
            self.gk_navRightBarButtonItem = UIBarButtonItem.gk_item(image: UIImage(named: "wb_more")!, target: self, action: #selector(moreAction))
        }else if offsetY >= 100.0 {
            alpha = 1.0
            self.gk_statusBarStyle = .default
            self.gk_navLeftBarButtonItem = UIBarButtonItem.gk_item(image: UIImage(named: "btn_back_black")!, target: self, action: #selector(backAction))
            self.gk_navRightBarButtonItem = UIBarButtonItem.gk_item(image: UIImage.gk_change(with: UIImage(named: "wb_more")!, color: .black), target: self, action: #selector(moreAction))
            self.titleLabel.alpha = 1
        }else {
            alpha = (offsetY - 60) / (100 - 60)
            
            if alpha > 0.8 {
                self.gk_statusBarStyle = .default
                self.gk_navLeftBarButtonItem = UIBarButtonItem.gk_item(image: UIImage(named: "btn_back_black")!, target: self, action: #selector(backAction))
                self.gk_navRightBarButtonItem = UIBarButtonItem.gk_item(image: UIImage.gk_change(with: UIImage(named: "wb_more")!, color: .black), target: self, action: #selector(moreAction))
                self.titleLabel.alpha = (offsetY - 92) / (100 - 92)
            }else {
                self.titleLabel.alpha = 0
                self.gk_statusBarStyle = .lightContent
                self.gk_navLeftBarButtonItem = UIBarButtonItem.gk_item(image: UIImage(named: "btn_back_black")!, target: self, action: #selector(backAction))
                self.gk_navRightBarButtonItem = UIBarButtonItem.gk_item(image: UIImage(named: "wb_more")!, target: self, action: #selector(moreAction))
            }
        }
        self.gk_navBarAlpha = alpha
        
        // 头图下拉
        self.headerView.scrollViewDidScroll(offsetY: scrollView.contentOffset.y)
    }
}

extension GKWBViewController: WMPageControllerDataSource, WMPageControllerDelegate {
    func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return self.childVCs.count
    }
    
    func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        return self.titles[index]
    }
    
    func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        return self.childVCs[index]
    }
    
    func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        guard let menuView = pageController.menuView ?? nil else {
            return .zero
        }
        
        let maxY = self.pageController(pageController, preferredFrameFor: menuView).maxY
        return CGRect(x: 0, y: maxY, width: kScreenW, height: kScreenH - maxY - kNavBar_Height)
    }
    
    func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        return CGRect(x: 0, y: 0, width: kScreenW, height: 40.0)
    }
    
    func pageController(_ pageController: WMPageController, didEnter viewController: UIViewController, withInfo info: [AnyHashable : Any]) {
        print("加载数据")
    }
}
