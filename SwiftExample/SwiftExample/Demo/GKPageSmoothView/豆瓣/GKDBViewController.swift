//
//  GKDBViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2020/12/23.
//  Copyright © 2020 gaokun. All rights reserved.
//

import UIKit
import JXSegmentedView
import GKNavigationBarSwift
import GKPageSmoothView

class GKDBViewController: GKDemoBaseViewController {

    lazy var titleView: UIView = {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 100, height: 44.0))
        
        let image = UIImage(named: "db_title")
        let imgView = UIImageView(image: image)
        imgView.frame = CGRect(x: 0, y: 0, width: 44.0 * image!.size.width / image!.size.height, height: 44.0)
        titleView.addSubview(imgView)
        return titleView
    }()
    
    lazy var smoothView: GKPageSmoothView = {
        let smoothView = GKPageSmoothView(dataSource: self)
        smoothView.delegate = self
        smoothView.ceilPointHeight = GK_STATUSBAR_NAVBAR_HEIGHT
        smoothView.isBottomHover = true
        smoothView.isAllowDragBottom = true
        smoothView.isAllowDragScroll = true
        smoothView.listCollectionView.gk_openGestureHandle = true
        return smoothView
    }()
    
    lazy var headerView: UIImageView = {
        let image = UIImage(named: "douban")
        let imgView = UIImageView(image: image)
        imgView.frame = CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height)
        return imgView
    }()
    
    lazy var segmentedView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 60))
        view.backgroundColor = .white
        view.addSubview(self.titleSegmentedView)
        
        let topView = UIView()
        topView.backgroundColor = .lightGray
        topView.layer.cornerRadius = 3.0
        topView.layer.masksToBounds = true
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(5)
            make.centerX.equalTo(view)
            make.width.equalTo(60)
            make.height.equalTo(6)
        }
        return view
    }()
    
    var dataSource = JXSegmentedNumberDataSource()
    
    lazy var titleSegmentedView: JXSegmentedView = {
        dataSource.titles = ["影评", "讨论"]
        dataSource.numbers = [342, 200]
        dataSource.isItemSpacingAverageEnabled = false
        dataSource.numberBackgroundColor = UIColor.clear
        dataSource.numberTextColor = UIColor.gray
        dataSource.numberFont = UIFont.systemFont(ofSize: 11)
        dataSource.numberOffset = CGPoint(x: 10, y: 6)
        dataSource.titleNormalFont = UIFont.systemFont(ofSize: 16)
        dataSource.titleNormalColor = UIColor.gray
        dataSource.titleSelectedColor = UIColor.black
        dataSource.itemSpacing = 50
        
        var segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 10, width: kScreenW, height: 40))
        segmentedView.delegate = self
        segmentedView.dataSource = dataSource
        segmentedView.contentEdgeInsetLeft = 16
        segmentedView.backgroundColor = .white
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .normal
        lineView.indicatorColor = .black
        segmentedView.indicators = [lineView]
        return segmentedView
    }()
    
    var isTitleViewShow = false
    var originAlpha: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gk_statusBarStyle = .lightContent
        self.gk_navBarAlpha = 0
        self.gk_navBackgroundColor = UIColor(red: 123.0 / 255.0, green: 106.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
        self.gk_navTitle = "电影"
        self.gk_navTitleColor = .white
        
        self.view.addSubview(self.smoothView)
        self.smoothView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.titleSegmentedView.contentScrollView = self.smoothView.listCollectionView
        self.smoothView.reloadData()
    }
    
    func changeTitle(isShow: Bool) {
        if isShow {
            if (self.gk_navTitle == nil) {return}
            self.gk_navTitle = nil
            self.gk_navTitleView = self.titleView
        }else {
            if (self.gk_navTitleView == nil) {return}
            self.gk_navTitle = "电影"
            self.gk_navTitleView = nil
        }
    }
    
    func attributedTextFrom(title: String, count: NSNumber, isSelected: Bool) -> NSAttributedString {
        let countString = String(format: "%@", count)
        let allString = String(format: "%@%@", title, countString)
        
        var tintColor: UIColor = .gray
        if isSelected {
            tintColor = .black
        }
        
        let attributedText = NSMutableAttributedString(string: allString, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: tintColor])
        let titleRange = (title as NSString).range(of: title)
        let countRange = (allString as NSString).range(of: countString)
        attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: countRange)
        attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: countRange)
        
        let fontRatio: CGFloat = 0.96
        
        attributedText.addAttribute(.baselineOffset, value: 0, range: titleRange)
        attributedText.addAttribute(.baselineOffset, value: fontRatio * (16 - 12), range: countRange)
        return attributedText
    }
}

extension GKDBViewController: GKPageSmoothViewDataSource {
    func headerView(in smoothView: GKPageSmoothView) -> UIView {
        return self.headerView
    }
    
    func segmentedView(in smoothView: GKPageSmoothView) -> UIView {
        return self.segmentedView
    }
    
    func numberOfLists(in smoothView: GKPageSmoothView) -> Int {
        return dataSource.titles.count
    }
    
    func smoothView(_ smoothView: GKPageSmoothView, initListAtIndex index: Int) -> GKPageSmoothListViewDelegate {
        return GKDBListView()
    }
}

extension GKDBViewController: GKPageSmoothViewDelegate {
    func smoothViewListScrollViewDidScroll(_ smoothView: GKPageSmoothView, scrollView: UIScrollView, contentOffset: CGPoint) {
        if (smoothView.isOnTop) { return }
        // 导航栏显隐
        let offsetY = contentOffset.y
        var alpha: CGFloat = 0
        if offsetY <= 0 {
            alpha = 0
        }else if offsetY > 60 {
            alpha = 1
            changeTitle(isShow: true)
        }else {
            alpha = offsetY / 60.0
            changeTitle(isShow: false)
        }
        self.gk_navBarAlpha = alpha
    }
    
    func smoothViewDragBegan(_ smoothView: GKPageSmoothView) {
        if smoothView.isOnTop {return}
        self.isTitleViewShow = (self.gk_navTitleView != nil)
        self.originAlpha = self.gk_navBarAlpha
    }
    
    func smoothViewDragEnded(_ smoothView: GKPageSmoothView, isOnTop: Bool) {
        // titleView已经显示，不作处理
        if self.isTitleViewShow {return}
        if isOnTop {
            self.gk_navBarAlpha = 1.0
            changeTitle(isShow: true)
        }else {
            self.gk_navBarAlpha = 0.0
            changeTitle(isShow: false)
        }
    }
}

extension GKDBViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        self.smoothView.showingOnTop()
    }
}
