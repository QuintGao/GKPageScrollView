//
//  GKPageSmoothView.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2020/5/10.
//  Copyright © 2020 gaokun. All rights reserved.
//

import UIKit

@objc public protocol GKPageSmoothListViewDelegate : NSObjectProtocol {
    
    /// 返回listView，如果是vc就返回vc.view,如果是自定义view，就返回view本身
    func listView() -> UIView
    
    /// 返回vc或view内部持有的UIScrollView或UITableView或UICollectionView
    func listScrollView() -> UIScrollView
    
    @objc optional func listViewDidAppear()
    @objc optional func listViewDidDisappear()
}

@objc public protocol GKPageSmoothViewDelegate : NSObjectProtocol {
    
    /// 返回页面header视图
    /// - Parameter smoothView: smoothView description
    func headerView(in smoothView: GKPageSmoothView) -> UIView
    
    /// 返回页面分段视图
    /// - Parameter smoothView: smoothView description
    func segmentedView(in smoothView: GKPageSmoothView) -> UIView
    
    /// 返回个数列表
    /// - Parameter smoothView: smoothView description
    func numberOfLists(in smoothView: GKPageSmoothView) -> Int
    
    /// 根据index初始化一个列表实例，需实现`GKPageSmoothListViewDelegate`代理
    /// - Parameters:
    ///   - smoothView: smoothView description
    ///   - index: 对应的索引
    func smoothView(_ smoothView: GKPageSmoothView, initListAtIndex index: Int) -> GKPageSmoothListViewDelegate
    
    /// containerView滑动代理
    /// - Parameters:
    ///   - smoothView: smoothView description
    ///   - scrollView: containerScrollView
    @objc optional func smoothViewDidScroll(_ smoothView: GKPageSmoothView, scrollView: UIScrollView)
}

public class GKPageSmoothCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    var headerContainerView: UIView?
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: headerContainerView)
        if headerContainerView?.bounds.contains(point) == true {
            return false
        }
        return true
    }
}

let GKPageSmoothViewCellID = "smoothViewCell"

open class GKPageSmoothView: UIView {
    public private(set) var listDict = [Int: GKPageSmoothListViewDelegate]()
    public let listCollectionView: GKPageSmoothCollectionView
    public var defaultSelectedIndex: Int = 0
    public var ceilPointHeight: CGFloat = GKPage_NavBar_Height
    public var isControlVerticalIndicator: Bool = false
    
    weak var delegate: GKPageSmoothViewDelegate?
    var listHeaderDict = [Int: UIView]()
    let headerContainerView: UIView
    var currentListScrollView: UIScrollView?
    var isSyncListContentOffsetEnabled: Bool = false
    var currentHeaderContainerViewY: CGFloat = 0
    
    var headerContainerHeight: CGFloat = 0
    var headerHeight: CGFloat = 0
    var segmentedHeight: CGFloat = 0
    var currentListInitailzeContentOffsetY: CGFloat = 0
    
    var currentIndex: Int = 0
    var isLoaded: Bool = false
    var isRefreshHeader: Bool = false

