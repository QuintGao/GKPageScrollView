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
    
    var scrollCallBack: ((UIScrollView) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gk_navigationBar.isHidden = true
        
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "listCell")
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + kRefreshDuration, execute: {
                self.count += 20
                
                if self.count >= 100 {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer.endRefreshing()
                }
                self.tableView.reloadData()
            })
        })
    }
    
    public func addHeaderRefresh() {
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + kRefreshDuration, execute: {
                self.tableView.mj_header.endRefreshing()
                
                self.count = 30
                self.tableView.reloadData()
            })
        })
    }
}

extension GKBaseListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        scrollCallBack = callBack
    }
}
