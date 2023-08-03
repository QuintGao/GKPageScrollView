//
//  GKPageScrollView.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2019/2/20.
//  Copyright © 2019 QuintGao. All rights reserved.
//

import UIKit

@objc public protocol GKPageListViewDelegate : NSObjectProtocol {
    
    /// 返回listView内部所持有的UIScrollview或UITableView或UICollectionView
    ///
    /// - Returns: UIScrollview
    func listScrollView() -> UIScrollView
    
    
    /// 当listView所持有的UIScrollview或UITableView或UICollectionView的代理方法`scrollViewDidScroll`回调时，需要调用该代理方法传入callBack
    ///
    /// - Parameter callBack: `scrollViewDidScroll`回调时调用的callBack
    func listViewDidScroll(callBack: @escaping (UIScrollView)->())
    
    
    /// 返回listView
    ///
    /// - Returns: UIView
    @objc optional func listView() -> UIView
    
    // 列表生命周期，懒加载方式有效
    @objc optional func listWillAppear()
    @objc optional func listDidAppear()
    @objc optional func listWillDisappear()
    @objc optional func listDidDisappear()
    
    /// 当子列表的scrollView需要改变位置时返回YES
    @objc optional func isListScrollViewNeedScroll() -> Bool
}

@objc public protocol GKPageScrollViewDelegate : NSObjectProtocol {
    /// 返回tableHeaderView
    ///
    /// - Parameter pageScrollView: pageScrollView description
    /// - Returns: tableHeaderView
    func headerView(in pageScrollView: GKPageScrollView) -> UIView
    
    // MARK: - 是否懒加载列表，优先级高于属性isLazyLoadList
    
    /// 返回是否懒加载列表（据此代理实现懒加载和非懒加载相应方法）
    ///
    /// - Parameter pageScrollView: pageScrollView description
    /// - Returns: 是否懒加载
    @objc optional func shouldLazyLoadList(in pageScrollView: GKPageScrollView) -> Bool
    
    // MARK: - 非懒加载相关方法(`shouldLazyLoadListInPageScrollView`方法返回NO时必须实现下面的方法)
    
    /// 返回分页试图
    ///
    /// - Parameter pageScrollView: pageScrollView description
    /// - Returns: pageView
    @objc optional func pageView(in pageScrollView: GKPageScrollView) -> UIView
    
    /// 返回listView，需实现GKPageListViewDelegate协议
    ///
    /// - Parameter pageScrollView: pageScrollView description
    /// - Returns: listView
    @objc optional func listView(in pageScrollView: GKPageScrollView) -> [GKPageListViewDelegate]
    
    // MARK: - 懒加载相关方法(`shouldLazyLoadListInPageScrollView`方法返回YES时必须实现下面的方法)
    
    /// 返回中间的segmentedView
    ///
    /// - Parameter pageScrollView: pageScrollView description
    /// - Returns: segmentedView
    @objc optional func segmentedView(in pageScrollView: GKPageScrollView) -> UIView
    
    /// 返回列表的数量
    ///
    /// - Parameter pageScrollView: pageScrollView description
    /// - Returns: 列表的数量
    @objc optional func numberOfLists(in pageScrollView: GKPageScrollView) -> Int
    
    /// 根据index初始化一个列表实例，需实现`GKPageListViewDelegate`代理
    ///
    /// - Parameters:
    ///   - pageScrollView: pageScrollView description
    ///   - index: 对应的索引
    /// - Returns: 实例对象
    @objc optional func pageScrollView(_ pageScrollView: GKPageScrollView, initListAtIndex index: Int) -> GKPageListViewDelegate
    
    // MARK: - mainTableView滚动相关方法
    
    /// mainTableView开始滑动回调
    ///
    /// - Parameter scrollView: mainTableView
    @objc optional func mainTableViewWillBeginDragging(_ scrollView: UIScrollView)
    
    /// mainTableView滑动回调，可用于实现导航栏渐变、头图缩放等功能
    ///
    /// - Parameters:
    ///   - scrollView: mainTableView
    ///   - isMainCanScroll: mainTableView是否可滑动，YES表示可滑动，没有到达临界点，NO表示不可滑动，已到达临界点
    @objc optional func mainTableViewDidScroll(_ scrollView: UIScrollView, isMainCanScroll: Bool)
    
