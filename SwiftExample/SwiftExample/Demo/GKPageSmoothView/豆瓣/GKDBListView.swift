//
//  GKDBListView.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2020/12/23.
//  Copyright © 2020 QuintGao. All rights reserved.
//

import UIKit
import GKPageSmoothView

enum GKDBListType {
    case scrollView
    case tableView
    case collectionView
}

class GKDBListView: UIView {
    
    var type: GKDBListType = .tableView
    
//    var listScrollView: UIScrollView?
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = GKBaseCollectionViewLayout()
        layout.itemSize = CGSizeMake((kScreenW  - 30)/2, (kScreenW  - 30) / 2)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    convenience init(type: GKDBListType) {
        self.init()
        self.type = type
        initUI()
    }
    
    func initUI() {
        if type == .tableView {
            scrollView = tableView
        }else {
            scrollView = collectionView
        }
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
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

extension GKDBListView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
}

extension GKDBListView: GKPageSmoothListViewDelegate {
    func listView() -> UIView {
        return self
    }
    
    func listScrollView() -> UIScrollView {
        return self.scrollView
    }
}
