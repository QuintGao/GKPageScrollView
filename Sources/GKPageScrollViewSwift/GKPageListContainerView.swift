//
//  GKPageListContainerView.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2019/3/13.
//  Copyright © 2019 QuintGao. All rights reserved.
//

import UIKit

/**
 列表容器的类型
 - ScrollView：UIScrollView。优势：没有副作用。劣势：实时的视图内存占用相对大一点，因为加载之后的所有列表视图都在视图层级里面
 - CollectionView：UICollectionView。优势：因为列表被添加到cell上，实时的视图内存占用更少。劣势：因为cell的重用机制的问题，导致列表被移除屏幕外之后，会被放入缓存区，而不存在于视图层级中，如果刚好你的列表使用了下拉刷新视图，在快速切换过程中，就会导致下拉刷新回调不成功的问题。
 */
public enum GKPageListContainerType {
    case scrollView
    case collectionView
}

@objc public protocol GKPageListContainerScrollViewGestureDelegate: NSObjectProtocol {
    
    @objc optional func pageListContainerScrollView(_ scrollView: UIScrollView, gestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func pageListContainerScrollView(_ scrollView: UIScrollView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

open class GKPageListContainerCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    open var isNestEnabled = false
    open weak var gestureDelegate: GKPageListContainerScrollViewGestureDelegate?
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = self.gestureDelegate?.pageListContainerScrollView?(self, gestureRecognizerShouldBegin: gestureRecognizer) {
            return result
        }else {
            if isNestEnabled {
                //没有代理，但是isNestEnabled为true
                if gestureRecognizer.isMember(of: NSClassFromString("UIScrollViewPanGestureRecognizer")!) {
                    let panGesture = gestureRecognizer as! UIPanGestureRecognizer
                    let velocityX = panGesture.velocity(in: panGesture.view!).x
                    if velocityX > 0 { // 右滑
                        if self.contentOffset.x == 0 {
                            return false
                        }
                    }else if velocityX < 0 { // 左滑
                        if self.contentOffset.x + self.bounds.size.width == self.contentSize.width {
                            return false
                        }
                    }
                }
            }
        }
        
        if self.panBack(gestureRecognizer: gestureRecognizer) {
            return false
        }
        
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = self.gestureDelegate?.pageListContainerScrollView?(self, gestureRecognizer: gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return result
        }
        
        if self.panBack(gestureRecognizer: gestureRecognizer) {
            return true
        }
        
        return false
    }
    
    func panBack(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGestureRecognizer {
            let point = self.panGestureRecognizer.translation(in: self)
            let state = gestureRecognizer.state
            
            let locationDistance = UIScreen.main.bounds.size.width
            
            if state == .began || state == .possible {
                let location = gestureRecognizer.location(in: self)
                if point.x > 0 && location.x < locationDistance && self.contentOffset.x <= 0 {
                    return true
                }
            }
        }
        return false
    }
}

@objc public protocol GKPageListContainerViewDelegate: NSObjectProtocol {
    func numberOfLists(in listContainerView: GKPageListContainerView) -> Int
    
    func listContainerView(_ listContainerView: GKPageListContainerView, initListAt index: Int) -> GKPageListViewDelegate
    
    // 返回自定义UIScrollView或UICollectionView的class
    @objc optional func scrollViewClass(in listContainerView: GKPageListContainerView) -> AnyClass?
    
    // 控制能否初始化对应index的列表。有些业务需求，需要在某些情况下才能初始化列表，通过改代理实现控制
    @objc optional func listContainerView(_ listContainerView: GKPageListContainerView, canInitListAt index: Int) -> Bool
    