    /// mainTableView结束滑动回调
    ///
    /// - Parameters:
    ///   - scrollView: mainTableView
    ///   - willDecelerate: 是否将要减速
    @objc optional func mainTableViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool)
    
    /// mainTableView结束滑动回调
    ///
    /// - Parameter scrollView: mainTableView
    @objc optional func mainTableViewDidEndDecelerating(_ scrollView: UIScrollView)
    
    /// mainTableView结束滑动动画
    /// - Parameter scrollView: mainTableView
    @objc optional func mainTableViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    
    /// pageScrollView刷新回调
    /// - Parameter pageScrollView: pageScrollView
    @objc optional func pageScrollViewReloadCell(_ pageScrollView: GKPageScrollView)
    
    /// 更新pageScrollView的cell属性
    /// 可需要cell的背景色等
    @objc optional func pageScrollViewUpdateCell(_ pageScrollView: GKPageScrollView, cell: UITableViewCell)
    
    /// 返回自定义UIScrollView或UICollectionView的class
    @objc optional func scrollViewClassInListContainerView(in pangeScrollView: GKPageScrollView) -> AnyClass?
    
    /// 控制能否初始化index对应的列表。有些业务需求，需要在某些情况下才允许初始化列表
    @objc optional func pageScrollViewListContainerView(_ containerView: GKPageListContainerView, canInitAt index: Int) -> Bool
}

open class GKPageScrollView: UIView {
    open weak var delegate: GKPageScrollViewDelegate!
    // 主列表
    open var mainTableView: GKPageTableView!
    // 包裹segmentedView和列表容器的view
    open var pageView: UIView?
    // 当前滑动的子列表
    open var currentListScrollView = UIScrollView()
    // 容器样式
    open var listContainerType: GKPageListContainerType = .collectionView
    // 懒加载时使用的容器
    open lazy var listContainerView: GKPageListContainerView = {
        let containerView = GKPageListContainerView(delegate: self, type: self.listContainerType)
        return containerView
    }()
    
    // 横向滑动的scrollView列表，用于解决左右滑动与上下滑动手势冲突
    open var horizontalScrollViewList: [UIScrollView]? {
        didSet {
            var list = horizontalScrollViewList
            if self.shouldLazyLoadListView() {
                list?.append(self.listContainerView.scrollView)
            }
            mainTableView.horizontalScrollViewList = list
        }
    }
    
    // 当前已经加载过可用的列表字典，key是index值，value是对应的列表
    public var validListDict = [Int: GKPageListViewDelegate]()
    
    // 吸顶临界点高度（默认：状态栏+导航栏）
    public var ceilPointHeight: CGFloat = GKPage_NavBar_Height
    
    // 是否允许列表下拉刷新，默认为NO
    public var isAllowListRefresh: Bool = false
    
    // 是否禁止mainScrollView在到达临界点后继续滑动，默认为NO
    public var isDisableMainScrollInCeil: Bool = false
    
    // 列表容器在UITableViewFooter中显示（默认NO）
    public var isShowInFooter: Bool = false
    
    // 是否懒加载列表
    public var isLazyLoadList: Bool = false {
        didSet {
            if self.shouldLazyLoadListView() {
                self.mainTableView.horizontalScrollViewList = [self.listContainerView.scrollView]
            }else {
                // 处理listView滑动
                self.configListViewScroll()
            }
        }
    }
    
    // 是否禁止主页滑动，默认NO
    public var isMainScrollDisabled: Bool = false {
        didSet {
            self.mainTableView.isScrollEnabled = !isMainScrollDisabled
            if isMainScrollDisabled {
                self.mainTableView.scrollsToTop = false
            }
        }
    }
    
    // 是否内部控制指示器的显示与隐藏（默认为NO）
    public var isControlVerticalIndicator: Bool = false
    
    // 刷新headerView后是否恢复到原始状态
    public var isRestoreWhenRefreshHeader: Bool = false
    
    // 刷新headerView后是否保持临界状态
    public var isKeepCriticalWhenRefreshHeader: Bool = false
    
    // 自动查找横向scrollView，设置为YES则不用传入horizontalScrollViewList，默认false
    public var isAutoFindHorizontalScrollView: Bool = false
    
