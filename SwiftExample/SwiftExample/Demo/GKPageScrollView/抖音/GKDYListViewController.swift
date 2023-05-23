//
//  GKDYListViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/26.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import GKPageScrollView

class GKDYListViewController: GKBaseTableViewController {

    var scrollCallBack: ((UIScrollView) -> ())?
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.gk_navigationBar.isHidden = true
        
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "listCell")
    }
}

extension GKDYListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = "第" + "\(indexPath.row + 1)" + "行"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallBack!(scrollView)
    }
}

extension GKDYListViewController: GKPageListViewDelegate {
    func listScrollView() -> UIScrollView {
        self.tableView
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        self.scrollCallBack = callBack
    }
    
    func listView() -> UIView {
        self.view
    }
    
    func listWillAppear() {
        print("\(index)===listWillAppear")
    }
    
    func listDidAppear() {
        print("\(index)===listDidAppear")
    }
    
    func listWillDisappear() {
        print("\(index)===listWillDisappear")
    }
    
    func listDidDisappear() {
        print("\(index)===listDidDisappear")
    }
}