    // 列表显示
    @objc optional func listContainerView(_ containerView: GKPageListContainerView, listDidAppearAt index: Int)
}

open class GKPageListContainerView: UIView {
    public private(set) var type: GKPageListContainerType
    public private(set) weak var delegate: GKPageListContainerViewDelegate?
    public private(set) var scrollView: UIScrollView!
    public var isNestEnabled = false {
        didSet {
            if let scrollView = scrollView as? GKPageListContainerScrollView {
                scrollView.isNestEnabled = isNestEnabled
            }else if let scrollView = scrollView as? GKPageListContainerCollectionView {
                scrollView.isNestEnabled = isNestEnabled
            }
        }
    }
    public weak var gestureDelegate: GKPageListContainerScrollViewGestureDelegate? {
        didSet {
            if let scrollView = scrollView as? GKPageListContainerScrollView {
                scrollView.gestureDelegate = gestureDelegate
            }else if let scrollView = scrollView as? GKPageListContainerCollectionView {
                scrollView.gestureDelegate = gestureDelegate
            }
        }
    }
    /// 已经加载过的列表字典。key是index，value是对应的列表
    open var validListDict = [Int: GKPageListViewDelegate]()
    /// 滚动切换的时候，滚动距离超过一页的多少百分比，就触发列表的初始化。默认0.01（即列表显示了一点就触发加载）。范围0~1，开区间不包括0和1
    open var initListPercent: CGFloat = 0.01 {
        didSet {
            if initListPercent <= 0 || initListPercent >= 1 {
                fatalError("initListPercent值范围为开区间(0,1)，即不包括0和1")
            }
        }
    }
    public var defaultSelectedIndex: Int = 0 {
        didSet {
            currentIndex = defaultSelectedIndex
        }
    }
    public private(set) var currentIndex: Int = 0
    private var collectionView: UICollectionView!
    private var containerVC: GKPageListContainerViewController!
    private var willAppearIndex: Int = -1
    private var willDisappearIndex: Int = -1
    