    // MARK: - 内部属性，尽量不要修改
    // 是否滑动到临界点，可以有偏差
    public var isCriticalPoint: Bool = false
    // 是否达到临界点，无偏差
    public var isCeilPoint: Bool = false
    // mainTableView是否可以滑动
    public var isMainCanScroll: Bool = true
    // listScrollView是否可以滑动
    public var isListCanScroll: Bool = false
    
    // 是否开始拖拽，只有在拖拽中才去处理滑动，解决使用mj_header可能出现的bug
    var isBeginDragging: Bool = false
    
    // 快速切换原点和临界点
    var isScrollToOriginal: Bool = false
    var isScrollToCritical: Bool = false
    
    // 是否加载
    var isLoaded: Bool = false
    
    // headerView的高度
    var headerHeight: CGFloat = 0
    var isRefreshHeader = false
    
    // 临界点
    var criticalPoint: CGFloat = 0
    var criticalOffset: CGPoint = .zero
    
    var allScrollViews = [UIScrollView]()
    
    var isListNeedScroll: Bool = false
    
    public init(delegate: GKPageScrollViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.initSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.mainTableView.frame.equalTo(self.bounds) { return }
        self.mainTableView.frame = self.bounds
        if !self.isLoaded { return }
        if self.isShowInFooter {
            self.mainTableView.tableFooterView = self.getPageView()
        }else {
            self.mainTableView.reloadData()
        }
    }
    
