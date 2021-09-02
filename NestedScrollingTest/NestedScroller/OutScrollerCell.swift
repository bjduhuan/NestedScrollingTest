//
//  OutScrollerCell.swift
//  Runner
//
//  Created by weichuang on 2021/9/1.
//

import Foundation
import UIKit
class OutScrollerCell: UITableViewCell {
    
 
    private var pagerVC = PagerViewController()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(pagerVC.view)
        pagerVC.view.snp.remakeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.size.height)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
