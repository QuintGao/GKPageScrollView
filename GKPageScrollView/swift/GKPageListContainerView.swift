//
//  GKPageListContainerView.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/3/13.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit

@objc public protocol GKPageListContainerViewDelegate: NSObjectProtocol {
    func numberOfRows(in listContainerView: GKPageListContainerView) -> Int
    
    func listContainerView(_ listContainerView: GKPageListContainerView, viewForListInRow row: Int) -> UIView
}

open class GKPageListContainerView: UIView {
    open var collectionView: UICollectionView!
    open weak var delegate: GKPageListContainerViewDelegate?
    weak var mainTableView: GKPageTableView?
    
    public init(delegate: GKPageListContainerViewDelegate) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        self.initSubviews()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.isPagingEnabled = true
        self.collectionView.scrollsToTop = false
        self.collectionView.bounces = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        if #available(iOS 10.0, *) {
            self.collectionView.isPrefetchingEnabled = false
        }
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        }
        self.addSubview(self.collectionView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
    }
    
    open func reloadData() {
        self.collectionView.reloadData()
    }
}

extension GKPageListContainerView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.delegate!.numberOfRows(in: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        let listView = self.delegate!.listContainerView(self, viewForListInRow: indexPath.item)
        listView.frame = cell.bounds
        cell.contentView.addSubview(listView)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.mainTableView?.isScrollEnabled = true
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.mainTableView?.isScrollEnabled = true
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.mainTableView?.isScrollEnabled = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking || scrollView.isDecelerating {
            self.mainTableView?.isScrollEnabled = false
        }
    }
}

extension GKPageListContainerView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.bounds.size
    }
}
