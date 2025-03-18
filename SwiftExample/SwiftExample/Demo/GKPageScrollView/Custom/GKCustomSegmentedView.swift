//
//  GKCustomSegmentedView.swift
//  SwiftExample
//
//  Created by QuintGao on 2025/3/18.
//

import UIKit

protocol GKCustomSegmentedViewDelegate: NSObjectProtocol {
    func didClickSelect(at index: Int)
}

class GKCustomSegmentedView: UIView {
    
    public weak var delegate: GKCustomSegmentedViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
    func initUI() {
        self.backgroundColor = UIColor.white
        let titles = ["作品", "收藏", "喜欢"]
        titles.enumerated().forEach {
            let btn = UIButton()
            btn.setTitle($0.element, for: .normal)
            btn.setTitleColor(.black, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 16)
            btn.tag = $0.offset
            btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
            addSubview(btn)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.width / 3
        let height = bounds.height
        subviews.enumerated().forEach {
            $0.element.frame = CGRect(x: CGFloat($0.offset) * width, y: 0, width: width, height: height)
        }
    }
    
    @objc func btnClick(sender: UIButton) {
        let index = sender.tag
        subviews.enumerated().forEach {
            let btn = $0.element as! UIButton
            if $0.offset == index {
                btn.setTitleColor(.red, for: .normal)
            } else {
                btn.setTitleColor(.black, for: .normal)
            }
        }
        delegate?.didClickSelect(at: index)
    }
    
    public func scrollSelect(with index: Int) {
        subviews.enumerated().forEach {
            let btn = $0.element as! UIButton
            if $0.offset == index {
                btn.setTitleColor(.red, for: .normal)
            } else {
                btn.setTitleColor(.black, for: .normal)
            }
        }
    }
}