    deinit {
        listDict.values.forEach {
            $0.listScrollView().removeObserver(self, forKeyPath: "contentOffset")
            $0.listScrollView().removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    public init(delegate: GKPageSmoothViewDelegate) {
        self.delegate = delegate
        
        headerContainerView = UIView()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        listCollectionView = GKPageSmoothCollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        listCollectionView.isPagingEnabled = true
        listCollectionView.bounces = false
        listCollectionView.showsHorizontalScrollIndicator = false
        listCollectionView.scrollsToTop = false
        listCollectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: GKPageSmoothViewCellID)
        if #available(iOS 10.0, *) {
            listCollectionView.isPrefetchingEnabled = false
        }
        if #available(iOS 11.0, *) {
            listCollectionView.contentInsetAdjustmentBehavior = .never
        }
        listCollectionView.headerContainerView = headerContainerView
        self.addSubview(listCollectionView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshHeaderView() {
        isRefreshHeader = true
        reloadData()
    }
    
    public func reloadData() {
        guard let delegate = delegate else { return }
        currentListScrollView = nil
        if isRefreshHeader {
            isRefreshHeader = false
        }else {
            currentIndex = defaultSelectedIndex
        }
        currentHeaderContainerViewY = 0
        isSyncListContentOffsetEnabled = false
        isLoaded = true
        
        listHeaderDict.removeAll()
        listDict.values.forEach {
            $0.listScrollView().removeObserver(self, forKeyPath: "contentOffset")
            $0.listScrollView().removeObserver(self, forKeyPath: "contentSize")
            $0.listView().removeFromSuperview()
        }
        listDict.removeAll()
        
        let headerView = delegate.headerView(in: self)
        let segmentedView = delegate.segmentedView(in: self)
        headerContainerView.addSubview(headerView)
        headerContainerView.addSubview(segmentedView)
        
        headerHeight = headerView.bounds.size.height
        segmentedHeight = segmentedView.bounds.size.height
        headerContainerHeight = headerHeight + segmentedHeight
        
        var width: CGFloat = bounds.size.width
        if width == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                width = self.bounds.size.width
                
                self.headerContainerView.frame = CGRect(x: 0, y: 0, width: width, height: self.headerContainerHeight)
                headerView.frame = CGRect(x: 0, y: 0, width: width, height: self.headerHeight)
                segmentedView.frame = CGRect(x: 0, y: self.headerHeight, width: width, height: self.segmentedHeight)
                self.listCollectionView.setContentOffset(CGPoint(x: width * CGFloat(self.currentIndex), y: 0), animated: false)
                self.listCollectionView.reloadData()
            }
        }else {
            self.headerContainerView.frame = CGRect(x: 0, y: 0, width: width, height: self.headerContainerHeight)
            headerView.frame = CGRect(x: 0, y: 0, width: width, height: self.headerHeight)
            segmentedView.frame = CGRect(x: 0, y: self.headerHeight, width: width, height: self.segmentedHeight)
            self.listCollectionView.setContentOffset(CGPoint(x: width * CGFloat(self.currentIndex), y: 0), animated: false)
            self.listCollectionView.reloadData()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        listCollectionView.frame = bounds
//        if headerContainerView.frame == .zero {
//            reloadData()
//        }
    }
    
    // MARK: - KVO
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let scrollView = object as? UIScrollView {
                listDidScroll(scrollView: scrollView)
            }
        }else if keyPath == "contentSize" {
            if let scrollView = object as? UIScrollView {
                let minContentSizeHeight = bounds.size.height - (self.headerHeight - self.ceilPointHeight)
                if minContentSizeHeight > scrollView.contentSize.height {
                    scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: minContentSizeHeight)
                    scrollView.contentOffset = CGPoint(x: 0, y: self.currentHeaderContainerViewY)
                }
            }
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Private Methods
    func listDidScroll(scrollView: UIScrollView) {
        if listCollectionView.isDragging || listCollectionView.isDecelerating {
            return
        }
        let index = listIndex(for: scrollView)
        if index != currentIndex {
            return
        }
        currentListScrollView = scrollView
        let contentOffsetY = scrollView.contentOffset.y + headerContainerHeight
        if contentOffsetY < (headerHeight - ceilPointHeight) {
            isSyncListContentOffsetEnabled = true
            currentHeaderContainerViewY = -contentOffsetY
            for list in listDict.values {
                if list.listScrollView() != scrollView {
                    list.listScrollView().setContentOffset(scrollView.contentOffset, animated: false)
                }
            }
            let header = listHeader(for: scrollView)
            if headerContainerView.superview != header {
                headerContainerView.frame.origin.y = 0
                header?.addSubview(headerContainerView)
            }
            
            if isControlVerticalIndicator && ceilPointHeight != 0 {
                currentListScrollView?.showsVerticalScrollIndicator = false
            }
        }else {
            if headerContainerView.superview != self {
                headerContainerView.frame.origin.y = -(headerHeight - ceilPointHeight)
                addSubview(headerContainerView)
            }
            
            if isControlVerticalIndicator {
                currentListScrollView?.showsVerticalScrollIndicator = true
            }
            
            if isSyncListContentOffsetEnabled {
                isSyncListContentOffsetEnabled = false
                currentHeaderContainerViewY = -(headerHeight - ceilPointHeight)
                for list in listDict.values {
                    if list.listScrollView() != currentListScrollView {
                        list.listScrollView().setContentOffset(CGPoint(x: 0, y: -(segmentedHeight + ceilPointHeight)), animated: false)
                    }
                }
            }
        }
    }
    
    func horizontalScrollDidEnd(at index: Int) {
        currentIndex = index
        guard let listHeader = listHeaderDict[index], let listScrollView = listDict[index]?.listScrollView() else { return }
        listDict.values.forEach {
            $0.listScrollView().scrollsToTop = ($0.listScrollView() == listScrollView)
        }
        if listScrollView.contentOffset.y <= -(segmentedHeight + ceilPointHeight) {
            headerContainerView.frame.origin.y = 0
            listHeader.addSubview(headerContainerView)
        }
    }
    
    func listHeader(for listScrollView: UIScrollView) -> UIView? {
        for (index, list) in listDict {
            if list.listScrollView() == listScrollView {
                return listHeaderDict[index]
            }
        }
        return nil
    }
    
    func listIndex(for listScrollView: UIScrollView) -> Int {
        for (index, list) in listDict {
            if list.listScrollView() == listScrollView {
                return index
            }
        }
        return 0
    }
    
    func listDidAppear(at index: Int) {
        guard let delegate = delegate else { return }
        let count = delegate.numberOfLists(in: self)
        if count <= 0 || index >= count {
            return
        }
        listDict[index]?.listViewDidAppear?()
    }
    
    func listDidDisappear(at index: Int) {
        guard let delegate = delegate else { return }
        let count = delegate.numberOfLists(in: self)
        if count <= 0 || index >= count {
            return
        }
        listDict[index]?.listViewDidDisappear?()
    }
}

