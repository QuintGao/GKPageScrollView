//
//  GKPageSmoothView.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2020/5/10.
//  Copyright © 2020 gaokun. All rights reserved.
//

import UIKit

public enum GKPageSmoothHoverType {
    case none       // 未悬停
    case top        // 顶部悬停
    case bottom     // 底部悬停
}

@objc public protocol GKPageSmoothListViewDelegate : NSObjectProtocol {
    
    /// 返回listView，如果是vc就返回vc.view,如果是自定义view，就返回view本身
    func listView() -> UIView
    
    /// 返回vc或view内部持有的UIScrollView或UITableView或UICollectionView
    func listScrollView() -> UIScrollView
    
    @objc optional func listViewDidAppear()
    @objc optional func listViewDidDisappear()
}

@objc public protocol GKPageSmoothViewDataSource : NSObjectProtocol {
    /// 返回页面header视图
    /// - Parameter smoothView: smoothView
    func headerView(in smoothView: GKPageSmoothView) -> UIView
    
    /// 返回需要悬浮的分段视图
    /// - Parameter smoothView: smoothView
    func segmentedView(in smoothView: GKPageSmoothView) -> UIView
    
    /// 返回列表个数
    /// - Parameter smoothView: smoothView
    func numberOfLists(in smoothView: GKPageSmoothView) -> Int
    
    /// 根据index初始化一个列表实例，列表需实现`GKPageSmoothListViewDelegate`代理
    /// - Parameters:
    ///   - smoothView: smoothView
    ///   - index: 列表索引
    func smoothView(_ smoothView: GKPageSmoothView, initListAtIndex index: Int) -> GKPageSmoothListViewDelegate
}

@objc public protocol GKPageSmoothViewDelegate : NSObjectProtocol {
    /// 容器列表滑动代理
    /// - Parameters:
    ///   - smoothView: smoothView description
    ///   - scrollView: containerScrollView
    @objc optional func smoothViewDidScroll(_ smoothView: GKPageSmoothView, scrollView: UIScrollView)
    
    /// 当前列表滑动代理
    /// - Parameters:
    ///   - smoothView: smoothView
    ///   - scrollView: 当前的列表scrollView
    ///   - contentOffset: 转换后的contentOffset
    @objc optional func smoothViewListScrollViewDidScroll(_ smoothView: GKPageSmoothView, scrollView: UIScrollView, contentOffset: CGPoint)
    
    /// 开始拖拽代理
    /// - Parameter smoothView: smoothView
    @objc optional func smoothViewDragBegan(_ smoothView: GKPageSmoothView)
    
    /// 结束拖拽代理
    /// - Parameters:
    ///   - smoothView: smoothView
    ///   - isOnTop: 是否通过拖拽滑动到顶部
    @objc optional func smoothViewDragEnded(_ smoothView: GKPageSmoothView, isOnTop: Bool)
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

open class GKPageSmoothView: UIView, UIGestureRecognizerDelegate {
    public private(set) var listDict = [Int: GKPageSmoothListViewDelegate]()
    public let listCollectionView: GKPageSmoothCollectionView
    public var defaultSelectedIndex: Int = 0
    public var ceilPointHeight: CGFloat = 0
    public var isControlVerticalIndicator: Bool = false
    public weak var delegate: GKPageSmoothViewDelegate?
    public var isBottomHover: Bool = false {
        didSet {
            if (isBottomHover) {
                self.refreshWidth { [self] (size) in
                    self.bottomContainerView.frame = CGRect(x: 0, y: size.height - self.segmentedHeight, width: size.width, height: size.height - self.ceilPointHeight)
                    self.addSubview(self.bottomContainerView)
                    
                    if self.headerHeight > size.height {
                        self.segmentedView?.frame = CGRect(x: 0, y: 0, width: size.width, height: self.segmentedHeight)
                        self.bottomContainerView.addSubview(self.segmentedView!)
                    }
                }
            }else {
                self.bottomContainerView.removeFromSuperview()
            }
        }
    }
    public var isAllowDragBottom: Bool = false {
        didSet {
            if self.isBottomHover {
                if isAllowDragBottom == true {
                    self.bottomContainerView.addGestureRecognizer(self.panGesture)
                }else {
                    self.bottomContainerView.removeGestureRecognizer(self.panGesture)
                }
            }
        }
    }
    public var isAllowDragScroll: Bool = false
    public private(set) var hoverType: GKPageSmoothHoverType = .none
    public private(set) var isOnTop: Bool = false
    
