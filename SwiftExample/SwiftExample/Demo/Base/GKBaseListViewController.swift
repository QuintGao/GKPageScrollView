//
//  GKBaseListViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import MJRefresh
import WebKit
import GKPageScrollView

enum GKBaseListType: Int {
    case UITableView
    case UICollectionView
    case UIScrollView
    case WKWebView
}

class GKBaseListViewController: UIViewController {

    init(listType: GKBaseListType) {
        super.init(nibName: nil, bundle: nil)
        self.listType = listType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var listType: GKBaseListType = .UIScrollView
    private weak var currentScrollView: UIScrollView?
    
    public var count = 30
    
    public var shouldLoadData = false
    
    var scrollCallBack: ((UIScrollView) -> ())?
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "tableViewCell")
        return tableView
    }()
    
    public lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.itemSize = CGSize(width: (kScreenW - 60)/2, height: (kScreenW - 60)/2)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "collectionViewCell")
        collectionView.backgroundColor = .white
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    public lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.delegate = self
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        webView.navigationDelegate = self
        return webView
    }()
    
    lazy var loadingView: UIImageView = {
        var images = [UIImage]()
        for i in 0..<4 {
            let imgName = "cm2_list_icn_loading" + "\(i+1)"
            
            let img = changeColor(image: UIImage(named: imgName)!, color: UIColor.rgbColor(r: 200, g: 38, b: 39))
            images.append(img)
        }
        
        for i in (0..<4).reversed() {
            let imgName = "cm2_list_icn_loading" + "\(i+1)"
            
            let img = changeColor(image: UIImage(named: imgName)!, color: UIColor.rgbColor(r: 200, g: 38, b: 39))
            images.append(img)
        }
        
        let loadingView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20.0, height: 20.0))
        loadingView.animationImages = images
        loadingView.animationDuration = 0.75
        loadingView.isHidden = true
        
        return loadingView
    }()
    
    lazy var loadLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.gray
        label.text = "正在加载..."
        label.isHidden = true
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.listType == .UITableView {
            self.view.addSubview(self.tableView)
            self.currentScrollView = self.tableView
        }else if self.listType == .UICollectionView {
            self.view.addSubview(self.collectionView)
            self.currentScrollView = self.collectionView
        }else if self.listType == .UIScrollView {
            self.view.addSubview(self.scrollView)
            self.currentScrollView = self.scrollView
        }else if self.listType == .WKWebView {
            self.view.addSubview(self.webView)
            self.currentScrollView = self.webView.scrollView
        }
        
        if self.listType == .WKWebView {
            self.webView.snp.makeConstraints { (make) in
                make.edges.equalTo(self.view)
            }
        }else {
            self.currentScrollView?.snp.makeConstraints({ (make) in
                make.edges.equalTo(self.view)
            })
        }
        
        if self.listType != .WKWebView {
            self.currentScrollView?.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
                DispatchQueue.main.asyncAfter(deadline: .now() + kRefreshDuration) {
                    self.loadMoreData()
                }
            })
        }
        
        if self.shouldLoadData {
            self.currentScrollView!.addSubview(self.loadingView)
            self.currentScrollView!.addSubview(self.loadLabel)
            
            self.loadingView.snp.makeConstraints { (make) in
                make.top.equalTo(self.currentScrollView!).offset(40.0)
                make.centerX.equalTo(self.currentScrollView!)
            }
            
            self.loadLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.loadingView.snp.bottom).offset(10.0)
                make.centerX.equalTo(self.loadingView)
            }
            
            self.count = 0
            self.currentScrollView?.mj_footer?.isHidden = self.count == 0
            self.reloadData()
            
            self.showLoading()
            if self.listType == .WKWebView {
                self.loadData()
            }else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.hideLoading()
                    self.loadData()
                }
            }
        }else {
            self.loadData()
        }
    }
    
    func loadData() {
        self.count = 30
        
        if self.listType == .UIScrollView {
            self.addCellToScrollView()
        }else if self.listType == .WKWebView {
            self.webView.load(URLRequest(url: URL(string: "https://github.com/QuintGao/GKPageScrollView")!))
        }
        self.reloadData()
    }
    
    func loadMoreData() {
        self.count += 20
        
        if self.count >= 100 {
            self.currentScrollView?.mj_footer?.endRefreshingWithNoMoreData()
        }else {
            self.currentScrollView?.mj_footer?.endRefreshing()
        }
        
        if self.listType == .UIScrollView {
            self.addCellToScrollView()
        }
        
        self.reloadData()
    }
    
    func addCellToScrollView() {
        for subView in self.scrollView.subviews {
            subView.removeFromSuperview()
        }
        
        var lastView: UIView?
        for i in 0..<self.count {
            let label = UILabel()
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 16)
            label.text = "第\(i + 1)行"
            self.scrollView.addSubview(label)
            
            label.snp.makeConstraints { (make) in
                make.left.equalTo(30)
                make.top.equalTo(lastView != nil ? lastView!.snp_bottom : 0)
                make.width.equalTo(self.scrollView.snp_width)
                make.height.equalTo(50.0)
            }
            lastView = label
        }
        
        self.scrollView.snp.remakeConstraints { (make) in
            make.edges.equalTo(self.view)
            make.bottom.equalTo(lastView!.snp_bottom)
        }
    }
    
    func reloadData() {
        if self.listType == .UITableView {
            self.tableView.reloadData()
        }else if self.listType == .UICollectionView {
            self.collectionView.reloadData()
        }
    }
    
    func showLoading() {
        self.loadingView.isHidden = false
        self.loadLabel.isHidden = false
        self.loadingView.startAnimating()
    }
    
    func hideLoading() {
        self.loadingView.isHidden = true
        self.loadLabel.isHidden = true
        self.loadingView.stopAnimating()
    }
    
    public func addHeaderRefresh() {
        self.currentScrollView!.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + kRefreshDuration, execute: {
                self.currentScrollView!.mj_header?.endRefreshing()
                
                self.count = 30
                self.reloadData()
            })
        })
    }
}

extension GKBaseListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView.mj_footer?.isHidden = self.count == 0
        return self.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = "第\(indexPath.row+1)行"
        return cell
    }
}

extension GKBaseListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collectionView.mj_footer?.isHidden = self.count == 0
        return self.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath)
        cell.contentView.backgroundColor = .red
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        let textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textColor = .black
        textLabel.text = "第\(indexPath.item+1)"
        cell.contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.center.equalTo(cell.contentView)
        }
        return cell
    }
}

extension GKBaseListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallBack!(scrollView)
    }
}

extension GKBaseListViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("加载成功")
        self.hideLoading()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("加载失败")
        self.hideLoading()
    }
}

extension GKBaseListViewController: GKPageListViewDelegate {
    func listView() -> UIView {
        return self.view
    }
    
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        scrollCallBack = callBack
    }
}
