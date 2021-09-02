//
//  InnerScrollerViewController.swift
//  Runner
//
//  Created by weichuang on 2021/9/1.
//

import Foundation
import UIKit
import SnapKit
class InnerScrollerViewController:UIViewController{
    
    static var canScroll = false

    
    lazy var listView:UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(InnerNormalCell.classForCoder(), forCellReuseIdentifier: "InnerNormalCell")
        tableView.estimatedRowHeight = 40
        tableView.tag = 100
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(listView)
        listView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        //建立通知中心 监听离开置顶命令
        NotificationCenter.default.addObserver(self, selector: #selector(acceptMsg(notification:)), name: Notification.Name.leaveTopNotificationName, object: nil)
        //建立通知中心 监听进入置顶命令
        NotificationCenter.default.addObserver(self, selector: #selector(acceptMsg(notification:)), name: Notification.Name.goTopNotificationName, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    /// 接收到通知的回调
    ///
    /// - Parameter notification:
    @objc func acceptMsg(notification: Notification) {
        let notificationName = notification.name
        if notificationName == Notification.Name.goTopNotificationName {
            if let canScroll_str = notification.userInfo?["canScroll"] as? String {
                if canScroll_str == "1" {
                    InnerScrollerViewController.canScroll = true
                }
            }
        }else if notificationName == Notification.Name.leaveTopNotificationName {
            listView.contentOffset = CGPoint.zero
            InnerScrollerViewController.canScroll = false
        }
    }
}

extension InnerScrollerViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InnerNormalCell", for: indexPath) as! InnerNormalCell
        return cell
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!InnerScrollerViewController.canScroll) {
            scrollView.contentOffset = CGPoint.zero
        }
        let offsetY = scrollView.contentOffset.y
        if (offsetY < 0) {
            print("inner---下拉--\(scrollView.contentOffset)")
            NotificationCenter.default.post(name: Notification.Name.leaveTopNotificationName, object: nil, userInfo: ["canScroll":"1"])
        }else{
            print("inner---上滑--\(scrollView.contentOffset)")
        }
    }
    
}