    weak var dataSource: GKPageSmoothViewDataSource?
    var listHeaderDict = [Int: UIView]()
    
    lazy var headerContainerView: UIView = { return UIView() }()
    lazy var bottomContainerView: UIView = { return UIView() }()
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(panGesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    var headerView: UIView?
    var segmentedView: UIView?
    
    public private(set) var currentListScrollView: UIScrollView?
    var isSyncListContentOffsetEnabled: Bool = false
    var currentHeaderContainerViewY: CGFloat = 0
    
    public private(set) var headerContainerHeight: CGFloat = 0
    var headerHeight: CGFloat = 0
    var segmentedHeight: CGFloat = 0
    var currentListInitailzeContentOffsetY: CGFloat = 0
    
    var currentIndex: Int = 0
    var isLoaded: Bool = false
    
    var scrollView: UIScrollView?
    var isDragScrollView: Bool = false
    var lastTransitionY: CGFloat = 0
    var currentListPanBeganContentOffsetY: CGFloat = 0
    var originBounces = false
    var originShowsVerticalScrollIndicator = false
    
    public init(dataSource: GKPageSmoothViewDataSource) {
        self.dataSource = dataSource
        
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
        
        self.addSubview(self.headerContainerView)
        self.refreshHeaderView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        listDict.values.forEach {
            $0.listScrollView().removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.listCollectionView.superview == self {
            self.listCollectionView.frame = self.bounds
        }else {
            var frame = self.listCollectionView.frame
            frame.origin.y = self.segmentedHeight
            self.listCollectionView.frame = frame
        }
    }
    
    /// 刷新headerView和segmentedView
    public func refreshHeaderView() {
        self.loadHeaderAndSegmentedView()
        
        self.refreshWidth { [self] (size) in
            var frame = self.headerContainerView.frame;
            if __CGSizeEqualToSize(frame.size, .zero) {
                frame = CGRect(x: 0, y: 0, width: size.width, height: self.headerContainerHeight)
            }else {
                frame.size.height = self.headerContainerHeight
            }
            self.headerContainerView.frame = frame
            
            self.headerView?.frame = CGRect(x: 0, y: 0, width: size.width, height: self.headerHeight)
            self.segmentedView?.frame = CGRect(x: 0, y: self.headerHeight, width: size.width, height: self.segmentedHeight)
            
            self.listDict.values.forEach {
                $0.listScrollView().contentInset = UIEdgeInsets(top: self.headerContainerHeight, left: 0, bottom: 0, right: 0)
            }
            
            if self.isBottomHover {
                self.bottomContainerView.frame = CGRect(x: 0, y: size.height - self.segmentedHeight, width: size.width, height: size.height - self.ceilPointHeight)
                
                if self.headerHeight > size.height {
                    self.segmentedView?.frame = CGRect(x: 0, y: 0, width: size.height, height: self.segmentedHeight)
                    self.bottomContainerView.addSubview(self.segmentedView!)
                }
            }
        }
    }
    
    /// 刷新列表
    public func reloadData() {
        currentListScrollView = nil
        currentIndex = defaultSelectedIndex
        currentHeaderContainerViewY = 0
        isSyncListContentOffsetEnabled = false
        isLoaded = true
        
        listHeaderDict.removeAll()
        listDict.values.forEach {
            $0.listScrollView().removeObserver(self, forKeyPath: "contentOffset")
            $0.listView().removeFromSuperview()
        }
        listDict.removeAll()
        
        self.refreshWidth { [self] (size) in
            self.listCollectionView.setContentOffset(CGPoint(x: size.width * CGFloat(self.currentIndex), y: 0), animated: false)
            self.listCollectionView.reloadData()
        }
    }
    
    /// 滑动到原点
    public func scrollToOriginalPoint() {
        self.currentListScrollView?.setContentOffset(CGPoint(x: 0, y: -self.headerContainerHeight), animated: true)
    }
    
    /// 滑动到悬停点
    public func scrollToCriticalPoint() {
        self.currentListScrollView?.setContentOffset(CGPoint(x: 0, y: -(self.segmentedHeight + self.ceilPointHeight)), animated: true)
    }
    
    /// 显示在顶部，允许底部拖拽时生效
    public func showingOnTop() {
        if (self.bottomContainerView.isHidden) { return }
        self.dragBegan()
        self.dragShowing()
    }
    
    /// 显示在底部，允许底部拖拽时生效
    public func showingOnBottom() {
        if (self.bottomContainerView.isHidden) { return }
        self.dragDismiss()
    }
    
    // MARK: - Gesture
    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began {
            self.delegate?.smoothViewDragBegan?(self)
            self.dragBegan()
            if let scrollView = self.scrollView {
                self.originBounces = scrollView.bounces
                self.originShowsVerticalScrollIndicator = scrollView.showsVerticalScrollIndicator
            }
            
            // bug fix #47，当UIScrollView向下滚动的时候，向下拖拽完成手势操作导致的错乱问题
            if let scrollView = self.currentListScrollView {
                scrollView.setContentOffset(scrollView.contentOffset, animated: false)
            }
        }
        let translation = panGesture.translation(in: self.bottomContainerView)
        if self.isDragScrollView {
            allowScrolling(scrollView: scrollView)
            // 当UIScrollView在最顶部时，处理视图的滑动
            if self.scrollView?.contentOffset.y ?? 0 <= 0 {
                if translation.y > 0 { // 向下拖拽
                    forbidScrolling(scrollView: scrollView)
                    self.isDragScrollView = false
                    var frame = self.bottomContainerView.frame
                    frame.origin.y += translation.y
                    self.bottomContainerView.frame = frame
                    
                    if !self.isAllowDragScroll {
                        self.scrollView?.panGestureRecognizer.isEnabled = false
                        self.scrollView?.panGestureRecognizer.isEnabled = true
                    }
                }
            }
        }else {
            let offsetY = self.scrollView?.contentOffset.y ?? 0
            let ceilPointY = self.ceilPointHeight
            
            if offsetY <= 0 {
                forbidScrolling(scrollView: scrollView)
                if translation.y > 0 { // 向下拖拽
                    var frame = self.bottomContainerView.frame
                    frame.origin.y += translation.y
                    self.bottomContainerView.frame = frame
                }else if (translation.y < 0 && self.bottomContainerView.frame.origin.y > ceilPointY) { // 向上拖拽
                    var frame = self.bottomContainerView.frame
                    frame.origin.y = max((self.bottomContainerView.frame.origin.y + translation.y), ceilPointY)
                    self.bottomContainerView.frame = frame
                }
            }else {
                if (translation.y < 0 && self.bottomContainerView.frame.origin.y > ceilPointY) { // 向上拖拽
                    var frame = self.bottomContainerView.frame
                    frame.origin.y = max((self.bottomContainerView.frame.origin.y + translation.y), ceilPointY)
                    self.bottomContainerView.frame = frame
                }
                
                if self.bottomContainerView.frame.origin.y > ceilPointY {
                    forbidScrolling(scrollView: scrollView)
                }else {
                    allowScrolling(scrollView: scrollView)
                }
            }
        }
        
        if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: self.bottomContainerView)
            if velocity.y < 0 { // 上滑
                if abs(self.lastTransitionY) > 5 && self.isDragScrollView == false {
                    self.dragShowing()
                }else {
                    if self.bottomContainerView.frame.origin.y > (self.ceilPointHeight + self.bottomContainerView.frame.size.height / 2) {
                        self.dragDismiss()
                    }else {
                        self.dragShowing()
                    }
                }
            }else { // 下滑
                if abs(self.lastTransitionY) > 5 && self.isDragScrollView == false && self.scrollView?.isDecelerating == false {
                    self.dragDismiss()
                }else {
                    if self.bottomContainerView.frame.origin.y > (self.ceilPointHeight + self.bottomContainerView.frame.size.height / 2) {
                        self.dragDismiss()
                    }else {
                        self.dragShowing()
                    }
                }
            }
            allowScrolling(scrollView: scrollView)
            self.isDragScrollView = false
            self.scrollView = nil
        }
        panGesture.setTranslation(.zero, in: self.bottomContainerView)
        self.lastTransitionY = translation.y
    }
    
    // MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == self.panGesture {
            var touchView = touch.view
            while touchView != nil {
                if touchView == self.currentListScrollView {
                    self.scrollView = touchView as? UIScrollView
                    self.isDragScrollView = true
                    break
                }else if touchView == self.bottomContainerView {
                    self.isDragScrollView = false
                    break
                }
                touchView = touchView?.next as? UIView
            }
        }
        return true
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let transition = panGesture.translation(in: gestureRecognizer.view)
            if transition.x != 0 { return false }
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGesture {
            if otherGestureRecognizer == self.scrollView?.panGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    // MARK: - KVO
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let scrollView = object as? UIScrollView {
                listDidScroll(scrollView: scrollView)
            }
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Private Methods
    func listDidScroll(scrollView: UIScrollView) {
        if listCollectionView.isDragging || listCollectionView.isDecelerating { return }
        
        if self.isOnTop { // 在顶部时无需处理headerView
            // 取消scrollView下滑时的弹性效果
            // buf fix #47，iOS12及以下系统isDragging会出现不准确的情况，所以这里改为用isTracking判断
            if self.isAllowDragScroll && (scrollView.isTracking || scrollView.isDecelerating) {
                if scrollView.contentOffset.y < 0 {
                    scrollView.contentOffset = .zero
                }
            }
            self.delegate?.smoothViewListScrollViewDidScroll?(self, scrollView: scrollView, contentOffset: scrollView.contentOffset)
        }else { // 不在顶部，通过列表scrollView滑动确定悬浮位置
            let index = self.listIndex(for: scrollView)
            if index != self.currentIndex { return }
            self.currentListScrollView = scrollView
            let contentOffsetY = scrollView.contentOffset.y + headerContainerHeight
            
            if contentOffsetY < (headerHeight - ceilPointHeight) {
                self.hoverType = .none
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
                
                if self.isBottomHover {
                    if contentOffsetY < headerContainerHeight - frame.size.height {
                        self.hoverType = .bottom
                        if self.segmentedView?.superview != self.bottomContainerView {
                            self.bottomContainerView.isHidden = false
                            self.segmentedView?.frame.origin.y = 0
                            self.bottomContainerView.addSubview(self.segmentedView!)
                        }
                    }else {
                        if self.segmentedView?.superview != self.headerContainerView {
                            self.bottomContainerView.isHidden = true
                            self.segmentedView?.frame.origin.y = self.headerHeight
                            self.headerContainerView.addSubview(self.segmentedView!)
                        }
                    }
                }
            }else {
                self.hoverType = .top
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
            let contentOffset = CGPoint(x: scrollView.contentOffset.x, y: contentOffsetY)
            self.delegate?.smoothViewListScrollViewDidScroll?(self, scrollView: scrollView, contentOffset: contentOffset)
        }
    }
    
    func loadHeaderAndSegmentedView() {
        self.headerView = self.dataSource?.headerView(in: self)
        self.segmentedView = self.dataSource?.segmentedView(in: self)
        self.headerContainerView.addSubview(self.headerView!)
        self.headerContainerView.addSubview(self.segmentedView!)
        
        self.headerHeight = self.headerView!.bounds.size.height
        self.segmentedHeight = self.segmentedView!.bounds.size.height
        self.headerContainerHeight = self.headerHeight + self.segmentedHeight
    }
    
    func refreshWidth(completion: @escaping (_ size: CGSize)->()) {
        if self.bounds.size.width == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                completion(self.bounds.size)
            }
        }else {
            completion(self.bounds.size)
        }
    }
    
    func horizontalScrollDidEnd(at index: Int) {
        currentIndex = index
        guard let listHeader = listHeaderDict[index], let listScrollView = listDict[index]?.listScrollView() else { return }
        self.currentListScrollView = listScrollView
        if self.isOnTop { return }
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
        guard let dataSource = dataSource else { return }
        let count = dataSource.numberOfLists(in: self)
        if count <= 0 || index >= count {
            return
        }
        listDict[index]?.listViewDidAppear?()
    }
    
    func listDidDisappear(at index: Int) {
        guard let dataSource = dataSource else { return }
        let count = dataSource.numberOfLists(in: self)
        if count <= 0 || index >= count {
            return
        }
        listDict[index]?.listViewDidDisappear?()
    }
    
    func allowScrolling(scrollView: UIScrollView?) {
        scrollView?.bounces = self.originBounces
        scrollView?.showsVerticalScrollIndicator = self.originShowsVerticalScrollIndicator
    }
    
    func forbidScrolling(scrollView: UIScrollView?) {
        scrollView?.contentOffset = .zero
        scrollView?.bounces = false
        scrollView?.showsVerticalScrollIndicator = false
    }
    
    func dragBegan() {
        self.isOnTop = true
        self.setupShowingLayout()
    }
    
    func dragDismiss() {
        UIView.animate(withDuration: 0.25) {
            var frame = self.bottomContainerView.frame
            frame.origin.y = self.frame.size.height - self.segmentedHeight
            self.bottomContainerView.frame = frame
        } completion: { (finished) in
            self.setupDismissLayout()
            self.isOnTop = false
            self.delegate?.smoothViewDragEnded?(self, isOnTop: self.isOnTop)
        }
    }
    
    func dragShowing() {
        UIView.animate(withDuration: 0.25) {
            var frame = self.bottomContainerView.frame
            frame.origin.y = self.ceilPointHeight
            self.bottomContainerView.frame = frame
        } completion: { (finished) in
            self.delegate?.smoothViewDragEnded?(self, isOnTop: self.isOnTop)
        }
    }
    
    func setupShowingLayout() {
        // 将headerContainerView添加到self
        if self.headerContainerView.superview != self {
            var frame = self.headerContainerView.frame
            frame.origin.y = -(self.currentListScrollView!.contentOffset.y + self.headerContainerHeight)
            self.headerContainerView.frame = frame
            self.insertSubview(self.headerContainerView, belowSubview: self.bottomContainerView)
        }
        
        // 将listCollectionView添加到bottomContainerView
        if self.listCollectionView.superview != self.bottomContainerView {
            var frame = self.listCollectionView.frame
            frame.origin.y = self.segmentedHeight
            frame.size.height = self.bottomContainerView.frame.size.height - self.segmentedHeight
            self.listCollectionView.frame = frame
            self.bottomContainerView.addSubview(self.listCollectionView)
            self.listCollectionView.headerContainerView = nil
            
            // 记录当前列表的滑动位置
            self.currentListPanBeganContentOffsetY = self.currentListScrollView?.contentOffset.y ?? 0
            
            self.listDict.values.forEach {
                $0.listScrollView().contentInset = .zero
                $0.listScrollView().contentOffset = .zero
                
                var frame = $0.listView().frame
                frame.size = self.listCollectionView.bounds.size
                $0.listView().frame = frame
            }
        }
    }
    
    func setupDismissLayout() {
        guard let listScrollView = self.currentListScrollView else { return }
        let listHeader = self.listHeader(for: listScrollView)
        if self.headerContainerView.superview != listHeader {
            var frame = self.headerContainerView.frame
            frame.origin.y = 0
            self.headerContainerView.frame = frame
            listHeader?.addSubview(self.headerContainerView)
        }
        
        if self.listCollectionView.superview != self {
            self.listCollectionView.frame = self.bounds
            self.insertSubview(self.listCollectionView, belowSubview: self.bottomContainerView)
            self.listCollectionView.headerContainerView = self.headerContainerView
            
            self.listDict.values.forEach {
                $0.listScrollView().contentInset = UIEdgeInsets(top: self.headerContainerHeight, left: 0, bottom: 0, right: 0)
                $0.listScrollView().contentOffset = .zero
                
                var frame = $0.listView().frame
                frame.size = self.listCollectionView.bounds.size
                $0.listView().frame = frame
            }
            self.currentListScrollView?.contentOffset = CGPoint(x: 0, y: self.currentListPanBeganContentOffsetY)
        }
    }
}

