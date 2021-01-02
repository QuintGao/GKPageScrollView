//
//  GKDemoBaseViewController.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/21.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit
import GKNavigationBarSwift
import GKPageScrollView

class GKDemoBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
    }
    
    deinit {
        print(NSStringFromClass(self.classForCoder) + "deinit")
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.gk_statusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.gk_statusBarStyle
    }
}