    fileprivate func initSubviews() {
        self.mainTableView = GKPageTableView(frame: .zero, style: .plain)
        self.mainTableView.dataSource = self
        self.mainTableView.delegate = self
        self.mainTableView.separatorStyle = .none
        self.mainTableView.showsVerticalScrollIndicator = false
        self.mainTableView.showsHorizontalScrollIndicator = false
        self.mainTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        if #available(iOS 11.0, *) {
            self.mainTableView.contentInsetAdjustmentBehavior = .never
        }
        if #available(iOS 15.0, *) {
            self.mainTableView.setValue(0, forKey: "sectionHeaderTopPadding")
        }
        self.addSubview(mainTableView)
        self.refreshHeaderView()
        
        if self.shouldLazyLoadListView() {
            self.mainTableView.horizontalScrollViewList = [self.listContainerView.scrollView]
        }
    }
    
    // MARK: - Public Methods
    public func refreshHeaderView() {
        let headerView = self.delegate.headerView(in: self)
        self.mainTableView.tableHeaderView = headerView
        self.headerHeight = headerView.frame.size.height
        
        self.criticalPoint = abs(self.mainTableView.rect(forSection: 0).origin.y - self.ceilPointHeight)
        self.criticalOffset = CGPoint(x: 0, y: self.criticalPoint)
        
        if isRestoreWhenRefreshHeader {
            scrollToOriginalPoint(false)
        }else {
            if isKeepCriticalWhenRefreshHeader && isCeilPoint {
                isRefreshHeader = true
                scrollToCriticalPoint(false)
            }
        }
    }
    
    public func refreshSegmentedView() {
        if self.shouldLazyLoadListView() {
            let segmentedView = self.delegate.segmentedView?(in: self)
            
            var frame = self.listContainerView.frame
            frame.origin.y = segmentedView!.frame.size.height
            self.listContainerView.frame = frame
        }
    }
    
    public func reloadData() {
        self.isLoaded = true
        
        for list in self.validListDict.values {
            list.listView!().removeFromSuperview()
        }
        validListDict.removeAll()
        
        // 设置列表加载方式
        if self.shouldLazyLoadListView() {
            self.listContainerView.reloadData()
        }else {
            self.configListViewScroll()
        }
        
        if self.isShowInFooter {
            self.mainTableView.tableFooterView = self.getPageView()
        }else {
            self.mainTableView.reloadData()
        }
        
        self.criticalPoint = abs(self.mainTableView.rect(forSection: 0).origin.y - self.ceilPointHeight)
        self.criticalOffset = CGPoint(x: 0, y: self.criticalPoint)
        
        if (!self.isAutoFindHorizontalScrollView) { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.findHorizontalScrollViews()
        }
    }
    
    public func horizonScrollViewWillBeginScroll() {
        self.mainTableView.isScrollEnabled = false
    }
    
    public func horizonScrollViewDidEndedScroll() {
        self.mainTableView.isScrollEnabled = true
    }
    
    public func scrollToOriginalPoint(_ animated: Bool? = true) {
        // 这里做了0.01秒的延时，是为了解决一个坑：
        // 当通过手势滑动结束调用此方法时，会有可能出现动画结束后UITableView没有回到原点的bug
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if self.mainTableView.contentOffset == .zero { return }
            if self.isScrollToOriginal { return }
            
            if animated == true {
                self.isScrollToOriginal = true
            }
            
            if self.isScrollToCritical {
                self.isScrollToCritical = false
            }
            
            self.isCeilPoint     = false
            self.isCriticalPoint = false
            self.isMainCanScroll = true
            self.isListCanScroll = false
            
            self.mainTableView.setContentOffset(.zero, animated: animated ?? true)
        }
    }
    
    public func scrollToCriticalPoint(_ animated: Bool? = true) {
        if (self.mainTableView.contentOffset == self.criticalOffset) { return }
        if self.isScrollToCritical { return }
        
        if animated == true {
            self.isScrollToCritical = true
        }else {
            self.isCeilPoint = true
            self.isCriticalPoint = true
        }
        
        if self.isScrollToOriginal {
            self.isScrollToOriginal = false
        }
        
        self.mainTableView.setContentOffset(self.criticalOffset, animated: animated ?? true)
        
        self.isMainCanScroll = false
        self.isListCanScroll = true
        
        self.mainTableViewCanScrollUpdate()
    }
    
    public func listScrollViewDidScroll(scrollView: UIScrollView) {
        self.currentListScrollView = scrollView
        
        if self.isListScrollViewNeedScroll() { return }
        
        if self.isMainScrollDisabled { return }
        
        if self.isScrollToOriginal || self.isScrollToCritical { return }
        
        // 获取listScrollView偏移量
        let offsetY = scrollView.contentOffset.y
        
        // listScrollView下滑至offsetY小于0，禁止其滑动，让mainTableView可下滑
        if offsetY <= 0 {
            if self.isDisableMainScrollInCeil {
                if self.isAllowListRefresh && offsetY <= 0 && self.isCeilPoint {
                    self.isMainCanScroll = false
                    self.isListCanScroll = true
                }else {
                    self.isMainCanScroll = true
                    self.isListCanScroll = false
                    
                    self.set(scrollView: scrollView, offset: .zero)
                    if self.isControlVerticalIndicator {
                        scrollView.showsVerticalScrollIndicator = false
                    }
                }
            }else {
                if self.isAllowListRefresh && offsetY < 0 && self.mainTableView.contentOffset.y == 0 {
                    self.isMainCanScroll = false
                    self.isListCanScroll = true
                }else {
                    self.isMainCanScroll = true
                    self.isListCanScroll = false
                    
                    self.set(scrollView: scrollView, offset: .zero)
                    if self.isControlVerticalIndicator {
                        scrollView.showsVerticalScrollIndicator = false
                    }
                }
            }
        }else {
            if self.isListCanScroll {
                if self.isControlVerticalIndicator {
                    scrollView.showsVerticalScrollIndicator = true
                }
                
                let headerHeight = self.headerHeight
                
                if floor(headerHeight) == 0 {
                    self.set(scrollView: self.mainTableView, offset: self.criticalOffset)
                }else {
                    // 如果此时mainTableView并没有滑动，则禁止listView滑动
                    if self.mainTableView.contentOffset.y == 0 && floor(headerHeight) != 0 {
                        self.isMainCanScroll = true
                        self.isListCanScroll = false
                        
                        self.set(scrollView: scrollView, offset: .zero)
                        if self.isControlVerticalIndicator {
                            scrollView.showsVerticalScrollIndicator = false
                        }
                    }else { // 矫正mainTableView的位置
                        self.set(scrollView: self.mainTableView, offset: self.criticalOffset)
                    }
                }
            }else {
                self.set(scrollView: scrollView, offset: .zero)
            }
        }
    }
    
    public func mainScrollViewDidScroll(scrollView: UIScrollView) {
        if !self.isBeginDragging {
            if isRefreshHeader || isListNeedScroll {
                isRefreshHeader = false
                isListNeedScroll = false
            }else {
                self.listScrollViewOffsetFixed()                
            }
            
            self.mainTableViewCanScrollUpdate()
            return
        }
        
        // 获取mainScrollView偏移量
        let offsetY = scrollView.contentOffset.y
        
        if self.isScrollToOriginal || self.isScrollToCritical {return}
        
        // 根据偏移量判断是否上滑到临界点
        if offsetY >= self.criticalPoint {
            self.isCriticalPoint = true
        }else {
            self.isCriticalPoint = false
        }
        
        // 无偏差临界点，对float值取整判断
        if !self.isCeilPoint {
            if round(offsetY) == round(self.criticalPoint) {
                self.isCeilPoint = true
            }
        }
        
        if self.isCriticalPoint {
            // 上滑到临界点后，固定其位置
            self.set(scrollView: scrollView, offset: self.criticalOffset)
            self.isMainCanScroll = false
            self.isListCanScroll = true
        }else {
            // 当滑动到无偏差临界点且不允许mainScrollView滑动时做处理
            if self.isCeilPoint && self.isDisableMainScrollInCeil {
                self.isMainCanScroll = false
                self.isListCanScroll = true
                self.set(scrollView: scrollView, offset: self.criticalOffset)
            }else {
                if self.isDisableMainScrollInCeil {
                    if self.isMainCanScroll {
                        // 未达到临界点，mainTableView可滑动，需要重置所有listScrollView的位置
                        self.listScrollViewOffsetFixed()
                    }else {
                        // 未到达临界点，mainScrollView不可滑动，固定mainScrollView的位置
                        self.mainScrollViewOffsetFixed()
                    }
                }else {
                    // 如果允许列表刷新，且mainTableView的offsetY小于0 或者 当前列表的offsetY小于0，mainTableView不可滑动
                    if self.isAllowListRefresh && ((offsetY <= 0 && self.isMainCanScroll) || (self.currentListScrollView.contentOffset.y < 0 && self.isListCanScroll)) {
                        self.set(scrollView: scrollView, offset: .zero)
                    }else {
                        if self.isMainCanScroll {
                            // 未达到临界点，mainTableView可滑动，需要重置所有listScrollView的位置
                            self.listScrollViewOffsetFixed()
                        }else {
                            // 未到达临界点，mainScrollView不可滑动，固定mainScrollView的位置
                            self.mainScrollViewOffsetFixed()
                        }
                    }
                }
            }
        }
        self.mainTableViewCanScrollUpdate()
    }
    
    // MARK: - Private Methods
    fileprivate func configListViewScroll() {
        guard let list = delegate.listView?(in: self) else { return }
        list.forEach {
            $0.listViewDidScroll { [weak self] scrollView in
                self?.listScrollViewDidScroll(scrollView: scrollView)
            }
        }
    }
    
    // 修正mainTableView的位置
    fileprivate func mainScrollViewOffsetFixed() {
        set(scrollView: mainTableView, offset: criticalOffset)
    }
    
    fileprivate func listScrollViewOffsetFixed() {
        if shouldLazyLoadListView() {
            validListDict.forEach {
                let scrollView = $0.value.listScrollView()
                set(scrollView: scrollView, offset: .zero)
                if isControlVerticalIndicator {
                    scrollView.showsVerticalScrollIndicator = false
                }
            }
        }else {
            if (!self.isLoaded) { return }
            guard let list = self.delegate.listView?(in: self) else { return }
            list.forEach {
                let scrollView = $0.listScrollView()
                set(scrollView: scrollView, offset: .zero)
                if isControlVerticalIndicator {
                    scrollView.showsVerticalScrollIndicator = false
                }
            }
        }
    }
    
    fileprivate func mainTableViewCanScrollUpdate() {
        self.delegate.mainTableViewDidScroll?(self.mainTableView, isMainCanScroll: self.isMainCanScroll)
    }
    
    fileprivate func shouldLazyLoadListView() -> Bool {
        if self.delegate.shouldLazyLoadList?(in: self) ?? false {
            return self.delegate.shouldLazyLoadList!(in: self)
        }else {
            return self.isLazyLoadList
        }
    }
    
    fileprivate func set(scrollView: UIScrollView, offset: CGPoint) {
        if !__CGPointEqualToPoint(scrollView.contentOffset, offset) {
            scrollView.contentOffset = offset
        }
    }
    
    fileprivate func getPageView() -> UIView? {
        let width = self.frame.size.width == 0 ? GKPage_Screen_Width : self.frame.size.width
        var height = self.frame.size.height == 0 ? GKPage_Screen_Height : self.frame.size.height
        
        var pageView = self.pageView
        if self.shouldLazyLoadListView() {
            if (pageView == nil) {
                pageView = UIView()
            }
            
            if let segmentedView = delegate.segmentedView?(in: self) {
                let x: CGFloat = 0
                let y: CGFloat = segmentedView.frame.size.height
                let w: CGFloat = width
                var h: CGFloat = height - y
                h -= (self.isMainScrollDisabled ? self.headerHeight : self.ceilPointHeight)
                self.listContainerView.frame = CGRect(x: x, y: y, width: w, height: h)
                pageView?.addSubview(segmentedView)
                pageView?.addSubview(listContainerView)
            }
        }else {
            pageView = (self.delegate.pageView?(in: self))!
        }
        height -= (self.isMainScrollDisabled ? self.headerHeight : self.ceilPointHeight)
        pageView?.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.pageView = pageView
        return pageView
    }
    
    fileprivate func findHorizontalScrollViews() {
        allScrollViews.removeAll()
        findHorizontalScrollViews(mainTableView)
        mainTableView.horizontalScrollViewList = allScrollViews
    }
    
    fileprivate func findHorizontalScrollViews(_ view: UIView) {
        view.subviews.forEach {
            if ($0.isKind(of: UIScrollView.self)) {
                let scrollView = $0 as! UIScrollView
                if (scrollView.contentSize.width > scrollView.frame.size.width) {
                    allScrollViews.append(scrollView)
                }
            }
            if ($0.subviews.count > 0) {
                findHorizontalScrollViews($0)
            }
        }
    }
    
    fileprivate func isListScrollViewNeedScroll() -> Bool {
        var isNeedScroll = false
        self.validListDict.values.forEach {
            if $0.listScrollView() == self.currentListScrollView {
                isNeedScroll = $0.isListScrollViewNeedScroll?() ?? false
            }
        }
        if isNeedScroll {
            self.isListNeedScroll = true
            scrollToCriticalPoint(false)
        }
        return isNeedScroll
    }
}

