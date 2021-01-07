//
//  GKPageScrollView.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/20.
//  Copyright © 2019 gaokun. All rights reserved.
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
}

open class GKPageScrollView: UIView {
    open weak var delegate: GKPageScrollViewDelegate?
    // 主列表
    open var mainTableView: GKPageTableView!
    // 当前滑动的子列表
    open var currentListScrollView = UIScrollView()
    // 懒加载时使用的容器
    open lazy var listContainerView: GKPageListContainerView = {
        let containerView = GKPageListContainerView(delegate: self)
        return containerView
    }()
    
    // 需要处理滑动冲突的UIScrollView列表
    open var horizontalScrollViewList: [UIScrollView]? {
        didSet {
            var list = horizontalScrollViewList
            if self.shouldLazyLoadListView() {
                list?.append(self.listContainerView.collectionView)
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
    
    // 是否懒加载列表
    public var isLazyLoadList: Bool = false {
        didSet {
            if self.shouldLazyLoadListView() {
                self.mainTableView.horizontalScrollViewList = [self.listContainerView.collectionView]
            }else {
                // 处理listView滑动
                self.configListViewScroll()
            }
        }
    }
    
    // 是否内部控制指示器的显示与隐藏（默认为NO）
    public var isControlVerticalIndicator: Bool = false
    
    // 是否滑动到临界点，可以有偏差
    var isCriticalPoint: Bool = false
    // 是否达到临界点，无偏差
    var isCeilPoint: Bool = false
    // mainTableView是否可以滑动
    var isMainCanScroll: Bool = true
    // listScrollView是否可以滑动
    var isListCanScroll: Bool = false
    
    // 是否开始拖拽，只有在拖拽中才去处理滑动，解决使用mj_header可能出现的bug
    var isBeginDragging: Bool = false
    
    // 快速切换原点和临界点
    var isScrollToOriginal: Bool = false
    var isScrollToCritical: Bool = false
    
    // 是否加载
    var isLoaded: Bool = false
    
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
        self.mainTableView.frame = self.bounds
    }
    
    fileprivate func initSubviews() {
        self.mainTableView = GKPageTableView(frame: .zero, style: .plain)
        self.mainTableView.dataSource = self
        self.mainTableView.delegate = self
        self.mainTableView.separatorStyle = .none
        self.mainTableView.showsVerticalScrollIndicator = false
        self.mainTableView.showsHorizontalScrollIndicator = false
        self.mainTableView.tableHeaderView = self.delegate?.headerView(in: self)
        self.mainTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        if #available(iOS 11.0, *) {
            self.mainTableView.contentInsetAdjustmentBehavior = .never
        }
        self.addSubview(mainTableView)
        
        if self.shouldLazyLoadListView() {
            self.mainTableView.horizontalScrollViewList = [self.listContainerView.collectionView]
        }
    }
    
    // MARK: - Public Methods
    public func refreshHeaderView() {
        self.mainTableView.tableHeaderView = self.delegate?.headerView(in: self)
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
        
        self.mainTableView.reloadData()
    }
    
    public func horizonScrollViewWillBeginScroll() {
        self.mainTableView.isScrollEnabled = false
    }
    
    public func horizonScrollViewDidEndedScroll() {
        self.mainTableView.isScrollEnabled = true
    }
    
    public func scrollToOriginalPoint() {
        // 这里做了0.01秒的延时，是为了解决一个坑：当通过手势滑动结束调用此方法时，会有可能出现动画结束后UITableView没有回到原点的bug
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if self.isScrollToOriginal {return}
            self.isScrollToOriginal = true
            self.isCeilPoint = false
            
            self.isMainCanScroll = true
            self.isListCanScroll = false
            
            self.mainTableView.setContentOffset(.zero, animated: true)
        }
    }
    
    public func scrollToCriticalPoint() {
        if self.isScrollToCritical {return}
        
        self.isScrollToCritical = true
        
        let criticalPoint = self.mainTableView.rect(forSection: 0).origin.y - self.ceilPointHeight
        
        self.mainTableView.setContentOffset(CGPoint(x: 0, y: criticalPoint), animated: true)
        
        self.isMainCanScroll = false
        self.isListCanScroll = true
        
        self.mainTableViewCanScrollUpdate()
    }
    
