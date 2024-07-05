//
//  GKPageSmoothView.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2020/5/10.
//  Copyright © 2020 QuintGao. All rights reserved.
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
    
    @objc optional func listViewWillAppear()
    @objc optional func listViewDidAppear()
    @objc optional func listViewWillDisappear()
    @objc optional func listViewDidDisappear()
    
    /// 当contentSize改变且不足一屏时，是否重置scrollView的位置，默认YES
    @objc optional func listScrollViewShouldReset() -> Bool
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
    
    // 代理
    public weak var delegate: GKPageSmoothViewDelegate?
    
    // 当前已经加载过的可用的列表字典，key是index值，value是对应列表
    public private(set) var listDict = [Int: GKPageSmoothListViewDelegate]()
    public let listCollectionView: GKPageSmoothCollectionView
    
    // 默认索引
    public var defaultSelectedIndex: Int = 0 {
        didSet {
            currentIndex = defaultSelectedIndex
        }
    }
    
    // 当前索引
    public private(set) var currentIndex: Int = 0
    
    // 当前列表
    public private(set) var currentListScrollView: UIScrollView?
    
    // 是否禁止主页滑动，默认false
    public var isMainScrollDisabled: Bool = false
    
    // 吸顶临界高度，默认0
    public var ceilPointHeight: CGFloat = 0
    
    // 是否内部控制指示器的显示与隐藏（默认为false）
    public var isControlVerticalIndicator: Bool = false

    // 是否支持底部悬停，默认false，只有当前headerView高度大于pageSmoothView高度时才生效
    public var isBottomHover: Bool = false {
        didSet {
            if (isBottomHover) {
                refreshWidth { [weak self] (size) in
                    guard let self = self else { return }
                    self.bottomContainerView.frame = CGRect(x: 0, y: size.height - self.segmentedHeight, width: size.width, height: size.height - self.ceilPointHeight)
                    self.addSubview(self.bottomContainerView)
                    
                    if self.headerHeight > size.height {
                        self.segmentedView?.frame = CGRect(x: 0, y: 0, width: size.width, height: self.segmentedHeight)
                        self.bottomContainerView.addSubview(self.segmentedView!)
                    }
                }
            }else {
                bottomContainerView.removeFromSuperview()
            }
        }
    }
    
    // 是否允许底部拖拽，默认false，当bottomHover为YES时才生效
    public var isAllowDragBottom: Bool = false {
        didSet {
            if isBottomHover {
                if isAllowDragBottom == true {
                    bottomContainerView.addGestureRecognizer(panGesture)
                }else {
                    bottomContainerView.removeGestureRecognizer(panGesture)
                }
            }
        }
    }
    
    // 是否允许底部拖拽到临界位置时可滑动scrollView，默认false
    public var isAllowDragScroll: Bool = false
    
    // 是否撑起scrollView，默认false
    // 如果设置为YES则当scrollView的contentSize不足时会修改scrollView的contentSize使其能够滑动到悬浮状态
    public var isHoldUpScrollView: Bool = false
    
    // smoothView悬停类型
    public private(set) var hoverType: GKPageSmoothHoverType = .none
    
    // 是否通过拖拽滑动到顶部
    public private(set) var isOnTop: Bool = false
    
    // 数据源
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
    
    var isSyncListContentOffsetEnabled: Bool = false
    var currentHeaderContainerViewY: CGFloat = 0
    
    /// header容器的高度
    public private(set) var headerContainerHeight: CGFloat = 0
    var headerHeight: CGFloat = 0
    var segmentedHeight: CGFloat = 0
    var currentListInitailzeContentOffsetY: CGFloat = 0
    
    var isLoaded: Bool = false
    
    var scrollView: UIScrollView?
    var isDragScrollView: Bool = false
    var lastTransitionY: CGFloat = 0
    var currentListPanBeganContentOffsetY: CGFloat = 0
    var originBounces = false
    var originShowsVerticalScrollIndicator = false
    
    var isScroll = false
    var willAppearIndex = -1
    var willDisappearIndex = -1
    
    var isChangeOffset: Bool = false
    
    public init(dataSource: GKPageSmoothViewDataSource) {
        self.dataSource = dataSource
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        listCollectionView = GKPageSmoothCollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        initSubviews()
    }
    
    public required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        listCollectionView = GKPageSmoothCollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
        initSubviews()
    }
    
    private func initSubviews() {
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        listCollectionView.isPagingEnabled = true
        listCollectionView.bounces = false
        listCollectionView.showsHorizontalScrollIndicator = false
        listCollectionView.showsVerticalScrollIndicator = false
        listCollectionView.scrollsToTop = false
        listCollectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: GKPageSmoothViewCellID)
        if #available(iOS 10.0, *) {
            listCollectionView.isPrefetchingEnabled = false
        }
        if #available(iOS 11.0, *) {
            listCollectionView.contentInsetAdjustmentBehavior = .never
        }
        listCollectionView.headerContainerView = headerContainerView
        addSubview(listCollectionView)
        addSubview(headerContainerView)
        refreshHeaderView()
    }
    
    deinit {
        listDict.values.forEach {
            $0.listScrollView().removeObserver(self, forKeyPath: "contentOffset")
            $0.listScrollView().removeObserver(self, forKeyPath: "contentSize")
        }
        listCollectionView.dataSource = nil
        listCollectionView.delegate = nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
                
        if (isMainScrollDisabled) {
            var frame = frame
            frame.origin.y = headerContainerHeight
            frame.size.height -= headerContainerHeight
            refreshList(frame: frame)
            listCollectionView.frame = frame
        }else {
            if listCollectionView.superview == self {
                refreshList(frame: bounds)
                listCollectionView.frame = bounds
            }else {
                var frame = bottomContainerView.frame
                frame.size.width = bounds.width
                frame.size.height = bounds.height - ceilPointHeight
                bottomContainerView.frame = frame
                
                frame = listCollectionView.frame
                frame.origin.y = segmentedHeight
                frame.size.width = frame.width
                frame.size.height = bottomContainerView.frame.height - segmentedHeight
                refreshList(frame: frame)
                listCollectionView.frame = frame
            }
        }
        
        listHeaderDict.values.forEach {
            var frame = $0.frame
            frame.origin.y = -headerContainerHeight
            frame.size.height = headerContainerHeight
            $0.frame = frame
        }
    }
    
    func refreshList(frame: CGRect) {
        listDict.values.forEach {
            var f = $0.listView().frame
            if ((f.width != 0 && f.width != frame.width) || (f.height != 0 && f.height != frame.height)) {
                f.size.width = frame.width
                f.size.height = frame.height
                $0.listView().frame = f
                listCollectionView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
                    guard let self = self else { return }
                    self.isChangeOffset = true
                    self.set(scrollView: self.listCollectionView, offset: CGPointMake(CGFloat(self.currentIndex) * frame.width, 0))
                }
            }
        }
    }
    
    /// 刷新headerView，headerView高度改变时调用
    public func refreshHeaderView() {
        loadHeaderAndSegmentedView()
        refreshHeaderContainerView()
    }
    
    /// 刷新segmentedView，segmentedView高度改变时调用
    public func refreshSegmentedView() {
        segmentedView = dataSource?.segmentedView(in: self)
        headerContainerView.addSubview(segmentedView!)
        refreshHeaderContainerHeight()
        refreshHeaderContainerView()
    }
    
    /// 刷新列表
    public func reloadData() {
        currentListScrollView = nil
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
        
        refreshWidth { [weak self] (size) in
            guard let self = self else { return }
            self.set(scrollView: self.listCollectionView, offset: CGPoint(x: size.width * CGFloat(self.currentIndex), y: 0))
            self.listCollectionView.reloadData()
            
            // 首次加载
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.listWillAppear(at: self.currentIndex)
                self.listDidAppear(at: self.currentIndex)
            }
        }
    }
    
    /// 滑动到原点
    public func scrollToOriginalPoint(_ animated: Bool? = true) {
        currentListScrollView?.setContentOffset(CGPoint(x: 0, y: -headerContainerHeight), animated: animated ?? true)
    }
    
    /// 滑动到悬停点
    public func scrollToCriticalPoint(_ animated: Bool? = true) {
        currentListScrollView?.setContentOffset(CGPoint(x: 0, y: -(segmentedHeight + ceilPointHeight)), animated: animated ?? true)
    }
    
    /// 显示在顶部，允许底部拖拽时生效
    public func showingOnTop() {
        if (bottomContainerView.isHidden) { return }
        dragBegan()
        dragShowing()
    }
    
    /// 显示在底部，允许底部拖拽时生效
    public func showingOnBottom() {
        if (bottomContainerView.isHidden) { return }
        dragDismiss()
    }
    
    // MARK: - Gesture
    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began {
            delegate?.smoothViewDragBegan?(self)
            dragBegan()
            if let scrollView = scrollView {
                originBounces = scrollView.bounces
                originShowsVerticalScrollIndicator = scrollView.showsVerticalScrollIndicator
            }
            
            // bug fix #47，当UIScrollView向下滚动的时候，向下拖拽完成手势操作导致的错乱问题
            if let scrollView = currentListScrollView {
                scrollView.setContentOffset(scrollView.contentOffset, animated: false)
            }
        }
        let translation = panGesture.translation(in: bottomContainerView)
        if isDragScrollView {
            allowScrolling(scrollView: scrollView)
            // 当UIScrollView在最顶部时，处理视图的滑动
            if scrollView?.contentOffset.y ?? 0 <= 0 {
                if translation.y > 0 { // 向下拖拽
                    forbidScrolling(scrollView: scrollView)
                    isDragScrollView = false
                    var frame = bottomContainerView.frame
                    frame.origin.y += translation.y
                    bottomContainerView.frame = frame
                    
                    if !isAllowDragScroll {
                        scrollView?.panGestureRecognizer.isEnabled = false
                        scrollView?.panGestureRecognizer.isEnabled = true
                    }
                }
            }
        }else {
            let offsetY = scrollView?.contentOffset.y ?? 0
            let ceilPointY = ceilPointHeight
            
            if offsetY <= 0 {
                forbidScrolling(scrollView: scrollView)
                if translation.y > 0 { // 向下拖拽
                    var frame = bottomContainerView.frame
                    frame.origin.y += translation.y
                    bottomContainerView.frame = frame
                }else if (translation.y < 0 && bottomContainerView.frame.origin.y > ceilPointY) { // 向上拖拽
                    var frame = bottomContainerView.frame
                    frame.origin.y = max((bottomContainerView.frame.origin.y + translation.y), ceilPointY)
                    bottomContainerView.frame = frame
                }
            }else {
                if (translation.y < 0 && bottomContainerView.frame.origin.y > ceilPointY) { // 向上拖拽
                    var frame = bottomContainerView.frame
                    frame.origin.y = max((bottomContainerView.frame.origin.y + translation.y), ceilPointY)
                    bottomContainerView.frame = frame
                }
                
                if bottomContainerView.frame.origin.y > ceilPointY {
                    forbidScrolling(scrollView: scrollView)
                }else {
                    allowScrolling(scrollView: scrollView)
                }
            }
        }
        
        if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: bottomContainerView)
            if velocity.y < 0 { // 上滑
                if abs(lastTransitionY) > 5 && isDragScrollView == false {
                    dragShowing()
                }else {
                    if bottomContainerView.frame.origin.y > (ceilPointHeight + bottomContainerView.frame.height / 2) {
                        dragDismiss()
                    }else {
                        dragShowing()
                    }
                }
            }else { // 下滑
                if abs(lastTransitionY) > 5 && isDragScrollView == false && scrollView?.isDecelerating == false {
                    dragDismiss()
                }else {
                    if bottomContainerView.frame.origin.y > (ceilPointHeight + bottomContainerView.frame.height / 2) {
                        dragDismiss()
                    }else {
                        dragShowing()
                    }
                }
            }
            allowScrolling(scrollView: scrollView)
            isDragScrollView = false
            scrollView = nil
        }
        panGesture.setTranslation(.zero, in: bottomContainerView)
        lastTransitionY = translation.y
    }
    
    // MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == panGesture {
            var touchView = touch.view
            while touchView != nil {
                if touchView == currentListScrollView {
                    scrollView = touchView as? UIScrollView
                    isDragScrollView = true
                    break
                }else if touchView == bottomContainerView {
                    isDragScrollView = false
                    break
                }
                touchView = touchView?.next as? UIView
            }
        }
        return true
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let transition = panGesture.translation(in: gestureRecognizer.view)
            if transition.x != 0 { return false }
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            if otherGestureRecognizer == scrollView?.panGestureRecognizer {
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
        } else if keyPath == "contentSize" {
            let minContentSizeHeight = bounds.height - segmentedHeight - ceilPointHeight
            if let scrollView = object as? UIScrollView {
                let contentH = scrollView.contentSize.height
                if minContentSizeHeight > contentH && isHoldUpScrollView {
                    scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: minContentSizeHeight)
                    //新的scrollView第一次加载的时候重置contentOffset
                    if let listScrollView = currentListScrollView {
                        if scrollView != listScrollView && scrollView.contentSize != .zero && !isOnTop {
                            set(scrollView: scrollView, offset: CGPoint(x: 0, y: currentListInitailzeContentOffsetY))
                        }
                    }
                }else {
                    var shoudReset = true
                    for list in listDict.values {
                        if list.listScrollView() == scrollView && list.listScrollViewShouldReset?() != nil {
                            shoudReset = list.listScrollViewShouldReset!()
                        }
                    }
                    
                    if minContentSizeHeight > contentH && shoudReset && !isMainScrollDisabled {
                        set(scrollView: scrollView, offset: CGPoint(x: scrollView.contentOffset.x, y: -headerContainerHeight))
                        listDidScroll(scrollView: scrollView)
                    }
                }
            }
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Private Methods
    func listDidScroll(scrollView: UIScrollView) {
        if isMainScrollDisabled {
            delegate?.smoothViewListScrollViewDidScroll?(self, scrollView: scrollView, contentOffset: scrollView.contentOffset)
            return
        }
        
        if listCollectionView.isDragging || listCollectionView.isDecelerating { return }
        
        if isOnTop { // 在顶部时无需处理headerView
            hoverType = .top
            // 取消scrollView下滑时的弹性效果
            // buf fix #47，iOS12及以下系统isDragging会出现不准确的情况，所以这里改为用isTracking判断
            if isAllowDragScroll && (scrollView.isTracking || scrollView.isDecelerating) {
                if scrollView.contentOffset.y < 0 {
                    set(scrollView: scrollView, offset: .zero)
                }
            }
            delegate?.smoothViewListScrollViewDidScroll?(self, scrollView: scrollView, contentOffset: scrollView.contentOffset)
        }else { // 不在顶部，通过列表scrollView滑动确定悬浮位置
            let index = listIndex(for: scrollView)
            if index != currentIndex { return }
            currentListScrollView = scrollView
            let contentOffsetY = scrollView.contentOffset.y + headerContainerHeight
            
            if contentOffsetY < (headerHeight - ceilPointHeight) {
                hoverType = .none
                isSyncListContentOffsetEnabled = true
                currentHeaderContainerViewY = -contentOffsetY
                listDict.values.forEach {
                    if $0.listScrollView() != scrollView {
                        set(scrollView: $0.listScrollView(), offset: scrollView.contentOffset)
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
                
                if isBottomHover {
                    if contentOffsetY < headerContainerHeight - frame.height {
                        hoverType = .bottom
                        if segmentedView?.superview != bottomContainerView {
                            bottomContainerView.isHidden = false
                            segmentedView?.frame.origin.y = 0
                            bottomContainerView.addSubview(segmentedView!)
                        }
                    }else {
                        if segmentedView?.superview != headerContainerView {
                            bottomContainerView.isHidden = true
                            segmentedView?.frame.origin.y = headerHeight
                            headerContainerView.addSubview(segmentedView!)
                        }
                    }
                }
            }else {
                hoverType = .top
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
                    listDict.values.forEach {
                        if ($0.listScrollView() != currentListScrollView) {
                            set(scrollView: $0.listScrollView(), offset: CGPoint(x: 0, y: -(segmentedHeight + ceilPointHeight)))
                        }
                    }
                }
            }
            let contentOffset = CGPoint(x: scrollView.contentOffset.x, y: contentOffsetY)
            delegate?.smoothViewListScrollViewDidScroll?(self, scrollView: scrollView, contentOffset: contentOffset)
        }
    }
    
    func loadHeaderAndSegmentedView() {
        headerView = dataSource?.headerView(in: self)
        segmentedView = dataSource?.segmentedView(in: self)
        headerContainerView.addSubview(headerView!)
        headerContainerView.addSubview(segmentedView!)
        refreshHeaderContainerHeight()
    }
    
    func refreshHeaderContainerView() {
        refreshWidth { [weak self] (size) in
            guard let self = self else { return }
            self.refreshHeaderContainerHeight()
            
            var frame = self.headerContainerView.frame
            if __CGSizeEqualToSize(frame.size, .zero) {
                frame = CGRect(x: 0, y: 0, width: size.width, height: self.headerContainerHeight)
            }else {
                frame.size.height = self.headerContainerHeight
            }
            self.headerContainerView.frame = frame
            
            self.headerView?.frame = CGRect(x: 0, y: 0, width: size.width, height: self.headerHeight)
            self.segmentedView?.frame = CGRect(x: 0, y: self.headerHeight, width: size.width, height: self.segmentedHeight)
            
            if self.segmentedView?.superview != self.headerContainerView { // 修复headerHeight < size.height, headerContainerHeight > size.height时segmentedView.superView为bottomContainerView
                self.headerContainerView.addSubview(self.segmentedView!)
            }
            
            if (!self.isMainScrollDisabled) {
                self.listDict.values.forEach {
                    var insets = $0.listScrollView().contentInset
                    insets.top = self.headerContainerHeight
                    $0.listScrollView().contentInset = insets
                    self.set(scrollView: $0.listScrollView(), offset: CGPoint(x: 0, y: -self.headerContainerHeight))
                }
                self.listHeaderDict.values.forEach {
                    var frame = $0.frame
                    frame.origin.y = -self.headerContainerHeight
                    frame.size.height = self.headerContainerHeight
                    $0.frame = frame
                }
            }
            
            if self.isBottomHover {
                if self.headerHeight > size.height {
                    self.bottomContainerView.isHidden = false // 修复滑动到非悬浮状态后执行刷新导致bottomContainerView未显示的问题
                    self.segmentedView?.frame = CGRect(x: 0, y: 0, width: size.width, height: self.segmentedHeight)
                    self.bottomContainerView.addSubview(self.segmentedView!)
                }
                if self.hoverType == .bottom {
                    self.bottomContainerView.frame = CGRect(x: 0, y: size.height - self.segmentedHeight, width: size.width, height: size.height - self.ceilPointHeight)
                    self.setupDismissLayout()
                }else if self.hoverType == .top {
                    // 记录当前列表的滑动位置
                    self.currentListPanBeganContentOffsetY = self.currentListScrollView?.contentOffset.y ?? 0
                    
                    self.listDict.values.forEach { [weak self] in
                        guard let self = self else { return }
                        $0.listScrollView().contentInset = .zero
                        self.set(scrollView: $0.listScrollView(), offset: .zero)
                        
                        var frame = $0.listView().frame
                        frame.size = self.listCollectionView.bounds.size
                        $0.listView().frame = frame
                    }
                }
            }
        }
    }
    
    func refreshHeaderContainerHeight() {
        headerHeight = headerView?.bounds.height ?? 0
        segmentedHeight = segmentedView?.bounds.height ?? 0
        headerContainerHeight = headerHeight + segmentedHeight
    }
    
    func refreshWidth(completion: @escaping (_ size: CGSize)->()) {
        if bounds.width == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                completion(self.bounds.size)
            }
        }else {
            completion(bounds.size)
        }
    }
    
    func horizontalScrollDidEnd(at index: Int) {
        currentIndex = index
        guard let listHeader = listHeaderDict[index], let listScrollView = listDict[index]?.listScrollView() else { return }
        currentListScrollView = listScrollView
        if isOnTop { return }
        listDict.values.forEach {
            $0.listScrollView().scrollsToTop = ($0.listScrollView() == listScrollView)
        }
        if listScrollView.contentOffset.y <= -(segmentedHeight + ceilPointHeight) {
            headerContainerView.frame.origin.y = 0
            listHeader.addSubview(headerContainerView)
        }
        
        let minContentSizeHeight = bounds.height - segmentedHeight - ceilPointHeight
        if (minContentSizeHeight > listScrollView.contentSize.height && !isHoldUpScrollView) {
            set(scrollView: listScrollView, offset: CGPoint(x: listScrollView.contentOffset.x, y: -headerContainerHeight))
            listDidScroll(scrollView: listScrollView)
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
    
    func listWillAppear(at index: Int) {
        guard checkIndexValid(index) else { return }
        let list = listDict[index]
        list?.listViewWillAppear?()
    }
    
    func listDidAppear(at index: Int) {
        guard checkIndexValid(index) else { return }
        currentIndex = index
        let list = listDict[index]
        list?.listViewDidAppear?()
    }
    
    func listWillDisappear(at index: Int) {
        guard checkIndexValid(index) else { return }
        let list = listDict[index]
        list?.listViewWillDisappear?()
    }
    
    func listDidDisappear(at index: Int) {
        guard checkIndexValid(index) else { return }
        let list = listDict[index]
        list?.listViewDidDisappear?()
    }
    
    func checkIndexValid(_ index: Int) -> Bool {
        guard let dataSource = dataSource else { return false }
        let count = dataSource.numberOfLists(in: self)
        if count <= 0 || index >= count {
            return false
        }
        return true
    }
    
    func listDidAppearOrDisappear(scrollView: UIScrollView) {
        let currentIndexPercent = scrollView.contentOffset.x / scrollView.bounds.width
        if willAppearIndex != -1 && willDisappearIndex != -1 {
            let appearIndex = willAppearIndex
            let disappearIndex = willDisappearIndex
            if willAppearIndex > willDisappearIndex {
                // 将要出现的列表在右边
                if currentIndexPercent >= CGFloat(willAppearIndex) {
                    willDisappearIndex = -1
                    willAppearIndex = -1
                    listDidDisappear(at: disappearIndex)
                    listDidAppear(at: appearIndex)
                }
            }else {
                // 将要出现的列表在左边
                if currentIndexPercent <= CGFloat(willAppearIndex) {
                    willDisappearIndex = -1
                    willAppearIndex = -1
                    listDidDisappear(at: disappearIndex)
                    listDidAppear(at: appearIndex)
                }
            }
        }
    }
    
    func allowScrolling(scrollView: UIScrollView?) {
        scrollView?.bounces = originBounces
        scrollView?.showsVerticalScrollIndicator = originShowsVerticalScrollIndicator
    }
    
    func forbidScrolling(scrollView: UIScrollView?) {
        set(scrollView: scrollView, offset: .zero)
        scrollView?.bounces = false
        scrollView?.showsVerticalScrollIndicator = false
    }
    
    func dragBegan() {
        isOnTop = true
        setupShowingLayout()
    }
    
    func dragDismiss() {
        UIView.animate(withDuration: 0.25) {
            var frame = self.bottomContainerView.frame
            frame.origin.y = self.frame.height - self.segmentedHeight
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
        if headerContainerView.superview != self {
            var frame = headerContainerView.frame
            frame.origin.y = -(currentListScrollView!.contentOffset.y + headerContainerHeight)
            headerContainerView.frame = frame
            insertSubview(headerContainerView, belowSubview: bottomContainerView)
        }
        
        // 将listCollectionView添加到bottomContainerView
        if listCollectionView.superview != bottomContainerView {
            var frame = listCollectionView.frame
            frame.origin.y = segmentedHeight
            frame.size.height = bottomContainerView.frame.height - segmentedHeight
            listCollectionView.frame = frame
            bottomContainerView.addSubview(listCollectionView)
            listCollectionView.headerContainerView = nil
            
            // 记录当前列表的滑动位置
            currentListPanBeganContentOffsetY = currentListScrollView?.contentOffset.y ?? 0
            
            listDict.values.forEach { [weak self] in
                guard let self = self else { return }
                $0.listScrollView().contentInset = .zero
                self.set(scrollView: $0.listScrollView(), offset: .zero)
                
                var frame = $0.listView().frame
                frame.size = self.listCollectionView.bounds.size
                $0.listView().frame = frame
            }
        }
    }
    
    func setupDismissLayout() {
        guard let listScrollView = currentListScrollView else { return }
        let listHeader = listHeader(for: listScrollView)
        if headerContainerView.superview != listHeader {
            var frame = headerContainerView.frame
            frame.origin.y = 0
            headerContainerView.frame = frame
            listHeader?.addSubview(headerContainerView)
        }
        
        if listCollectionView.superview != self {
            listCollectionView.frame = bounds
            insertSubview(listCollectionView, belowSubview: bottomContainerView)
            listCollectionView.headerContainerView = headerContainerView
            
            listDict.values.forEach { [weak self] in
                guard let self = self else { return }
                $0.listScrollView().contentInset = UIEdgeInsets(top: self.headerContainerHeight, left: 0, bottom: 0, right: 0)
                if $0.listScrollView() != self.currentListScrollView {
                    self.set(scrollView: $0.listScrollView(), offset: .zero)
                }
                
                var frame = $0.listView().frame
                frame.size = self.listCollectionView.bounds.size
                $0.listView().frame = frame
            }
            set(scrollView: currentListScrollView, offset: CGPoint(x: 0, y: currentListPanBeganContentOffsetY))
        }
    }
    
    fileprivate func set(scrollView: UIScrollView?, offset: CGPoint) {
        guard let scrollView = scrollView else { return }
        if !__CGPointEqualToPoint(scrollView.contentOffset, offset) {
            scrollView.setContentOffset(offset, animated: false)
        }
    }
}

extension GKPageSmoothView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        let count = dataSource.numberOfLists(in: self)
        return isLoaded ? count : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GKPageSmoothViewCellID, for: indexPath)
        var list = listDict[indexPath.item]
        if list == nil {
            list = dataSource.smoothView(self, initListAtIndex: indexPath.item)
            if let listVC = list as? UIViewController {
                var next: UIResponder? = superview
                while next != nil {
                    if let vc = next as? UIViewController {
                        vc.addChild(listVC)
                        break
                    }
                    next = next?.next
                }
            }
            listDict[indexPath.item] = list!
            list?.listView().setNeedsLayout()
            
            let listScrollView = list?.listScrollView()
            if #available(iOS 11.0, *) {
                list?.listScrollView().contentInsetAdjustmentBehavior = .never
            }
            
            if let scrollView = list?.listScrollView() {
                let minContentSizeHeight = bounds.height - segmentedHeight - ceilPointHeight
                if scrollView.contentSize.height < minContentSizeHeight && isHoldUpScrollView {
                    scrollView.contentSize = CGSize(width: bounds.width, height: minContentSizeHeight)
                }
            }
            
            if !isMainScrollDisabled {
                if !isOnTop {
                    var insets = list?.listScrollView().contentInset
                    insets?.top = headerContainerHeight
                    list?.listScrollView().contentInset = insets ?? .zero
                    currentListInitailzeContentOffsetY = -headerContainerHeight + min(-currentHeaderContainerViewY, (headerHeight - ceilPointHeight))
                    set(scrollView: list?.listScrollView(), offset: CGPoint(x: 0, y: currentListInitailzeContentOffsetY))
                }
                let listHeader = UIView(frame: CGRect(x: 0, y: -headerContainerHeight, width: bounds.width, height: headerContainerHeight))
                listScrollView?.addSubview(listHeader)
                
                if !isOnTop && headerContainerView.superview == nil {
                    listHeader.addSubview(headerContainerView)
                }
                listHeaderDict[indexPath.item] = listHeader
            }
            list?.listScrollView().addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            list?.listScrollView().addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
            // bug fix #69 修复首次进入时可能出现的headerView无法下拉的问题
            listScrollView?.contentOffset = listScrollView!.contentOffset
        }
        listDict.values.forEach {
            $0.listScrollView().scrollsToTop = ($0 === list)
        }
        if let listView = list?.listView(), listView.superview != cell.contentView {
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            listView.frame = cell.bounds
            cell.contentView.addSubview(listView)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        listDict.values.forEach { [weak self] in
            guard let self = self else { return }
            $0.listView().frame = CGRect.init(origin: .zero, size: self.listCollectionView.bounds.size)
        }
        return listCollectionView.bounds.size
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        panGesture.isEnabled = false
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isChangeOffset {
            isChangeOffset = false
            return
        }
        delegate?.smoothViewDidScroll?(self, scrollView: scrollView)
        let indexPercent = scrollView.contentOffset.x/scrollView.bounds.width
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.width)
        isScroll = true
        
        if !isMainScrollDisabled {
            if !isOnTop {
                let listScrollView = listDict[index]?.listScrollView()
                if index != currentIndex && (indexPercent - CGFloat(index) == 0) && !(scrollView.isTracking || scrollView.isDecelerating) && listScrollView?.contentOffset.y ?? 0 <= -(segmentedHeight + ceilPointHeight) {
                    horizontalScrollDidEnd(at: index)
                }else {
                    // 左右滚动的时候，把headerContainerView添加到self，达到悬浮的效果
                    if headerContainerView.superview != self {
                        headerContainerView.frame.origin.y = currentHeaderContainerViewY
                        addSubview(headerContainerView)
                    }
                }
            }
        }
        
        guard scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating else { return }
        let percent = scrollView.contentOffset.x / scrollView.bounds.width
        let maxCount = Int(round(scrollView.contentSize.width / scrollView.bounds.width))
        var leftIndex = Int(floor(Double(percent)))
        leftIndex = max(0, min(maxCount - 1, leftIndex))
        let rightIndex = leftIndex + 1
        if (percent < 0 || rightIndex >= maxCount) {
            listDidAppearOrDisappear(scrollView: scrollView)
            return
        }
        if rightIndex == currentIndex {
            // 当前选中的在右边，用户正在从右往左滑动
            if listDict[leftIndex] != nil {
                if willAppearIndex == -1 {
                    willAppearIndex = leftIndex
                    listWillAppear(at: willAppearIndex)
                }
            }
            if willDisappearIndex == -1 {
                willDisappearIndex = rightIndex
                listWillDisappear(at: willDisappearIndex)
            }
        }else {
            // 当前选中的在左边，用户正在从左往右滑动
            if listDict[rightIndex] != nil {
                if willAppearIndex == -1 {
                    willAppearIndex = rightIndex
                    listWillAppear(at: willAppearIndex)
                }
            }
            if willDisappearIndex == -1 {
                willDisappearIndex = leftIndex
                listWillDisappear(at: leftIndex)
            }
        }
        listDidAppearOrDisappear(scrollView: scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // 滑动到一半又取消滑动处理
            if (willDisappearIndex != -1) {
                listWillAppear(at: willDisappearIndex)
                listWillDisappear(at:willAppearIndex)
                listDidAppear(at:willDisappearIndex)
                listDidDisappear(at:willAppearIndex)
                willDisappearIndex = -1
                willAppearIndex = -1
            }
        }
        if (isMainScrollDisabled) { return }
        if !decelerate {
            let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            horizontalScrollDidEnd(at: index)
        }
        panGesture.isEnabled = true
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 滑动到一半又取消滑动处理
        if (willDisappearIndex != -1) {
            listWillAppear(at: willDisappearIndex)
            listWillDisappear(at:willAppearIndex)
            listDidAppear(at:willDisappearIndex)
            listDidDisappear(at:willAppearIndex)
            willDisappearIndex = -1
            willAppearIndex = -1
        }
        if (isMainScrollDisabled) { return }
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        horizontalScrollDidEnd(at: index)
        panGesture.isEnabled = true
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if !isLoaded { return }
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        currentIndex = index
        currentListScrollView = listDict[index]?.listScrollView()
        isScroll = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self = self else { return }
            if !self.isScroll && self.headerContainerView.superview == self {
                self.horizontalScrollDidEnd(at: index)
            }
        }
    }
}
