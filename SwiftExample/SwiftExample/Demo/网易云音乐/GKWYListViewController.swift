//
//  GKWYListViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/22.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import GKPageScrollView

class GKWYListViewController: GKBaseTableViewController {

    var scrollCallBack: ((UIScrollView) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gk_navigationBar.isHidden = true
        
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "listCell")
        self.tableView.showsVerticalScrollIndicator = false
    }
}

extension GKWYListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = "第" + "\(indexPath.row+1)" + "行"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallBack!(scrollView)
    }
}

extension GKWYListViewController: GKPageListViewDelegate {
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        scrollCallBack = callBack
    }
}
