//
//  GKBaseListViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import MJRefresh

class GKBaseListViewController: GKBaseTableViewController {

    public var count = 30
    
    public var shouldLoadData = false
    
    var scrollCallBack: ((UIScrollView) -> ())?
    
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

        self.gk_navigationBar.isHidden = true
        
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "listCell")
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + kRefreshDuration, execute: {
                self.count += 20
                
                if self.count >= 100 {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer?.endRefreshing()
                }
                self.tableView.reloadData()
            })
        })
        
        if self.shouldLoadData {
            self.tableView.addSubview(self.loadingView)
            self.tableView.addSubview(self.loadLabel)
            
            self.loadingView.snp.makeConstraints { (make) in
                make.top.equalTo(self.tableView).offset(40.0)
                make.centerX.equalTo(self.tableView)
            }
            
            self.loadLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.loadingView.snp.bottom).offset(10.0)
                make.centerX.equalTo(self.loadingView)
            }
            
            self.loadData()
        }
    }
    
    func loadData() {
        self.count = 0
        
        self.showLoading()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.count = 30
            
            self.hideLoading()
            
            self.tableView.reloadData()
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
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + kRefreshDuration, execute: {
                self.tableView.mj_header?.endRefreshing()
                
                self.count = 30
                self.tableView.reloadData()
            })
        })
    }
}

extension GKBaseListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView.mj_footer?.isHidden = self.count == 0
        return self.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.textLabel?.text = "第" + "\(indexPath.row+1)" + "行"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallBack!(scrollView)
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
