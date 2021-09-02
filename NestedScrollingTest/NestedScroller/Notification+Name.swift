//
//  Notification+Name.swift
//  Runner
//
//  Created by weichuang on 2021/9/1.
//

import Foundation
extension Notification.Name {
    ///发现界面--滚到顶部
    static let goTopNotificationName = NSNotification.Name("goTopNotificationName")
    ///发现界面--离开顶部
    static let leaveTopNotificationName = NSNotification.Name("leaveTopNotificationName")

}
