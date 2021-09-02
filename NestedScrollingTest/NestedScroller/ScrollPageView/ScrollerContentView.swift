//
//  ScrollerContentView.swift
//  ScrollViewController
//
//  Created by jasnig on 16/4/13.
//  Copyright © 2016年 ZeroJ. All rights reserved.
// github: https://github.com/jasnig
// 简书: http://www.jianshu.com/users/fb31a3d1ec30/latest_articles


import UIKit
open class ScrollerContentView: UIView {
    static let cellId = "cellId"
    
    /// 所有的子控制器
    fileprivate var childVcs: [UIViewController] = []
    /// 用来判断是否是点击了title, 点击了就不要调用scrollview的代理来进行相关的计算
    fileprivate var forbidTouchToAdjustPosition = false
    /// 用来记录开始滚动的offSetX
    fileprivate var oldOffSetX:CGFloat = 0.0
    fileprivate var oldIndex = 0
    fileprivate var currentIndex = 1
    
    // 这里使用weak 避免循环引用
    fileprivate weak var parentViewController: UIViewController?
    open weak var delegate: ScrollerContentViewDelegate?
    
    fileprivate lazy var collectionView: UICollectionView = {[weak self] in
        let flowLayout = UICollectionViewFlowLayout()
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        
        if let strongSelf = self {
            flowLayout.itemSize = strongSelf.bounds.size
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            
            collection.bounces = false
            collection.showsHorizontalScrollIndicator = false
            collection.frame = strongSelf.bounds
            collection.collectionViewLayout = flowLayout
            collection.isPagingEnabled = true
            // 如果不设置代理, 将不会调用scrollView的delegate方法
            collection.delegate = strongSelf
            collection.dataSource = strongSelf
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: ScrollerContentView.cellId)
        }
        return collection
    }()
    
    
    public init(frame:CGRect, childVcs:[UIViewController], parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        self.childVcs = childVcs
        super.init(frame: frame)
        commonInit()
        

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("不要使用storyboard中的view为ScrollerContentView")
    }
    
    
    fileprivate func commonInit() {
        
        // 不要添加navigationController包装后的子控制器
        for childVc in childVcs {
            if childVc.isKind(of: UINavigationController.self) {
                fatalError("不要添加UINavigationController包装后的子控制器")
            }
            parentViewController?.addChild(childVc)
        }
        
        collectionView.frame = bounds
        
        // 在这里调用了懒加载的collectionView, 那么之前设置的self.frame将会用于collectionView,如果在layoutsubviews()里面没有相关的处理frame的操作, 那么将导致内容显示不正常
        addSubview(collectionView)
        
        // 设置naviVVc手势代理, 处理pop手势
        if let naviParentViewController = self.parentViewController?.parent as? UINavigationController, let popGesture = naviParentViewController.interactivePopGestureRecognizer {
            // MARK---不重置系统返回手势
//            naviParentViewController.interactivePopGestureRecognizer?.delegate = self
            // 优先执行naviParentViewController.interactivePopGestureRecognizer的手势
            // 在代理方法中会判断是否真的执行, 不执行的时候就执行scrollView的滚动手势
            collectionView.panGestureRecognizer.require(toFail: popGesture)
            
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds

    }
    
    deinit {
        parentViewController = nil
//        logOut("\(self.debugDescription) --- 销毁")
    }

}

//MARK: - public helper
extension ScrollerContentView {
    
    // 给外界可以设置ContentOffSet的方法
    public func setContentOffSet(_ offSet: CGPoint , animated: Bool) {
        // 不要执行collectionView的scrollView的滚动代理方法
        self.forbidTouchToAdjustPosition = true
        self.collectionView.setContentOffset(offSet, animated: animated)
    }
    
    // 给外界刷新视图的方法
    public func reloadAllViewsWithNewChildVcs(_ newChildVcs: [UIViewController] ) {
        
        // removing the old childVcs
        childVcs.forEach { (childVc) in
            childVc.willMove(toParent: nil)
            childVc.view.removeFromSuperview()
            childVc.removeFromParent()
        }
        // setting the new childVcs
        childVcs = newChildVcs
        
        // don't add the childVc that wrapped by the navigationController
        // 不要添加navigationController包装后的子控制器
        for childVc in childVcs {
            if childVc.isKind(of: UINavigationController.self) {
                fatalError("不要添加UINavigationController包装后的子控制器")
            }
            // 添加子控制器
            parentViewController?.addChild(childVc)

        }
        collectionView.backgroundColor = UIColor.white
        // 刷新视图
        collectionView.reloadData()
        
    }
}


