//
//  OutScrollerViewController.swift
//  Runner
//
//  Created by weichuang on 2021/9/1.
//

import Foundation
import SnapKit
class OutScrollerViewController:UIViewController{
    
    
    lazy var listView:TKGestureTableView = {
        let tableView = TKGestureTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(OutNormalCell.classForCoder(), forCellReuseIdentifier: "OutNormalCell")
        tableView.register(OutScrollerCell.classForCoder(), forCellReuseIdentifier: "OutScrollerCell")
        tableView.estimatedRowHeight = 40
        return tableView
    }()
    
    
    var isTopAndCanNotMoveTabViewPre:Bool = false
    var isTopAndCanNotMoveTabView:Bool = false
    var canScroll:Bool = false
    
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
    
    /// 接收到通知的回调
    ///
    /// - Parameter notification:
    @objc func acceptMsg(notification: Notification) {
        let notificationName = notification.name
        if notificationName == Notification.Name.goTopNotificationName {//到达已经吸顶部分
            if let canScroll_str = notification.userInfo?["canScroll"] as? String {
                if canScroll_str == "1" {
                    canScroll = false
                }
            }
        }else if notificationName == Notification.Name.leaveTopNotificationName {//离开吸顶部分
            listView.contentOffset = CGPoint.zero
            canScroll = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension OutScrollerViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row < 4){
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutNormalCell", for: indexPath) as! OutNormalCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutScrollerCell", for: indexPath) as! OutScrollerCell
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("out---\(scrollView.contentOffset)")
        ///吸顶效果
        let offsetY = scrollView.contentOffset.y
            let tabOffsetY:CGFloat = CGFloat(Int(listView.rectForRow(at: IndexPath(row: 4, section: 0)).origin.y))
            isTopAndCanNotMoveTabViewPre = isTopAndCanNotMoveTabView
            if offsetY >= tabOffsetY {
                scrollView.contentOffset = CGPoint(x: 0, y: tabOffsetY)
                isTopAndCanNotMoveTabView = true
            }else {
                isTopAndCanNotMoveTabView = false
            }
            if (isTopAndCanNotMoveTabView != isTopAndCanNotMoveTabViewPre){
                if (!isTopAndCanNotMoveTabViewPre && isTopAndCanNotMoveTabView) {
                    //上滑-滑动到顶端
                    print("out---上滑-滑动到顶端--\(scrollView.contentOffset)")
                    NotificationCenter.default.post(name: Notification.Name.goTopNotificationName, object: nil, userInfo: ["canScroll":"1"])
                    canScroll = false
                }
                if(isTopAndCanNotMoveTabViewPre && !isTopAndCanNotMoveTabView){
                    //下滑-离开顶端
                    print("out---下滑-离开顶端--\(scrollView.contentOffset)")
                    if (!canScroll) {
                        scrollView.contentOffset = CGPoint(x: 0, y: tabOffsetY)
                    }
                }
            }
        
    }
}
