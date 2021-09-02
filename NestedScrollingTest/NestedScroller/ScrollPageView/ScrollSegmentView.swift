//
//  TopScrollView.swift
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
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//

import UIKit

open class ScrollSegmentView: UIView {

    // 1. 实现颜色填充效果
    
    
    /// 所有的title设置
    open var segmentStyle: SegmentStyle
    
    /// 点击响应的closure
    open var titleBtnOnClick:((_ label: UILabel, _ index: Int) -> Void)?
    /// 附加按钮点击响应
    open var extraBtnOnClick: ((_ extraBtn: UIButton) -> Void)?
    /// self.bounds.size.width
    fileprivate var currentWidth: CGFloat = 0
    /// 遮盖x和文字x的间隙
    fileprivate var xGap = 5
    /// 遮盖宽度比文字宽度多的部分
    fileprivate var wGap: Int {
        return 2 * xGap
    }
    
    
    /// 缓存标题labels
    fileprivate var labelsArray: [CustomLabel] = []
    var callbackCurrentIndex:((Int)->Void)?
    /// 记录当前选中的下标
    var currentIndex:Int = 0
    
    
    /// 记录上一个下标
    fileprivate var oldIndex = 0
    /// 用来缓存所有标题的宽度, 达到根据文字的字数和font自适应控件的宽度
    fileprivate var titlesWidthArray: [CGFloat] = []
    /// 所有的标题
    fileprivate var titles:[String]
    
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollV = UIScrollView()
        scrollV.showsHorizontalScrollIndicator = false
        scrollV.bounces = false
        scrollV.isPagingEnabled = false
        return scrollV
        
    }()
    ///滚动条宽度
    fileprivate var scrollerWidth:CGFloat = 0
    /// 滚动条
    fileprivate lazy var scrollLine: UIView? = {[unowned self] in
        let line = UIView()
        return self.segmentStyle.showLine ? line : nil
    }()
    /// 遮盖
    fileprivate lazy var coverLayer: UIView? = {[unowned self] in
        
        if !self.segmentStyle.showCover {
            return nil
        }
        let cover = UIView()
        cover.layer.cornerRadius = CGFloat(self.segmentStyle.coverCornerRadius)
        // 这里只有一个cover 需要设置圆角, 故不用考虑离屏渲染的消耗, 直接设置 masksToBounds 来设置圆角
        cover.layer.masksToBounds = true
        
        return cover
    
    }()
    
    /// 末端分割线
    fileprivate lazy var carveLine: UILabel = {
        let line = UILabel()
        line.backgroundColor = UIColor(hexString: "#d8d8d8")!
        return line
    }()
    
    /// 底部分割线
    fileprivate lazy var bottomLine: UILabel = {
        let line = UILabel()
        line.backgroundColor = UIColor(hexString: "#d8d8d8")!
        return line
    }()
        
    
    /// 懒加载颜色的rgb变化值, 不要每次滚动时都计算
    fileprivate lazy var rgbDelta: (deltaR: CGFloat, deltaG: CGFloat, deltaB: CGFloat) = {[unowned self] in
        let normalColorRgb = self.normalColorRgb
        let selectedTitleColorRgb = self.selectedTitleColorRgb
        let deltaR = normalColorRgb.r - selectedTitleColorRgb.r
        let deltaG = normalColorRgb.g - selectedTitleColorRgb.g
        let deltaB = normalColorRgb.b - selectedTitleColorRgb.b
        
        return (deltaR: deltaR, deltaG: deltaG, deltaB: deltaB)
    }()
    
    /// 懒加载颜色的rgb变化值, 不要每次滚动时都计算
    fileprivate lazy var normalColorRgb: (r: CGFloat, g: CGFloat, b: CGFloat) = {
        
        if let normalRgb = self.getColorRGB(self.segmentStyle.normalTitleColor) {
            return normalRgb
        } else {
            fatalError("设置普通状态的文字颜色时 请使用RGB空间的颜色值")
        }
        
    }()
    
    fileprivate lazy var selectedTitleColorRgb: (r: CGFloat, g: CGFloat, b: CGFloat) =  {
        
        if let selectedRgb = self.getColorRGB(self.segmentStyle.selectedTitleColor) {
            return selectedRgb
        } else {
            fatalError("设置选中状态的文字颜色时 请使用RGB空间的颜色值")
        }
        
    }()
    
    //FIXME: 如果提供的不是RGB空间的颜色值就可能crash
    fileprivate func getColorRGB(_ color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat)? {
//        let colorString = String(color)
//        let colorArr = colorString.componentsSeparatedByString(" ")
//        logOut(colorString)
//        guard let r = Int(colorArr[1]), let g = Int(colorArr[2]), let b = Int(colorArr[3]) else {
//            return nil
//        }
        
        
        let numOfComponents = color.cgColor.numberOfComponents
        if numOfComponents == 4 {
            let componemts = color.cgColor.components
//            logOut("\(componemts[0]) --- \(componemts[1]) ---- \(componemts[2]) --- \(componemts[3])")

            return (r: (componemts?[0])!, g: (componemts?[1])!, b: (componemts?[2])!)

        }
        return nil
        
        
    }
    /// 背景图片
    open var backgroundImage: UIImage? = nil {
        didSet {
            // 在设置了背景图片的时候才添加imageView
            if let image = backgroundImage {
                backgroundImageView.image = image
                insertSubview(backgroundImageView, at: 0)

            }
        }
    }
    fileprivate lazy var backgroundImageView: UIImageView = {[unowned self] in
        let imageView = UIImageView(frame: self.bounds)
        return imageView
    }()
    

    
    /// 初始化的过程中做了太多的事了 !!!!!!
    public init(frame: CGRect, segmentStyle: SegmentStyle, titles: [String]) {
        self.segmentStyle = segmentStyle
        self.titles = titles
        super.init(frame: frame)
        if !self.segmentStyle.scrollTitle { // 不能滚动的时候就不要把缩放和遮盖或者滚动条同时使用, 否则显示效果不好

            self.segmentStyle.scaleTitle = !(self.segmentStyle.showCover || self.segmentStyle.showLine)
        }
        //设置背景颜色
        backgroundColor = self.segmentStyle.backgroundColor
        if let layer = self.segmentStyle.backgroundLayer{
            self.layer.insertSublayer(layer,at: 0)
        }
        addSubview(scrollView)
        //添加末端分割线
        addSubview(carveLine)
        carveLine.isHidden = !self.segmentStyle.showExtraButton
        //添加底部分割线
        addSubview(bottomLine)
        bottomLine.isHidden = !self.segmentStyle.showExtraButton
        // 设置了frame之后可以直接设置其他的控件的frame了, 不需要在layoutsubView()里面设置
        setupTitles()
        setupUI()
        adjustTitleOffSetToCurrentIndex(0)

    }
    
    required public init?(coder aDecoder: NSCoder) {
        var style = SegmentStyle()
        // 设置字体
        style.titleFont = UIFont.systemFont(ofSize: 16)
        style.gradualChangeTitleColor = true
        // 滚动条
        style.showLine = true
        style.scrollLineToBottom = 0
        style.scrollLineColor = UIColor.init(hexString: "#FF9222") ?? UIColor.orange
        style.scrollLineHeight = 2
        style.scrollLineWidth = 43
        style.scrollTitle = true
        style.titleFont = UIFont.systemFont(ofSize: 16,weight: .medium)
        style.selectedTitleFont = UIFont.systemFont(ofSize: 16,weight: .medium)
        style.normalTitleColor = UIColor.init(hexString: "#333333") ?? UIColor.black
        style.selectedTitleColor = UIColor.init(hexString: "#FF8F1C") ?? UIColor.orange
        style.scrollHeight = 40
        style.scrollRadius = 0
        style.backgroundColor = UIColor.white
        style.firstTitleToLeft = 15
        style.titleMargin = (UIScreen.main.bounds.size.width-30)/4-50
        segmentStyle = style
        titles = []
        super.init(coder: aDecoder)
        if !self.segmentStyle.scrollTitle { // 不能滚动的时候就不要把缩放和遮盖或者滚动条同时使用, 否则显示效果不好
            self.segmentStyle.scaleTitle = !(self.segmentStyle.showCover || self.segmentStyle.showLine)
        }
        //设置背景颜色
        backgroundColor = self.segmentStyle.backgroundColor
        if let layer = self.segmentStyle.backgroundLayer{
            self.layer.insertSublayer(layer,at: 0)
        }
        addSubview(scrollView)
        //添加末端分割线
        addSubview(carveLine)
        carveLine.isHidden = !self.segmentStyle.showExtraButton
        //添加底部分割线
        addSubview(bottomLine)
        bottomLine.isHidden = !self.segmentStyle.showExtraButton
        // 设置了frame之后可以直接设置其他的控件的frame了, 不需要在layoutsubView()里面设置
        setupTitles()
        setupUI()
        adjustTitleOffSetToCurrentIndex(0)    }
    //MARK: - private
    ///title 的点击
    @objc private func titleLabelOnClick(_ tapGes: UITapGestureRecognizer) {
        guard let currentLabel = tapGes.view as? CustomLabel else { return }
        currentIndex = currentLabel.tag
        
        adjustUIWhenBtnOnClickWithAnimate(true)
        titleBtnOnClick?(currentLabel, currentIndex)
    }
    ///附加按钮的点击
    @objc private func extraBtnOnClick(_ btn: UIButton) {
        extraBtnOnClick?(btn)
    }

    deinit {
//        logOut("\(self.debugDescription) --- 销毁")
    }

}

