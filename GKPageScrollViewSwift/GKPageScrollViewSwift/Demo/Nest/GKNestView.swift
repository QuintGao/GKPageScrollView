//
//  GKNestView.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/10/18.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import JXSegmentedView

protocol GKNestViewDelegate: AnyObject {
    func nestViewWillScroll()
    func nestViewEndScroll()
}

class GKNestView: UIView {
    public weak var delegate: GKNestViewDelegate?
    
    var titleDataSource = JXSegmentedTitleDataSource()
    
    var listScrollCallBack: ((UIScrollView) -> ())?
    
    var currentListScrollView: UIScrollView = UIScrollView()
    
    lazy var segmentedView: JXSegmentedView = {
        titleDataSource.titleNormalColor = UIColor.gray
        titleDataSource.titleSelectedColor = UIColor.gray
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 14.0)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 14.0)
        titleDataSource.titles = ["综合", "销量", "价格"]
        
        var segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kBaseSegmentHeight))
        segmentedView.delegate = self
        segmentedView.dataSource = titleDataSource
        segmentedView.backgroundColor = UIColor.white
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .lengthen
        segmentedView.indicators = [lineView]
        
        segmentedView.contentScrollView = self.contentScrollView
        
        return segmentedView
    }()
    
    lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        
        scrollView.addSubview(self.compListView)
        scrollView.addSubview(self.saleListView)
        scrollView.addSubview(self.priceListView)
        
        return scrollView
    }()
    
    lazy var compListView: GKNestListView = {
        let complistView = GKNestListView()
        complistView.scrollCallBack = { [weak self] (scrollView: UIScrollView) -> () in
            self?.listScrollCallBack!(scrollView)
        }
        return complistView
    }()
    
    lazy var saleListView: GKNestListView = {
        let saleListView = GKNestListView()
        saleListView.scrollCallBack = { [weak self] (scrollView: UIScrollView) -> () in
            self?.listScrollCallBack!(scrollView)
        }
        return saleListView
    }()
    
    lazy var priceListView: GKNestListView = {
        let priceListView = GKNestListView()
        priceListView.scrollCallBack = { [weak self] (scrollView: UIScrollView) -> () in
            self?.listScrollCallBack!(scrollView)
        }
        return priceListView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.segmentedView)
        self.addSubview(self.contentScrollView)
        
        self.segmentedView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(40.0)
        }
        
        self.contentScrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.top.equalTo(self.segmentedView.snp_bottom)
        }
        
        self.currentListScrollView = self.compListView.tableView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let listW = self.contentScrollView.frame.size.width
        let listH = self.contentScrollView.frame.size.height
        
        self.compListView.frame = CGRect(x: 0, y: 0, width: listW, height: listH)
        self.saleListView.frame = CGRect(x: listW, y: 0, width: listW, height: listH)
        self.priceListView.frame = CGRect(x: 2 * listW, y: 0, width: listW, height: listH)
        
        self.contentScrollView.contentSize = CGSize(width: 3 * listW, height: 0)
    }
}

extension GKNestView: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        switch index {
        case 0:
            self.currentListScrollView = self.compListView.tableView
            break
        case 1:
            self.currentListScrollView = self.saleListView.tableView
            break
        case 2:
            self.currentListScrollView = self.priceListView.tableView
            break
        default:
            break
        }
    }
}

extension GKNestView: GKPageListViewDelegate {
    func listView() -> UIView {
        return self
    }
    
    func listScrollView() -> UIScrollView {
        return self.currentListScrollView
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        listScrollCallBack = callBack
    }
}

extension GKNestView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.delegate?.nestViewWillScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.delegate?.nestViewEndScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.nestViewEndScroll()
    }
}
