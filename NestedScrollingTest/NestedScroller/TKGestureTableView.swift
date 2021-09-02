//
//  TKGestureTableView.swift
//  Runner
//
//  Created by weichuang on 2021/9/1.
//

import Foundation
import UIKit

class TKGestureTableView: UITableView, UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let otherView = otherGestureRecognizer.view {
            if otherView.tag == 100 {
                return true
            }
        }
        return false
    }
    
}