//MARK: - public helper
extension ScrollSegmentView {
    ///  对外界暴露设置选中的下标的方法 可以改变设置下标滚动后是否有动画切换效果
    public func selectedIndex(_ selectedIndex: Int, animated: Bool) {
        if selectedIndex < 0 || (titles.count > 0 && selectedIndex >= titles.count) {
            return
        }
        // 自动调整到相应的位置
        currentIndex = selectedIndex
        // 可以改变设置下标滚动后是否有动画切换效果
        adjustUIWhenBtnOnClickWithAnimate(animated)
    }
    
    // 暴露给外界来刷新标题的文字显示
    public func reloadTitlesWithNewTitles(_ titles: [String]) {
        // 移除所有的scrollView子视图
        scrollView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        // 移除所有的label相关
        titlesWidthArray.removeAll()
        labelsArray.removeAll()
        
        // 重新设置UI
        self.titles = titles
        setupTitles()
        setupUI()
        // default selecte the first tag
        if titles.count > 0{
            selectedIndex(0, animated: true)
        }
    }
}


extension ScrollSegmentView {
    fileprivate func setupTitles() {
        for (index, title) in titles.enumerated() {
            
            let label = CustomLabel(frame: CGRect.zero)
            label.tag = index
            label.text = title
            label.textColor = segmentStyle.normalTitleColor
            label.font = segmentStyle.titleFont
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.titleLabelOnClick(_:)))
            label.addGestureRecognizer(tapGes)
            let norFontNum = segmentStyle.titleFont.pointSize
            let selFontNum = segmentStyle.selectedTitleFont.pointSize
            let size = (title as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0.0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: norFontNum > selFontNum ? segmentStyle.titleFont : segmentStyle.selectedTitleFont], context: nil)
            
            titlesWidthArray.append(size.width)
            labelsArray.append(label)
            scrollView.addSubview(label)
        }
    }
    
    fileprivate func setupUI() {
        setupScrollView()
        // 先设置label的位置
        setUpLabelsPosition()
        // 再设置滚动条和cover的位置
        setupScrollLineAndCover()
        
        if segmentStyle.scrollTitle { // 设置滚动区域
            if let lastLabel = labelsArray.last {
                scrollView.contentSize = CGSize(width: lastLabel.frame.maxX + 7, height: 0)
                
            }
        }
        
    }
    
    fileprivate func setupScrollView() {
          currentWidth = bounds.size.width
          let scrollW = currentWidth
          scrollView.frame = CGRect(x: 0.0, y: 0.0, width: scrollW, height: bounds.size.height)
      }
    // 先设置label的位置
    fileprivate func setUpLabelsPosition() {
        var titleX: CGFloat = 0.0
        let titleY: CGFloat = 0.0
        var titleW: CGFloat = 0.0
        let titleH = bounds.size.height - segmentStyle.scrollLineHeight
        
        if !segmentStyle.scrollTitle {// 标题不能滚动, 平分宽度
            titleW = currentWidth / CGFloat(titles.count)
            
            for (index, label) in labelsArray.enumerated() {
                
                titleX = CGFloat(index) * titleW
                
                label.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
                
                
            }
            
        } else {// 标题能滚动, 从左往右分布
            
            for (index, label) in labelsArray.enumerated() {
                titleW = titlesWidthArray[index]
                
                
                if index != 0 {
                    titleX = segmentStyle.titleMargin
                    let lastLabel = labelsArray[index - 1]
                    titleX = lastLabel.frame.maxX + segmentStyle.titleMargin
                }else {
                    titleX = segmentStyle.firstTitleToLeft
                }
                label.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
            }
            
        }
        
        guard labelsArray.count > 0 else {
            return
        }
        if let firstLabel = labelsArray[0] as? CustomLabel {
            
            // 缩放, 设置初始的label的transform
            if segmentStyle.scaleTitle {
                firstLabel.currentTransformSx = segmentStyle.titleBigScale
            }
            // 设置初始状态文字的颜色
            firstLabel.textColor = segmentStyle.selectedTitleColor
            firstLabel.font = segmentStyle.selectedTitleFont

        }
        
        
    }
    
    // 再设置滚动条和cover的位置
    fileprivate func setupScrollLineAndCover() {
        if let line = scrollLine {
            line.backgroundColor = segmentStyle.scrollLineColor
            line.layer.cornerRadius = segmentStyle.scrollRadius
//            if segmentStyle.scrollLineColor != UIColor.white{
//                line.layer.shadowColor = segmentStyle.scrollLineColor.cgColor
//                line.layer.shadowRadius = segmentStyle.scrollRadius
//                line.layer.shadowOffset = CGSize(width: 0, height: 2)
//                line.layer.shadowOpacity = 0.50
//            }
            scrollView.addSubview(line)
            
        }
        if let cover = coverLayer {
            cover.backgroundColor = segmentStyle.coverBackgroundColor
            scrollView.insertSubview(cover, at: 0)
            
        }
        if labelsArray.count > 0{
            let coverX = labelsArray[0].frame.origin.x
            let coverW = labelsArray[0].frame.size.width
            let coverH: CGFloat = segmentStyle.coverHeight
            let coverY = (bounds.size.height - coverH) / 2
            if segmentStyle.scrollTitle {
                // 这里x-xGap width+wGap 是为了让遮盖的左右边缘和文字有一定的距离
                coverLayer?.frame = CGRect(x: coverX - CGFloat(xGap), y: coverY, width: coverW + CGFloat(wGap), height: coverH)
            } else {
                coverLayer?.frame = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
            }
            //底部分割线
            bottomLine.frame = CGRect(x: 0, y: bounds.size.height - 0.3, width: bounds.size.width, height: 0.3)
            scrollerWidth = ((self.segmentStyle.scrollLineWidth == 0) ? labelsArray[0].frame.size.width : self.segmentStyle.scrollLineWidth)
            let scrollerX:CGFloat = (labelsArray[0].frame.size.width-scrollerWidth)/2
            scrollLine?.frame = CGRect(x: coverX+scrollerX, y: bounds.size.height - segmentStyle.scrollLineHeight - segmentStyle.scrollLineToBottom, width: scrollerWidth, height: segmentStyle.scrollLineHeight)
            
        }
    }
    

}