    public func listScrollViewDidScroll(scrollView: UIScrollView) {
        self.currentListScrollView = scrollView
        
        if self.isScrollToOriginal || self.isScrollToCritical {return}
        
        // 获取listScrollView偏移量
        let offsetY = scrollView.contentOffset.y
        
        // listScrollView下滑至offsetY小于0，禁止其滑动，让mainTableView可下滑
        if offsetY <= 0 {
            if self.isDisableMainScrollInCeil {
                if self.isAllowListRefresh && offsetY < 0 && self.isCeilPoint {
                    self.isMainCanScroll = false
                    self.isListCanScroll = true
                }else {
                    self.isMainCanScroll = true
                    self.isListCanScroll = false

                    scrollView.contentOffset = .zero
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

                    if (scrollView.isDecelerating) { return }
                    scrollView.contentOffset = .zero
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
                
                let headerHeight = self.delegate?.headerView(in: self).frame.size.height
                
                if floor(headerHeight ?? 0) == 0 {
                    let criticalPoint = self.mainTableView.rect(forSection: 0).origin.y - self.ceilPointHeight
                    self.mainTableView.contentOffset = CGPoint(x: 0, y: criticalPoint)
                }else {
                    // 如果此时mainTableView并没有滑动，则禁止listView滑动
                    if self.mainTableView.contentOffset.y == 0 && floor(headerHeight ?? 0) != 0 {
                        self.isMainCanScroll = true
                        self.isListCanScroll = false

                        if (scrollView.isDecelerating) { return }
                        scrollView.contentOffset = .zero
                        if self.isControlVerticalIndicator {
                            scrollView.showsVerticalScrollIndicator = false
                        }
                    }else { // 矫正mainTableView的位置
                        let criticalPoint = self.mainTableView.rect(forSection: 0).origin.y - self.ceilPointHeight
                        self.mainTableView.contentOffset = CGPoint(x: 0, y: criticalPoint)
                    }
                }
            }else {
                if (scrollView.isDecelerating) { return }
                scrollView.contentOffset = .zero
            }
        }
    }
    
    public func mainScrollViewDidScroll(scrollView: UIScrollView) {
        if !self.isBeginDragging {
            // 点击状态栏滑动
            self.listScrollViewOffsetFixed()
            
            self.mainTableViewCanScrollUpdate();
            
            return;
        }
        
        // 获取mainScrollView偏移量
        let offsetY = scrollView.contentOffset.y
        // 临界点
        let criticalPoint = self.mainTableView.rect(forSection: 0).origin.y - self.ceilPointHeight
        
        if self.isScrollToOriginal || self.isScrollToCritical {return}
        
        // 根据偏移量判断是否上滑到临界点
        if offsetY >= criticalPoint {
            self.isCriticalPoint = true
        }else {
            self.isCriticalPoint = false
        }
        
        // 无偏差临界点，对float值取整判断
        if !self.isCeilPoint {
            if floor(offsetY) == floor(criticalPoint) {
                self.isCeilPoint = true
            }
        }
        
        if self.isCriticalPoint {
            // 上滑到临界点后，固定其位置
            scrollView.contentOffset = CGPoint(x: 0, y: criticalPoint)
            self.isMainCanScroll = false
            self.isListCanScroll = true
        }else {
            // 当滑动到无偏差临界点且不允许mainScrollView滑动时做处理
            if self.isCeilPoint && self.isDisableMainScrollInCeil {
                self.isMainCanScroll = false
                self.isListCanScroll = true
                scrollView.contentOffset = CGPoint(x: 0, y: criticalPoint)
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
                        scrollView.contentOffset = .zero
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
        if (self.delegate!.listView?(in: self).count) ?? 0 > 0 {
            for (_, value) in (self.delegate!.listView?(in: self).enumerated())! {
                value.listViewDidScroll { (scrollView) in
                    self.listScrollViewDidScroll(scrollView: scrollView)
                }
            }
        }
    }
    
    // 修正mainTableView的位置
    fileprivate func mainScrollViewOffsetFixed() {
        // 获取临界点位置
        let criticalPoint = self.mainTableView.rect(forSection: 0).origin.y - self.ceilPointHeight
        
        if self.shouldLazyLoadListView() {
            for listItem in self.validListDict.values {
                let listScrollView = listItem.listScrollView()
                if listScrollView.contentOffset.y != 0 {
                    self.mainTableView.contentOffset = CGPoint(x: 0, y: criticalPoint)
                }
            }
        }else {
            if self.delegate!.listView?(in: self).count ?? 0 > 0 {
                for (_, value) in (self.delegate!.listView?(in: self).enumerated())! {
                    let listScrollView = value.listScrollView()
                    
                    if listScrollView.contentOffset.y != 0 {
                        self.mainTableView.contentOffset = CGPoint(x: 0, y: criticalPoint)
                    }
                }
            }
        }
    }
    
    fileprivate func listScrollViewOffsetFixed() {
        if self.shouldLazyLoadListView() {
            for listItem in self.validListDict.values {
                let listScrollView = listItem.listScrollView()
                listScrollView.contentOffset = .zero
                if self.isControlVerticalIndicator {
                    listScrollView.showsVerticalScrollIndicator = false
                }
            }
        }else {
            if self.delegate!.listView?(in: self).count ?? 0 > 0 {
                for (_, value) in (self.delegate!.listView?(in: self).enumerated())! {
                    let listScrollView = value.listScrollView()
                    listScrollView.contentOffset = .zero
                    if self.isControlVerticalIndicator {
                        listScrollView.showsVerticalScrollIndicator = false
                    }
                }
            }
        }
    }
    
    fileprivate func mainTableViewCanScrollUpdate() {
        self.delegate!.mainTableViewDidScroll?(self.mainTableView, isMainCanScroll: self.isMainCanScroll)
    }
    
    fileprivate func shouldLazyLoadListView() -> Bool {
        if self.delegate?.shouldLazyLoadList?(in: self) ?? false {
            return self.delegate!.shouldLazyLoadList!(in: self)
        }else {
            return self.isLazyLoadList
        }
    }
}

extension GKPageScrollView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isLoaded ? 1 : 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        let width = self.frame.size.width == 0 ? GKPage_Screen_Width : self.frame.size.width
        let height = self.frame.size.height == 0 ? GKPage_Screen_Height : self.frame.size.height
        
        let pageView: UIView
        if self.shouldLazyLoadListView() {
            pageView = UIView()
            
            let segmentedView = self.delegate!.segmentedView?(in: self)
            
            let x: CGFloat = 0
            let y: CGFloat = segmentedView!.frame.size.height
            let w: CGFloat = width
            let h: CGFloat = height - self.ceilPointHeight - y
            
            self.listContainerView.frame = CGRect(x: x, y: y, width: w, height: h)
            pageView.addSubview(segmentedView!)
            pageView.addSubview(self.listContainerView)
        }else {
            pageView = (self.delegate!.pageView?(in: self))!
        }
        pageView.frame = CGRect(x: 0, y: 0, width: width, height: height - self.ceilPointHeight)
        cell.contentView.addSubview(pageView)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.frame.size.height == 0 ? GKPage_Screen_Height : self.frame.size.height
        return height - self.ceilPointHeight
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
        
        self.delegate!.mainTableViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.isBeginDragging = false
        }
        self.delegate!.mainTableViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isBeginDragging = false
        self.delegate!.mainTableViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.delegate!.mainTableViewDidEndScrollingAnimation?(scrollView)
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
    public func numberOfRows(in listContainerView: GKPageListContainerView) -> Int {
        return (self.delegate!.numberOfLists?(in: self))!
    }
    
    public func listContainerView(_ listContainerView: GKPageListContainerView, viewForListInRow row: Int) -> UIView {
        var list = self.validListDict[row]
        if list == nil {
            list = self.delegate!.pageScrollView?(self, initListAtIndex: row)
            list?.listViewDidScroll(callBack: {[weak self] (scrollView) in
                self?.listScrollViewDidScroll(scrollView: scrollView)
            })
            validListDict[row] = list!
        }
        return list!.listView!()
    }
}
