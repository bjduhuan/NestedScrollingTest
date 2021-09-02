//
//  PagerViewController.swift
//  Runner
//
//  Created by weichuang on 2021/9/1.
//

import Foundation
import UIKit
class PagerViewController: UIViewController {
    
    private var scrollPageView:ScrollPageView!
    private var titles:[String] = ["1","2","3"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        initPagerView()
    }
    
    private func initPagerView(){
        
        _ = self.view.subviews.map {
            $0.removeFromSuperview()
        }
        
        // 设置顶部滚动
        var style = SegmentStyle()
        // 设置字体
        style.titleFont = UIFont.systemFont(ofSize: 16)
        // 滚动条
        style.showLine = true
        style.scrollLineToBottom = 5
        style.scrollLineColor = UIColor.init(hexString: "#FF6600")!
        style.scrollLineHeight = 4
        style.scrollLineWidth = 35.5
        style.scrollTitle = true
        style.titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        style.selectedTitleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        style.normalTitleColor = UIColor.init(hexString: "#333333")!
        style.selectedTitleColor = UIColor.init(hexString: "#FF6600")!
        style.scrollHeight = 67
        style.scrollRadius = 2
        style.scrollTitle = false
        style.firstTitleToLeft = 15
        // 设置scrollView里的标题元素
        //初始化ScrollPageView'
        scrollPageView = ScrollPageView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), segmentStyle: style, titles: titles, childVcs:setVCWithData(),parentViewController: self)
        scrollPageView.selectedIndex(0, animated: true)
        self.view.addSubview(scrollPageView)
    }
    
    private func setVCWithData()->[UIViewController]{
        var childVCs:[UIViewController] = []
        for _ in 0..<titles.count{
            childVCs.append(InnerScrollerViewController())
        }
        return childVCs
    }
    
}
