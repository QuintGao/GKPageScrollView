//
//  GKPinLocationViewController.swift
//  SwiftExample
//
//  Created by gaokun on 2021/3/18.
//

import UIKit
import GKNavigationBarSwift
import JXSegmentedView
import GKPageSmoothView

class GKPinLocationViewController: GKDemoBaseViewController {
    lazy var smoothView: GKPageSmoothView = {
        let smoothView = GKPageSmoothView(dataSource: self)
        smoothView.ceilPointHeight = GK_STATUSBAR_NAVBAR_HEIGHT
        smoothView.delegate = self
        return smoothView
    }()
    
    lazy var headerView: UIImageView = {
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kBaseHeaderHeight))
        headerView.contentMode = .scaleAspectFill;
        headerView.clipsToBounds = true;
        headerView.image = UIImage(named: "test")
        return headerView
    }()
    
    let pinDataSource = JXSegmentedPinTitleDataSource()
    lazy var titleView: JXSegmentedView = {
        pinDataSource.titles = ["年货市集", "新年换新", "安心过年", "爆品专区", "尝鲜专区", "贺岁大餐", "超值外卖", "玩乐特惠", "商超年货"];
        pinDataSource.pinImage = self.changeImage(image: UIImage(named: "location")!, color: UIColor.red)
        pinDataSource.titleNormalColor = UIColor.gray
        pinDataSource.titleSelectedColor = UIColor.red
        pinDataSource.titleNormalFont = UIFont.systemFont(ofSize: 15)
    
        let titleView = JXSegmentedView()
        titleView.backgroundColor = UIColor.white
        titleView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: kBaseSegmentHeight)
        titleView.delegate = self
        titleView.dataSource = pinDataSource
        return titleView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gk_navTitle = "上下滑动切换tab"
        self.gk_navLineHidden = true
        self.gk_navTitleColor = .white
        self.gk_navTitleFont = UIFont.boldSystemFont(ofSize: 18)
        self.gk_navBackgroundColor = .clear
        self.gk_statusBarStyle = .lightContent
        
        view.addSubview(smoothView)
        smoothView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        smoothView.reloadData()
    }
    
    func changeImage(image: UIImage, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)//kCGBlendModeNormal
        context?.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        context?.clip(to: rect, mask: image.cgImage!);
        color.setFill()
        context?.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension GKPinLocationViewController: GKPageSmoothViewDataSource, GKPageSmoothViewDelegate {
    func headerView(in smoothView: GKPageSmoothView) -> UIView {
        return self.headerView
    }
    
    func segmentedView(in smoothView: GKPageSmoothView) -> UIView {
        return self.titleView
    }
    
    func numberOfLists(in smoothView: GKPageSmoothView) -> Int {
        return 1
    }
    
    func smoothView(_ smoothView: GKPageSmoothView, initListAtIndex index: Int) -> GKPageSmoothListViewDelegate {
        let listView = GKPinLocationView()
        var data = [[String: String]]()
        let counts = [6, 8 ,9, 5, 7, 10, 13, 6, 8]
        for i in 0..<counts.count {
            var dic = [String: String]()
            dic["title"] = self.pinDataSource.titles[i]
            dic["count"] = String(counts[i])
            data.append(dic)
        }
        listView.datas = data;
        return listView;
    }
    
    func smoothViewListScrollViewDidScroll(_ smoothView: GKPageSmoothView, scrollView: UIScrollView, contentOffset: CGPoint) {
        if !(scrollView.isTracking || scrollView.isDecelerating) { return }
        // 用户滚动的才处理
        // 获取categoryView下面一点的所有部件信息，用于指定，当前最上方显示的那个section
        let categoryH = self.titleView.frame.size.height
        let tableView = scrollView as! UITableView
        let topIndexPaths = tableView.indexPathsForRows(in: CGRect(x: 0, y: contentOffset.y + categoryH - self.headerView.frame.size.height + 40 + 10, width: tableView.frame.size.width, height: 200))
        let topIndexPath = topIndexPaths?.first
        if let indexPath = topIndexPath {
            let topSection = indexPath.section
            if self.titleView.selectedIndex != topSection {
                self.titleView.selectItemAt(index: topSection)
            }
        }
    }
}

extension GKPinLocationViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        let tableView = self.smoothView.currentListScrollView as! UITableView
        let frame = tableView.rectForHeader(inSection: index)
        tableView.setContentOffset(CGPoint(x: 0, y: frame.origin.y - kBaseHeaderHeight + kBaseSegmentHeight + 40), animated: true)
    }
}