    public init(delegate: GKPageListContainerViewDelegate, type: GKPageListContainerType = .collectionView) {
        self.delegate = delegate
        self.type = type
        super.init(frame: .zero)
        self.initSubviews()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        guard let delegate = delegate else { return }
        containerVC = GKPageListContainerViewController()
        containerVC.view.backgroundColor = UIColor.clear
        addSubview(containerVC.view)
        containerVC.viewWillAppearClosure = { [weak self] in
            guard let self = self else { return }
            self.listWillAppear(at: self.currentIndex)
        }
        containerVC.viewDidAppearClosure = { [weak self] in
            guard let self = self else { return }
            self.listDidAppear(at: self.currentIndex)
        }
        containerVC.viewWillDisappearClosure = { [weak self] in
            guard let self = self else { return }
            self.listWillDisappear(at: self.currentIndex)
        }
        containerVC.viewDidDisappearClosure = { [weak self] in
            guard let self = self else { return }
            self.listDidDisappear(at: self.currentIndex)
        }
        
        if type == .scrollView {
            if let scrollViewClass = delegate.scrollViewClass?(in: self) as? UIScrollView.Type {
                scrollView = scrollViewClass.init()
            }else {
                scrollView = GKPageListContainerScrollView()
            }
            scrollView.backgroundColor = .clear
            scrollView.delegate = self
            scrollView.isPagingEnabled = true
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.scrollsToTop = false
            scrollView.bounces = false
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            containerVC.view.addSubview(scrollView)
        }else if type == .collectionView {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .horizontal
            
            if let collectionViewClass = delegate.scrollViewClass?(in: self) as? UICollectionView.Type {
                collectionView = collectionViewClass.init(frame: .zero, collectionViewLayout: layout)
            }else {
                collectionView = GKPageListContainerCollectionView(frame: .zero, collectionViewLayout: layout)
            }
            collectionView.backgroundColor = .clear
            collectionView.isPagingEnabled = true
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.scrollsToTop = false
            collectionView.bounces = false
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
            if #available(iOS 10.0, *) {
                collectionView.isPrefetchingEnabled = false
            }
            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = .never
            }
            containerVC.view.addSubview(collectionView)
            // 让外部统一访问scrollView
            scrollView = collectionView
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        var next: UIResponder? = newSuperview
        while next != nil {
            if let vc = next as? UIViewController {
                vc.addChild(containerVC)
                break
            }
            next = next?.next
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let delegate = delegate else { return }
        containerVC.view.frame = bounds
        if type == .scrollView {
            if scrollView.frame == .zero || scrollView.bounds.size != bounds.size {
                scrollView.frame = bounds
                scrollView.contentSize = CGSize(width: scrollView.bounds.size.width * CGFloat(delegate.numberOfLists(in: self)), height: scrollView.bounds.size.height)
                validListDict.forEach {
                    $0.value.listView?().frame = CGRect(x: CGFloat($0.key) * scrollView.bounds.size.width, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
                }
                scrollView.contentOffset = CGPoint(x: CGFloat(currentIndex) * scrollView.bounds.size.width, y: 0)
            }else {
                scrollView.frame = bounds
                scrollView.contentSize = CGSize(width: scrollView.bounds.size.width * CGFloat(delegate.numberOfLists(in: self)), height: scrollView.bounds.size.height)
            }
        }else {
            if collectionView.frame == .zero || collectionView.bounds.size != bounds.size {
                collectionView.frame = bounds
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.reloadData()
                collectionView.contentOffset = CGPoint(x: CGFloat(currentIndex) * collectionView.bounds.size.width, y: 0)
            }else {
                collectionView.frame = bounds
            }
        }
    }
    
    // MARK: - ListContainer
    public func contentScrollView() -> UIScrollView {
        return scrollView
    }
    
    public func scrolling(from leftIndex: Int, to rightIndex: Int, percent: CGFloat, selectedIndex: Int) {
    }
    
    public func didClickSelectedItem(at index: Int) {
        if !checkIndexValid(index) { return }
        willAppearIndex = -1
        willDisappearIndex = -1
        if currentIndex != index {
            listWillDisappear(at: currentIndex)
            listDidDisappear(at: currentIndex)
            listWillAppear(at: index)
            listDidAppear(at: index)
        }
    }
    
    public func reloadData() {
        guard let delegate = delegate else { return }
        if currentIndex < 0 || currentIndex >= delegate.numberOfLists(in: self) {
            defaultSelectedIndex = 0
            currentIndex = 0
        }
        validListDict.values.forEach {
            if let listVC = $0 as? UIViewController {
                listVC.removeFromParent()
            }
            $0.listView?().removeFromSuperview()
        }
        validListDict.removeAll()
        if type == .scrollView {
            scrollView.contentSize = CGSize(width: scrollView.bounds.size.width * CGFloat(delegate.numberOfLists(in: self)), height: scrollView.bounds.size.height)
        }else {
            collectionView.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let self = self else { return }
            self.listWillAppear(at: self.currentIndex)
            self.listDidAppear(at: self.currentIndex)
        }
    }
    
    // MARK: - Private
    func initListIfNeeded(at index: Int) {
        guard let delegate = delegate else { return }
        if delegate.listContainerView?(self, canInitListAt: index) == false {
            return
        }
        var existedList = validListDict[index]
        if existedList != nil {
            return
        }
        existedList = delegate.listContainerView(self, initListAt: index)
        guard let list = existedList else { return }
        if let vc = list as? UIViewController {
            containerVC.addChild(vc)
        }
        validListDict[index] = list
        guard let listView = list.listView?() else { return }
        switch type {
        case .scrollView:
            listView.frame = CGRect(x: CGFloat(index) * scrollView.bounds.size.width, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
            scrollView.addSubview(listView)
        case .collectionView:
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                cell.contentView.subviews.forEach { $0.removeFromSuperview() }
                listView.frame = cell.contentView.bounds
                cell.contentView.addSubview(listView)
            }
        }
    }
    
    private func listWillAppear(at index: Int) {
        guard checkIndexValid(index) else { return }
        let list = validListDict[index]
        if (list == nil) {
            initListIfNeeded(at: index)
            listWillAppear(at: index)
        }else {
            list?.listWillAppear?()
            if let vc = list as? UIViewController {
                vc.beginAppearanceTransition(true, animated: false)
            }
        }
    }
    
    private func listDidAppear(at index: Int) {
        guard checkIndexValid(index) else { return }
        currentIndex = index
        let list = validListDict[index]
        list?.listDidAppear?()
        if let vc = list as? UIViewController {
            vc.endAppearanceTransition()
        }
        delegate?.listContainerView?(self, listDidAppearAt: index)
    }
    
    private func listWillDisappear(at index: Int) {
        guard checkIndexValid(index) else { return }
        let list = validListDict[index]
        list?.listWillDisappear?()
        if let vc = list as? UIViewController {
            vc.beginAppearanceTransition(false, animated: false)
        }
    }
    
    private func listDidDisappear(at index: Int) {
        guard checkIndexValid(index) else { return }
        let list = validListDict[index]
        list?.listDidDisappear?()
        if let vc = list as? UIViewController {
            vc.endAppearanceTransition()
        }
    }
    
    private func checkIndexValid(_ index: Int) -> Bool {
        guard let delegate = delegate else { return false }
        let count = delegate.numberOfLists(in: self)
        if (count <= 0 || index >= count) {
            return false
        }
        return true
    }
    
    private func listDidAppearOrDisappear(scrollView: UIScrollView) {
        let currentIndexPercent = scrollView.contentOffset.x / scrollView.bounds.size.width
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
}

extension GKPageListContainerView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let delegate = delegate else { return 0 }
        return delegate.numberOfLists(in: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let list = validListDict[indexPath.item]
        if let listView = list?.listView?() {
            listView.frame = cell.contentView.bounds
            cell.contentView.addSubview(listView)
        }
        return cell
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating else { return }
        let percent = scrollView.contentOffset.x / scrollView.bounds.size.width
        let maxCount = Int(round(scrollView.contentSize.width / scrollView.bounds.size.width))
        var leftIndex = Int(floor(Double(percent)))
        leftIndex = max(0, min(maxCount - 1, leftIndex))
        let rightIndex = leftIndex + 1
        if (percent < 0 || rightIndex >= maxCount) {
            listDidAppearOrDisappear(scrollView: scrollView)
            return
        }
        let remainderRatio = percent - CGFloat(leftIndex)
        if rightIndex == currentIndex {
            // 当前选中的在右边，用户正在从右往左滑动
            if validListDict[leftIndex] == nil && remainderRatio < (1 - initListPercent) {
                initListIfNeeded(at: leftIndex)
            }else if validListDict[leftIndex] != nil {
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
            if validListDict[rightIndex] == nil && remainderRatio > initListPercent {
                initListIfNeeded(at: rightIndex)
            }else if validListDict[rightIndex] != nil {
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
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 滑动到一半又取消滑动处理
        if (willDisappearIndex != -1) {
            listWillAppear(at: willDisappearIndex)
            listWillDisappear(at: willAppearIndex)
            listDidAppear(at: willDisappearIndex)
            listDidDisappear(at: willAppearIndex)
            willDisappearIndex = -1
            willAppearIndex = -1
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // 滑动到一半又取消滑动处理
            if (willDisappearIndex != -1) {
                listWillAppear(at: willDisappearIndex)
                listWillDisappear(at: willAppearIndex)
                listDidAppear(at: willDisappearIndex)
                listDidDisappear(at: willAppearIndex)
                willDisappearIndex = -1
                willAppearIndex = -1
            }
        }
    }
}

extension GKPageListContainerView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.bounds.size
    }
}

open class GKPageListContainerScrollView: UIScrollView, UIGestureRecognizerDelegate {
    open var isNestEnabled = false
    open weak var gestureDelegate: GKPageListContainerScrollViewGestureDelegate?
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = self.gestureDelegate?.pageListContainerScrollView?(self, gestureRecognizerShouldBegin: gestureRecognizer) {
            return result
        }else {
            if isNestEnabled {
                // 没有代理，但是isNestEnabled为true
                if gestureRecognizer.isMember(of: NSClassFromString("UIScrollViewPanGestureRecognizer")!) {
                    let panGesture = gestureRecognizer as! UIPanGestureRecognizer
                    let velocityX = panGesture.velocity(in: panGesture.view!).x
                    if velocityX > 0 { // 右滑
                        if self.contentOffset.x == 0 {
                            return false
                        }
                    }else if velocityX < 0 { // 左滑
                        if self.contentOffset.x + self.bounds.size.width == self.contentSize.width {
                            return false
                        }
                    }
                }
            }
        }
        
        if self.panBack(gestureRecognizer: gestureRecognizer) {
            return false
        }
        
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = self.gestureDelegate?.pageListContainerScrollView?(self, gestureRecognizer: gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return result
        }
        
        if self.panBack(gestureRecognizer: gestureRecognizer) {
            return true
        }
        
        return false
    }
    
    fileprivate func panBack(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGestureRecognizer {
            let point = self.panGestureRecognizer.translation(in: self)
            let state = gestureRecognizer.state
            
            let locationDistance = UIScreen.main.bounds.size.width
            
            if state == .began || state == .possible {
                let location = gestureRecognizer.location(in: self)
                if point.x > 0 && location.x < locationDistance && self.contentOffset.x <= 0 {
                    return true
                }
            }
        }
        return false
    }
}

class GKPageListContainerViewController: UIViewController {
    var viewWillAppearClosure: (() -> ())?
    var viewDidAppearClosure: (() -> ())?
    var viewWillDisappearClosure: (() -> ())?
    var viewDidDisappearClosure: (() -> ())?
    override var shouldAutomaticallyForwardAppearanceMethods: Bool { return false }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearClosure?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearClosure?()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearClosure?()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidDisappearClosure?()
    }
}
