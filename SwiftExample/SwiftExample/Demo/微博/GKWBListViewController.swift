//
//  GKWBListViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import MJRefresh

class GKWBListViewController: GKDemoBaseViewController {

    public var isCanScroll = false
    
    lazy var tableView: UITableView! = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "listCell")
        tableView.rowHeight = 60.0
        return tableView
    }()
    
    var scrollCallBack: ((UIScrollView) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navigationBar.isHidden = true
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        if self.isCanScroll {
            self.tableView.mj_header = MJRefreshNormalHeader.init {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.tableView.reloadData()
                    self.tableView.mj_header?.endRefreshing()
                })
            }
        }
    }
}

extension GKWBListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.textLabel?.text = "第" + "\(indexPath.row)" + "行"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollCallBack != nil {
            scrollCallBack!(scrollView)
        }
    }
}

extension GKWBListViewController: GKPageListViewDelegate {
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        scrollCallBack = callBack
    }
}