extension GKPageSmoothView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let delegate = delegate else { return 0 }
        
        let count = delegate.numberOfLists(in: self)
        
        return self.isLoaded ? count : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate = delegate else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GKPageSmoothViewCellID, for: indexPath)
        var list = listDict[indexPath.item]
        if list == nil {
            list = delegate.smoothView(self, initListAtIndex: indexPath.item)
            listDict[indexPath.item] = list!
            list?.listView().setNeedsLayout()
            list?.listView().layoutIfNeeded()
            if list?.listScrollView().isKind(of: UITableView.self) == true {
                (list?.listScrollView() as? UITableView)?.estimatedRowHeight = 0
                (list?.listScrollView() as? UITableView)?.estimatedSectionHeaderHeight = 0
                (list?.listScrollView() as? UITableView)?.estimatedSectionFooterHeight = 0
            }
            if #available(iOS 11.0, *) {
                list?.listScrollView().contentInsetAdjustmentBehavior = .never
            }
            list?.listScrollView().contentInset = UIEdgeInsets(top: headerContainerHeight, left: 0, bottom: 0, right: 0)
            currentListInitailzeContentOffsetY = -headerContainerHeight + min(-currentHeaderContainerViewY, (headerHeight - ceilPointHeight))
            list?.listScrollView().contentOffset = CGPoint(x: 0, y: currentListInitailzeContentOffsetY)
            let listHeader = UIView(frame: CGRect(x: 0, y: -headerContainerHeight, width: bounds.size.width, height: headerContainerHeight))
            list?.listScrollView().addSubview(listHeader)
            if headerContainerView.superview == nil {
                listHeader.addSubview(headerContainerView)
            }
            listHeaderDict[indexPath.item] = listHeader
            list?.listScrollView().addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            list?.listScrollView().addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        }
        listDict.values.forEach {
            $0.listScrollView().scrollsToTop = ($0 === list)
        }
        if let listView = list?.listView(), listView.superview != cell.contentView {
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            listView.frame = cell.contentView.bounds
            cell.contentView.addSubview(listView)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listDidAppear(at: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listDidDisappear(at: indexPath.item)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.smoothViewDidScroll?(self, scrollView: scrollView)
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
        let ratio = Int(scrollView.contentOffset.x)%Int(scrollView.bounds.size.width)
        
        let listScrollView = self.listDict[index]?.listScrollView()
        if index != currentIndex && ratio == 0 && !(scrollView.isDragging || scrollView.isDecelerating) && listScrollView?.contentOffset.y ?? 0 <= -(segmentedHeight + ceilPointHeight) {
            horizontalScrollDidEnd(at: index)
        }else {
            if headerContainerView.superview != self {
                headerContainerView.frame.origin.y = currentHeaderContainerViewY
                addSubview(headerContainerView)
            }
        }
        if currentIndex != index {
            currentIndex = index
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
            horizontalScrollDidEnd(at: index)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        horizontalScrollDidEnd(at: index)
    }
}
