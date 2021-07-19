//
//  GKNestScrollView.swift
//  GKPageScrollViewSwift
//
//  Created by gaokun on 2019/10/22.
//  Copyright © 2019 gaokun. All rights reserved.
//

import UIKit

protocol GKNestScrollViewDelegate: AnyObject {
    func nestScrollViewGestureRecognizerShouldBegin(_ scrollView: GKNestScrollView, gestureRecognizer: UIGestureRecognizer) -> Bool
    func nestScrollGestureRecognizer(_ scrollView: GKNestScrollView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

class GKNestScrollView: UIScrollView {

    public weak var gestureDelegate: GKNestScrollViewDelegate?
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = self.gestureDelegate?.nestScrollViewGestureRecognizerShouldBegin(self, gestureRecognizer: gestureRecognizer) {
            return result
        }
        
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let result = self.gestureDelegate?.nestScrollGestureRecognizer(self, gestureRecognizer: gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return result
        }
        
        return false
    }
}