extension ScrollerContentView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    final public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }
    
    final public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScrollerContentView.cellId, for: indexPath)
        // 避免出现重用显示内容出错 ---- 也可以直接给每个cell用不同的reuseIdentifier实现
        // avoid to the case that shows the wrong thing due to the collectionViewCell's reuse
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        let  vc = childVcs[(indexPath as NSIndexPath).row]
        vc.view.frame = bounds
        cell.contentView.addSubview(vc.view)
        // finish buildding the parent-child relationship
        vc.didMove(toParent: parentViewController)
        
        return cell
    }
    
 
 
}


// MARK: - UIScrollViewDelegate
extension ScrollerContentView: UIScrollViewDelegate {
    
    /**
     为了解决在滚动或接着点击title更换的时候因为index不同步而增加了下边的两个代理方法的判断
     
     */
    // 滚动减速完成时再更新title的位置
    //
    final public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = Int(floor(scrollView.contentOffset.x / bounds.size.width))
        
        delegate?.contentViewDidEndMoveToIndex(currentIndex)
        // 保证如果滚动没有到下一页就返回了上一页, 那么在didScroll的代理里面执行之后, currentIndex和oldIndex不对
        // 通过这种方式再次正确设置 index



    }
    
    // 代码调整contentOffSet但是没有动画的时候不会调用这个
//    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
//    }
    
    
    // 手指开始拖的时候, 记录此时的offSetX, 并且表示不是点击title切换的内容
    final public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        /// 用来判断方向
        oldOffSetX = scrollView.contentOffset.x
        
        forbidTouchToAdjustPosition = false
        delegate?.contentViewDidBeginMove()
    }
    
    // 需要实时更新滚动的进度和移动的方向及下标 以便于外部使用
    final public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetX = scrollView.contentOffset.x
        
        // 如果是点击了title, 就不要计算了, 直接在点击相应的方法里就已经处理了滚动
        if forbidTouchToAdjustPosition {
            return
        }
        
        let temp = offSetX / bounds.size.width
        var progress = temp - floor(temp)
        
        if offSetX - oldOffSetX >= 0 {// 手指左滑, 滑块右移
            if progress == 0.0 {// 滚动开始和滚动完成的时候不要继续
                return
            }
            oldIndex = Int(floor(offSetX / bounds.size.width))
            currentIndex = oldIndex + 1
            if currentIndex >= childVcs.count {
                // 不要越界, 越界后直接设置currentIndex为数组最后下标
                // 同时为了避免在最后一页时滚动没有完成返回了原来那一页,导致index错误,就直接返回了, 在完成的代理方法里面重新设置了index
                currentIndex = childVcs.count - 1
                return
            }
            
        } else {// 手指右滑, 滑块左移
            currentIndex = Int(floor(offSetX / bounds.size.width))
            oldIndex = currentIndex + 1
            if oldIndex >= childVcs.count {
                oldIndex = childVcs.count - 1
                return
            }
            progress = 1.0 - progress
            
        }
        
        //        logOut("\(progress)------\(oldIndex)----\(currentIndex)")
        
        delegate?.contentViewMoveToIndex(oldIndex, toIndex: currentIndex, progress: progress)
        
        
        
    }

    
}

// MARK: - UIGestureRecognizerDelegate
extension ScrollerContentView: UIGestureRecognizerDelegate {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if let naviParentViewController = self.parentViewController?.parent as? UINavigationController , naviParentViewController.visibleViewController == parentViewController { // 当显示的是ScrollPageView的时候 只在第一个tag处执行pop手势
            return collectionView.contentOffset.x == 0
        }
        return true
    }
}

public protocol ScrollerContentViewDelegate: class {
    /// 有默认实现, 不推荐重写
    func contentViewMoveToIndex(_ fromIndex: Int, toIndex: Int, progress: CGFloat)
    /// 有默认实现, 不推荐重写
    func contentViewDidEndMoveToIndex(_ currentIndex: Int)
    /// 无默认操作, 推荐重写
    func contentViewDidBeginMove()
    /// 必须提供的属性
    var segmentView: ScrollSegmentView { get }
}

// 由于每个遵守这个协议的都需要执行些相同的操作, 所以直接使用协议扩展统一完成,协议遵守者只需要提供segmentView即可
extension ScrollerContentViewDelegate {
    
    // 默认什么都不做
    public func contentViewDidBeginMove() {
        
    }
    
    // 内容每次滚动完成时调用, 确定title和其他的控件的位置
    public func contentViewDidEndMoveToIndex(_ currentIndex: Int) {
        segmentView.adjustTitleOffSetToCurrentIndex(currentIndex)
        segmentView.adjustUIWithProgress(1.0, oldIndex: currentIndex, currentIndex: currentIndex)
    }
    
    // 内容正在滚动的时候,同步滚动滑块的控件
    public func contentViewMoveToIndex(_ fromIndex: Int, toIndex: Int, progress: CGFloat) {
        segmentView.adjustUIWithProgress(progress, oldIndex: fromIndex, currentIndex: toIndex)
    }
}

