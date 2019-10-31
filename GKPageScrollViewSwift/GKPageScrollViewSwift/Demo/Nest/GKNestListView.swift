//
//  GKNestListView.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/10/18.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import VTMagic

class GKNestListView: UIView {

    var scrollCallBack: ((UIScrollView) -> ())?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GKNestListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "你好，这是第" + "\(indexPath.row+1)" + "行cell"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallBack!(scrollView)
    }
}

extension GKNestListView: GKPageListViewDelegate {
    func listView() -> UIView {
        return self
    }
    
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        scrollCallBack = callBack
    }
}
