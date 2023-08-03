//
//  GKIndexListViewController.swift
//  GKPageScrollViewSwift
//
//  Created by QuintGao on 2019/2/21.
//  Copyright © 2019 QuintGao. All rights reserved.
//

import UIKit
import GKPageScrollView

class GKIndexListViewController: UIViewController {
    
    var scrollCallBack: ((UIScrollView) -> ())?
    
    var array = [[String: Any]]()
    
    var isChangeSection: Bool = false
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "tableViewCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.view)
        })
        
        self.array = [["title": "A", "list": ["assfsdf", "adfdfsdf", "adfkdfdsf", "adkfjdik", "adkjfdsf"]],
                      ["title": "B", "list": ["bsgdsfd", "badsfsfs", "bdsafsdfd", "bidfjidd", "bsidfadd"]],
                      ["title": "C", "list": ["csfsdfs", "csdfsfds", "csdfasdif", "casdifdj", "casdkfds"]],
                      ["title": "D", "list": ["dsafdfs", "dsfdsfdf", "dsfadfdfd", "dsafodsf", "dsafoisf"]],
                      ["title": "E", "list": ["esafdfs", "esfdsfdf", "esfadfdfd", "esafodsf", "esafoisf"]],
                      ["title": "F", "list": ["fsafdfs", "fsfdsfdf", "fsfadfdfd", "fsafodsf", "fsafoisf"]]]
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var frame = self.view.frame
        frame.size = (self.view.superview?.bounds.size)!
        self.view.frame = frame
    }
}

extension GKIndexListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        array.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let list = array[section]["list"] as? [String]
        return list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        let list = array[indexPath.section]["list"] as? [String]
        cell.textLabel?.text = list?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return array[section]["title"] as? String
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        20
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        ["A", "B", "C", "D", "E", "F"]
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        isChangeSection = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isChangeSection = false
        }
        return index
    }
}

extension GKIndexListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let callBack = scrollCallBack {
            callBack(scrollView)
        }
    }
}

extension GKIndexListViewController: GKPageListViewDelegate {
    func listView() -> UIView {
        return self.view
    }
    
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func listViewDidScroll(callBack: @escaping (UIScrollView) -> ()) {
        scrollCallBack = callBack
    }
    
    func isListScrollViewNeedScroll() -> Bool {
        isChangeSection
    }
}
