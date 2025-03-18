//
//  LandViewController.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//

import UIKit

class LandViewController: UIViewController {
    
    // 边框视图
    private var borderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置背景颜色
        view.backgroundColor = .black
        
        // 创建边框视图
        createBorderView()
    }
    
    private func createBorderView() {
        // 边框尺寸
        let borderWidth: CGFloat = 140
        let borderHeight: CGFloat = 60
        let cornerRadius: CGFloat = 20
        
        // 边框位置
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let borderX = (screenWidth - borderWidth) / 2
        let borderY: CGFloat = 60 // 距离屏幕顶部的距离
        
        // 初始化边框视图
        borderView = UIView(frame: CGRect(x: borderX, y: borderY, width: borderWidth, height: borderHeight))
        
        // 设置边框样式
        borderView.backgroundColor = .clear
        borderView.layer.cornerRadius = cornerRadius
        borderView.layer.borderWidth = 2
        borderView.layer.borderColor = UIColor.blue.cgColor
        
        // 添加到视图
        view.addSubview(borderView)
    }
}
