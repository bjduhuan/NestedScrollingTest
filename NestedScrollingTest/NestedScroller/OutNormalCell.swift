//
//  OutNormalCell.swift
//  Runner
//
//  Created by weichuang on 2021/9/1.
//

import Foundation
import UIKit

class OutNormalCell: UITableViewCell {
    
    lazy var label:UILabel = {
        let label = UILabel()
        label.text = "Normal"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.white
        self.contentView.addSubview(label)
        label.snp.remakeConstraints { make in
            make.left.equalTo(30)
            make.top.equalTo(30)
            make.bottom.equalTo(-30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
