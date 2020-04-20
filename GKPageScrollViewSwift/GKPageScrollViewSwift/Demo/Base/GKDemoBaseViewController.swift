//
//  GKDemoBaseViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import GKNavigationBar

class GKDemoBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.gk_statusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.gk_statusBarStyle
    }
}