extension GKPageSmoothView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource else { return 0 }
        
        let count = dataSource.numberOfLists(in: self)
        return self.isLoaded ? count : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = self.dataSource else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GKPageSmoothViewCellID, for: indexPath)
        var list = listDict[indexPath.item]
        if list == nil {
            list = dataSource.smoothView(self, initListAtIndex: indexPath.item)
            listDict[indexPath.item] = list!
            list?.listView().setNeedsLayout()
            list?.listView().layoutIfNeeded()
            
            let listScrollView = list?.listScrollView()
            if listScrollView?.isKind(of: UITableView.self) == true {
                (listScrollView as? UITableView)?.estimatedRowHeight = 0
                (listScrollView as? UITableView)?.estimatedSectionHeaderHeight = 0
                (listScrollView as? UITableView)?.estimatedSectionFooterHeight = 0
            }
            if #available(iOS 11.0, *) {
                list?.listScrollView().contentInsetAdjustmentBehavior = .never
            }
            
            if __CGSizeEqualToSize(listScrollView?.contentSize ?? .zero, .zero) {
                list?.listScrollView().contentSize = CGSize(width: list?.listScrollView().contentSize.width ?? 0, height: self.bounds.size.height)
            }
            
            if !self.isOnTop {
                list?.listScrollView().contentInset = UIEdgeInsets(top: headerContainerHeight, left: 0, bottom: 0, right: 0)
                currentListInitailzeContentOffsetY = -headerContainerHeight + min(-currentHeaderContainerViewY, (headerHeight - ceilPointHeight))
                list?.listScrollView().contentOffset = CGPoint(x: 0, y: currentListInitailzeContentOffsetY)
            }
            let listHeader = UIView(frame: CGRect(x: 0, y: -headerContainerHeight, width: bounds.size.width, height: headerContainerHeight))
            listScrollView?.addSubview(listHeader)
            
            if !self.isOnTop && self.headerContainerView.superview == nil {
                listHeader.addSubview(headerContainerView)
            }
            listHeaderDict[indexPath.item] = listHeader
            list?.listScrollView().addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            // bug fix #69 修复首次进入时可能出现的headerView无法下拉的问题
            listScrollView?.contentOffset = listScrollView!.contentOffset
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
        return self.listCollectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listDidAppear(at: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listDidDisappear(at: indexPath.item)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.panGesture.isEnabled = false
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.smoothViewDidScroll?(self, scrollView: scrollView)
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
        let ratio = Int(scrollView.contentOffset.x)%Int(scrollView.bounds.size.width)
        
        if !self.isOnTop {
            let listScrollView = self.listDict[index]?.listScrollView()
            if index != currentIndex && ratio == 0 && !(scrollView.isDragging || scrollView.isDecelerating) && listScrollView?.contentOffset.y ?? 0 <= -(segmentedHeight + ceilPointHeight) {
                horizontalScrollDidEnd(at: index)
            }else {
                if headerContainerView.superview != self {
                    headerContainerView.frame.origin.y = currentHeaderContainerViewY
                    addSubview(headerContainerView)
                }
            }
        }
        if currentIndex != index && ratio == 0 {
            currentIndex = index
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
            horizontalScrollDidEnd(at: index)
        }
        self.panGesture.isEnabled = true
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        horizontalScrollDidEnd(at: index)
        self.panGesture.isEnabled = true
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        currentListScrollView = self.listDict[currentIndex]?.listScrollView()
    }
}