extension GKPageScrollView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isShowInFooter {
            return 0
        }
        return self.isLoaded ? 1 : 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        self.delegate.pageScrollViewUpdateCell?(self, cell: cell)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        if let pageView = getPageView() {
            cell.contentView.addSubview(pageView)
        }
        self.delegate.pageScrollViewReloadCell?(self)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isShowInFooter {
            return 0
        }
        var height = self.frame.size.height == 0 ? GKPage_Screen_Height : self.frame.size.height
        height -= (self.isMainScrollDisabled ? self.headerHeight : self.ceilPointHeight)
        return height
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.mainScrollViewDidScroll(scrollView: scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isBeginDragging = true
        if self.isScrollToOriginal {
            self.isScrollToOriginal = false
            self.isCeilPoint = false
        }
        
        if self.isScrollToCritical {
            self.isScrollToCritical = false
            self.isCeilPoint = true
        }
        
        self.delegate.mainTableViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.isBeginDragging = false
        }
        self.delegate.mainTableViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isBeginDragging = false
        self.delegate.mainTableViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.delegate.mainTableViewDidEndScrollingAnimation?(scrollView)
        if self.isScrollToOriginal {
            self.isScrollToOriginal = false
            self.isCeilPoint = false
            
            // 修正listView偏移
            self.listScrollViewOffsetFixed()
        }
        
        if self.isScrollToCritical {
            self.isScrollToCritical = false
            self.isCeilPoint = true
        }
        
        self.mainTableViewCanScrollUpdate()
    }
}

extension GKPageScrollView: GKPageListContainerViewDelegate {
    public func numberOfLists(in listContainerView: GKPageListContainerView) -> Int {
        return self.delegate.numberOfLists?(in: self) ?? 0
    }
    
    public func listContainerView(_ listContainerView: GKPageListContainerView, initListAt index: Int) -> GKPageListViewDelegate {
        var list = validListDict[index]
        if list == nil {
            list = self.delegate.pageScrollView?(self, initListAtIndex: index)
            list?.listViewDidScroll(callBack: { [weak self ] scrollView in
                self?.listScrollViewDidScroll(scrollView: scrollView)
            })
            validListDict[index] = list
        }
        return list!
    }
    
    public func listContainerView(_ containerView: GKPageListContainerView, listDidAppearAt index: Int) {
        guard let list = validListDict[index] else { return }
        currentListScrollView = list.listScrollView()
    }
}
