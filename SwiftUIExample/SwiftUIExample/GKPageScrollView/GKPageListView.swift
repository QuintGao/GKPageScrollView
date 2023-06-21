//
//  GKPageListView.swift
//  SwiftUIExample
//
//  Created by QuintGao on 2023/6/21.
//

import UIKit
import GKPageScrollView
import SnapKit

class GKPageListView: UIView {
    var scrollCallback: ((UIScrollView) -> ())?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
}

extension GKPageListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "第\(indexPath.row + 1)行"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView)
    }
}

extension GKPageListView: GKPageListViewDelegate {
    func listView() -> UIView {
        self
    }
    
    func listScrollView() -> UIScrollView {
        UIScrollView()
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        scrollCallback = callBack
    }
}