extension ScrollSegmentView {
    // 自动或者手动点击按钮的时候调整UI
    private func adjustUIWhenBtnOnClickWithAnimate(_ animated: Bool) {
        // 重复点击时的相应, 这里没有处理, 可以传递给外界来处理
        if currentIndex == oldIndex { return }
//        firstTagLabel.textColor = currentIndex == 0 ? segmentStyle.selectedTitleColor : segmentStyle.normalTitleColor
//        firstTagLabel.font = currentIndex == 0 ? segmentStyle.selectedTitleFont : segmentStyle.titleFont
//        firstTagLine.backgroundColor = currentIndex == 0 ? segmentStyle.selectedTitleColor : .white
        
        let oldLabel = labelsArray[oldIndex] 
        let currentLabel = labelsArray[currentIndex] 
        
        adjustTitleOffSetToCurrentIndex(currentIndex)
        
        let animatedTime = animated ? 0.3 : 0.0
        UIView.animate(withDuration: animatedTime, animations: {[unowned self] in
            
            // 设置文字颜色
            oldLabel.textColor = self.segmentStyle.normalTitleColor
            oldLabel.font = self.segmentStyle.titleFont
            currentLabel.textColor = self.segmentStyle.selectedTitleColor
            currentLabel.font = self.segmentStyle.selectedTitleFont
            // 缩放文字
            if self.segmentStyle.scaleTitle {
                oldLabel.currentTransformSx = self.segmentStyle.titleOriginalScale
                
                currentLabel.currentTransformSx = self.segmentStyle.titleBigScale
                
            }
            
            
            // 设置滚动条的位置
            self.scrollLine?.frame.origin.x = currentLabel.frame.origin.x + (currentLabel.frame.size.width - self.scrollerWidth)/2
            self.scrollLine?.frame.size.width = self.scrollerWidth
            
            // 设置遮盖位置
            if self.segmentStyle.scrollTitle {
                self.coverLayer?.frame.origin.x = currentLabel.frame.origin.x - CGFloat(self.xGap)
                self.coverLayer?.frame.size.width = currentLabel.frame.size.width + CGFloat(self.wGap)
            } else {
                self.coverLayer?.frame.origin.x = currentLabel.frame.origin.x
                self.coverLayer?.frame.size.width = currentLabel.frame.size.width
            }
            
        }) 
        oldIndex = currentIndex
        
//        titleBtnOnClick?(currentLabel, currentIndex)
    }
    
