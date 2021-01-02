//
//  GKDBListView.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2020/12/23.
//  Copyright © 2020 gaokun. All rights reserved.
//

import UIKit
import GKPageSmoothView

class GKDBListView: UIView {
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GKDBListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "第\(indexPath.row)行"
        return cell
    }
}

extension GKDBListView: GKPageSmoothListViewDelegate {
    func listView() -> UIView {
        return self
    }
    
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
}
