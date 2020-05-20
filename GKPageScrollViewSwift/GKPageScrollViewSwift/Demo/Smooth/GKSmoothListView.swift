//
//  GKSmoothListView.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2020/5/12.
//  Copyright © 2020 gaokun. All rights reserved.
//

import UIKit
import GKNavigationBarSwift

enum GKSmoothListType: Int {
    case tableView
    case collectionView
    case scrollView
}

class GKSmoothListView: UIView {
    var smoothScrollView: UIScrollView?

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.backgroundColor = .white
        return scrollView
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "tableViewCell")
        tableView.rowHeight = 50.0
        tableView.backgroundColor = .white
        return tableView
    }()

    lazy var collectionView: UICollectionView = {
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

        return collectionView
    }()
    
    let count: Int = 100

    init(listType: GKSmoothListType) {
        super.init(frame: .zero)

        if listType == .scrollView {
            smoothScrollView = self.scrollView
        }else if listType == .tableView {
            smoothScrollView = self.tableView
        }else if listType == .collectionView {
            smoothScrollView = self.collectionView
        }
        self.addSubview(self.smoothScrollView!)
        self.smoothScrollView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(self)
        })
        
        if listType == GKSmoothListType.scrollView {
            var lastView: UIView?
            for i in 0..<self.count {
                let label = UILabel()
                label.textColor = .black
                label.font = UIFont.systemFont(ofSize: 16.0)
                label.text = "第\(i + 1)行"
                self.scrollView.addSubview(label)
                
                label.snp.makeConstraints { (make) in
                    make.left.equalTo(30)
                    if let v = lastView {
                        make.top.equalTo(v.snp_bottom)
                    }else {
                        make.top.equalTo(0)
                    }
                    make.width.equalTo(self.scrollView.snp_width)
                    make.height.equalTo(50.0)
                }
                lastView = label
            }
            
            self.scrollView.snp.remakeConstraints { (make) in
                make.edges.equalTo(self)
                make.bottom.equalTo(lastView!.snp_bottom)
            }
        }else if listType == .tableView {
            self.tableView.reloadData()
        }else if listType == .collectionView {
            self.collectionView.reloadData()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GKSmoothListView: GKPageSmoothListViewDelegate {
    func listView() -> UIView {
        return self
    }

    func listScrollView() -> UIScrollView {
        return self.smoothScrollView!
    }
}

extension GKSmoothListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = "第\(indexPath.row+1)行"
        return cell
    }
}

extension GKSmoothListView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath)
        cell.contentView.backgroundColor = .red
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        let textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 16.0)
        textLabel.text = "第\(indexPath.item+1)行"
        cell.contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.center.equalTo(cell.contentView)
        }
        
        return cell
    }
}
