//
//  ViewController.swift
//  SwiftExample
//
//  Created by gaokun on 2020/12/29.
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
    
    let dataSource = [["group": "GKPageScrollView", "list": [["title": "微博个人主页", "class": "GKWBViewController"],
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
                                                             ["title": "嵌套使用2", "class": "GKNest2ViewController"]]],
                      ["group": "GKPageSmoothView", "list": [["title": "豆瓣电影主页", "class": "GKDBViewController"],
                                                             ["title": "滑动延续", "class": "GKSmoothViewController"]]]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navTitle = "SwiftDemo";
        
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.gk_navigationBar.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let list = self.dataSource[section]["list"] as! [Any]
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        let list = self.dataSource[indexPath.section]["list"] as! [Any]
        let dict = list[indexPath.row] as! [String: String]
        cell.textLabel?.text = dict["title"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let projectName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        
        let list = self.dataSource[indexPath.section]["list"] as! [Any]
        let dict = list[indexPath.row] as! [String: String]
        let className = dict["class"]
        
        let vc = (NSClassFromString(projectName + "." + className!) as! UIViewController.Type).init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .black
        let dic = self.dataSource[section]
        titleLabel.text = dic["group"] as? String
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(headerView).offset(10)
            $0.centerY.equalTo(headerView)
        }
        return headerView;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

