//
//  GKPageTableView.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/2/20.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit

open class GKPageTableView: UITableView, UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
