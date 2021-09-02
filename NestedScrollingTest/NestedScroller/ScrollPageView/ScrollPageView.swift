//
//  ScrollPageView.swift
//  ScrollViewController
//
//  Created by jasnig on 16/4/6.
//  Copyright © 2016年 ZeroJ. All rights reserved.
// github: https://github.com/jasnig
// 简书: http://www.jianshu.com/users/fb31a3d1ec30/latest_articles

//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//

import UIKit

open class ScrollPageView: UIView {
    open var segmentStyle = SegmentStyle()
    /// 附加按钮点击响应
    open var extraBtnOnClick: ((_ extraBtn: UIButton) -> Void)? {
        didSet {
            segView.extraBtnOnClick = extraBtnOnClick
        }
    }
    
    fileprivate var segView: ScrollSegmentView!
    fileprivate var contentView: ScrollerContentView!
    fileprivate var titlesArray: [String] = []
    /// 所有的子控制器
    var childVcs: [UIViewController] = []
    // 这里使用weak避免循环引用
    fileprivate weak var parentViewController: UIViewController?
    var callbackCurrentIndex:((Int)->Void)?

    
    public init(frame:CGRect, segmentStyle: SegmentStyle, titles: [String], childVcs:[UIViewController], parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        self.childVcs = childVcs
        self.titlesArray = titles
        self.segmentStyle = segmentStyle
        assert(childVcs.count == titles.count, "标题的个数必须和子控制器的个数相同")
        super.init(frame: frame)
        // 初始化设置了frame后可以在以后的任何地方直接获取到frame了, 就不必重写layoutsubview()方法在里面设置各个控件的frame
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func commonInit() {
        backgroundColor = UIColor.white
        segView = ScrollSegmentView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: segmentStyle.scrollHeight), segmentStyle: segmentStyle, titles: titlesArray)
        segView.callbackCurrentIndex = {[weak self] index in
            self?.callbackCurrentIndex?(index)
        }
        guard let parentVc = parentViewController else { return }
        
        contentView = ScrollerContentView(frame: CGRect(x: 0, y: segView.frame.maxY, width: bounds.size.width, height: bounds.size.height - segmentStyle.scrollHeight), childVcs: childVcs, parentViewController: parentVc)
        contentView.delegate = self
        addSubview(contentView)
        addSubview(segView)
        // 在这里调用了懒加载的collectionView, 那么之前设置的self.frame将会用于collectionView,如果在layoutsubviews()里面没有相关的处理frame的操作, 那么将导致内容显示不正常
        // 避免循环引用
        segView.titleBtnOnClick = {[unowned self] (label: UILabel, index: Int) in
            
            // 切换内容显示
            self.contentView.setContentOffSet(CGPoint(x: self.contentView.bounds.size.width * CGFloat(index), y: 0), animated: false)
        }


    }
    
    deinit {
        parentViewController = nil
//        logOut("\(self.debugDescription) --- 销毁")
    }

 
}

//MARK: - public helper
extension ScrollPageView {
    
    /// 给外界设置选中的下标的方法
    public func selectedIndex(_ selectedIndex: Int, animated: Bool) {
        // 移动滑块的位置
        segView.selectedIndex(selectedIndex, animated: animated)
        
    }

    ///   给外界重新设置视图内容的标题的方法, 在设置之前需要先移除childViewControllers, 然后添加新的childViewControllers
    ///
    ///  - parameter titles:      newTitles
    ///  - parameter newChildVcs: newChildVcs
    public func reloadChildVcsWithNewTitles(_ titles: [String], andNewChildVcs newChildVcs: [UIViewController]) {
        self.childVcs = newChildVcs
        self.titlesArray = titles
        
        segView.reloadTitlesWithNewTitles(titlesArray)
        contentView.reloadAllViewsWithNewChildVcs(childVcs)
    }
}

extension ScrollPageView: ScrollerContentViewDelegate {

    public var segmentView: ScrollSegmentView {
        return segView
    }

}