    // 手动滚动时需要提供动画效果
    public func adjustUIWithProgress(_ progress: CGFloat,  oldIndex: Int, currentIndex: Int) {
        // 记录当前的currentIndex以便于在点击的时候处理
        self.oldIndex = currentIndex
        
        //        logOut("\(currentIndex)------------currentIndex")
        
        let oldLabel = labelsArray[oldIndex] 
        let currentLabel = labelsArray[currentIndex] 
        
        // 需要改变的距离 和 宽度
        let xDistance = currentLabel.frame.origin.x - oldLabel.frame.origin.x
        let wDistance = currentLabel.frame.size.width - oldLabel.frame.size.width
        
        // 横向滚动时，设置滚动条位置
        if scrollerWidth == oldLabel.frame.width{//滚动条长度和整个按钮长度一致，位置跟随滚动
            scrollLine?.frame.origin.x = oldLabel.frame.origin.x + xDistance * progress
        }else{////滚动条长度和整个按钮长度不一致，位置跟随滚动
//            logOut(progress)
            scrollLine?.frame.origin.x = oldLabel.frame.origin.x + (currentLabel.frame.width-scrollerWidth)/2 + xDistance * progress
        }
        scrollLine?.frame.size.width = scrollerWidth
    
        // 设置 cover位置
        if segmentStyle.scrollTitle {
            coverLayer?.frame.origin.x = oldLabel.frame.origin.x + xDistance * progress - CGFloat(xGap)
            coverLayer?.frame.size.width = oldLabel.frame.size.width + wDistance * progress + CGFloat(wGap)
        } else {
            coverLayer?.frame.origin.x = oldLabel.frame.origin.x + xDistance * progress
            coverLayer?.frame.size.width = oldLabel.frame.size.width + wDistance * progress
        }
        
        // 文字颜色渐变
        if segmentStyle.gradualChangeTitleColor {
            
            oldLabel.textColor = UIColor(red:selectedTitleColorRgb.r + rgbDelta.deltaR * progress, green: selectedTitleColorRgb.g + rgbDelta.deltaG * progress, blue: selectedTitleColorRgb.b + rgbDelta.deltaB * progress, alpha: 1.0)
            
            currentLabel.textColor = UIColor(red: normalColorRgb.r - rgbDelta.deltaR * progress, green: normalColorRgb.g - rgbDelta.deltaG * progress, blue: normalColorRgb.b - rgbDelta.deltaB * progress, alpha: 1.0)
            
            
        }
        
        
        // 缩放文字
        if !segmentStyle.scaleTitle {
            return
        }
        
        // 注意左右间的比例是相关连的, 加减相同
        // 设置文字缩放
        let deltaScale = (segmentStyle.titleBigScale - segmentStyle.titleOriginalScale)
        
        oldLabel.currentTransformSx = segmentStyle.titleBigScale - deltaScale * progress
        currentLabel.currentTransformSx = segmentStyle.titleOriginalScale + deltaScale * progress
        
        
    }
    // 居中显示title
    public func adjustTitleOffSetToCurrentIndex(_ cIndex: Int) {
        if labelsArray.count > 0{
            let currentLabel = labelsArray[cIndex]
            //        firstTagLabel.textColor = cIndex == 0 ? segmentStyle.selectedTitleColor : segmentStyle.normalTitleColor
            //        firstTagLabel.font = cIndex == 0 ? segmentStyle.selectedTitleFont : segmentStyle.titleFont
            //        firstTagLine.backgroundColor = cIndex == 0 ? segmentStyle.selectedTitleColor : .white
            var offSetX = currentLabel.center.x - currentWidth / 2
            if offSetX < 0 {
                offSetX = 0
            }
            var maxOffSetX = scrollView.contentSize.width - currentWidth
            
            // 可以滚动的区域小余屏幕宽度
            if maxOffSetX < 0 {
                maxOffSetX = 0
            }
            
            if offSetX > maxOffSetX {
                offSetX = maxOffSetX
            }
            
            scrollView.setContentOffset(CGPoint(x:offSetX, y: 0), animated: true)
            
            // 没有渐变效果的时候设置切换title时的颜色
            if !segmentStyle.gradualChangeTitleColor {
                for (index, label) in labelsArray.enumerated() {
                    if index == cIndex {
                        label.textColor = segmentStyle.selectedTitleColor
                        label.font = segmentStyle.selectedTitleFont
                    } else {
                        label.textColor = segmentStyle.normalTitleColor
                        label.font = segmentStyle.titleFont
                    }
                }
            }
            currentIndex = cIndex
            callbackCurrentIndex?(currentIndex)
        }
    }
    
    public func changedTitleLabelColor() {
        // 重新设置所有标题的颜色
        for (index, label) in labelsArray.enumerated() {
            if index == currentIndex {
                label.textColor = segmentStyle.selectedTitleColor
                label.font = segmentStyle.selectedTitleFont
            } else {
                label.textColor = segmentStyle.normalTitleColor
                label.font = segmentStyle.titleFont
            }
        }
        //重新设置指示器颜色
        scrollLine?.backgroundColor = segmentStyle.scrollLineColor
    }
}




open class CustomLabel: UILabel {
    /// 用来记录当前label的缩放比例
    open var currentTransformSx:CGFloat = 1.0 {
        didSet {
            transform = CGAffineTransform(scaleX: currentTransformSx, y: currentTransformSx)
        }
    }
}


