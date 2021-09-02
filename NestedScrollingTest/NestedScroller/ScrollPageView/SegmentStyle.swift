//
//  SegmentStyle.swift
//  ScrollViewController
//
//  Created by jasnig on 16/4/13.
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


public struct SegmentStyle {
    /// 是否显示遮盖
    public var showCover = false
    /// 是否显示下划线
    public var showLine = false
    /// 是否缩放文字
    public var scaleTitle = false
    /// 是否可以滚动标题
    public var scrollTitle = true
    ///导航条高度
    public var scrollHeight:CGFloat = 40
    /// 是否颜色渐变
    public var gradualChangeTitleColor = false
    /// 是否显示附加的按钮
    public var showExtraButton = false
    
    /// 背景颜色
    public var backgroundColor = UIColor.white
    public var backgroundLayer:CAGradientLayer?
    
    public var extraBtnBackgroundImageName: String?
    /// 下面的滚动条的高度 默认2
    public var scrollLineHeight: CGFloat = 2
    /// 下面的滚动条的高度 默认0,会显示和bt宽度一致
    public var scrollLineWidth: CGFloat = 0

    /// 下面的滚动条的颜色,如果不是白色 , (❌会有线条同色阴影)
    public var scrollLineColor = UIColor.black
    ///滚动条距底部距离，默认是0
    public var scrollLineToBottom: CGFloat = 0
    ///滚动条的圆角
    public var scrollRadius:CGFloat = 0

    
    
    /// 遮盖的背景颜色
    public var coverBackgroundColor = UIColor.orange
    /// 遮盖圆角
    public var coverCornerRadius = 14.0
    
    /// cover的高度 默认28
    public var coverHeight: CGFloat = 28.0
    /// 文字间的间隔 默认15  scrollTitle为true有效
    public var titleMargin: CGFloat = 0
    ///标题可滚动时,第一个label距离左边的距离
    public var firstTitleToLeft:CGFloat = 0
    /// 文字 字体 默认14.0
    public var titleFont = UIFont.systemFont(ofSize: 14.0)
    ///选中的字体
    public var selectedTitleFont = UIFont.systemFont(ofSize: 14.0)

    /// 放大倍数 默认1.3
    public var titleBigScale: CGFloat = 1.3
    /// 默认倍数 不可修改
    let titleOriginalScale: CGFloat = 1.0
    
    /// 文字正常状态颜色 请使用RGB空间的颜色值!! 如果提供的不是RGB空间的颜色值就可能crash
    public var normalTitleColor = UIColor(red: 51.0/255.0, green: 53.0/255.0, blue: 75/255.0, alpha: 1.0)
    /// 文字选中状态颜色 请使用RGB空间的颜色值!! 如果提供的不是RGB空间的颜色值就可能crash
    public var selectedTitleColor = UIColor(red: 255.0/255.0, green: 128.0/255.0, blue: 0/255.0, alpha: 1.0)
    
    public init() {
        
    }
    
}
