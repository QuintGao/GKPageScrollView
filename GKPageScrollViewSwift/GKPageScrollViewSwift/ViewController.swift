//
//  ViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class ViewController: GKDemoBaseViewController {

    lazy var tableView: UITableView! = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    let dataSource = [["title": "微博个人主页", "class": "GKWBViewController"],
                      ["title": "微博发现页", "class": "GKWBFindViewController"],
                      ["title": "网易云歌手页", "class": "GKWYViewController"],
                      ["title": "抖音个人主页", "class": "GKDYViewController"],
                      ["title": "主页刷新", "class": "GKMainRefreshViewController"],
                      ["title": "列表刷新", "class": "GKListRefreshViewController"],
                      ["title": "列表懒加载", "class": "GKListLoadViewController"],
                      ["title": "item加载", "class": "GKItemLoadViewController"],
                      ["title": "Header左右滑动", "class": "GKHeaderScrollViewController"],
                      ["title": "VTMagic使用", "class": "GKVTMagicViewController"],
                      ["title": "嵌套使用1", "class": "GKNest1ViewController"],
                      ["title": "嵌套使用2", "class": "GKNest2ViewController"]]
//                      ["title": "测试", "class": "GKTestViewController"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navTitle = "Demo";
        
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.gk_navigationBar.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = self.dataSource[indexPath.row]["title"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let projectName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        
        let className = self.dataSource[indexPath.row]["class"]
        
        let vc = (NSClassFromString(projectName + "." + className!) as! UIViewController.Type).init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
