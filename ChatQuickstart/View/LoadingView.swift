//
//  LoadingView.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//


import UIKit

/// 自定义加载指示器视图（支持动态配置）
public final class LoadingView: UIView {
    
    // MARK: - 子视图
    
    /// 半透明背景视图
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 系统活动指示器
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    /// 统一UI配置方法
    private func setupUI() {
        addSubview(backgroundView)
        backgroundView.addSubview(activityIndicator)
        
        // 使用自动布局实现动态适配
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 80),
            backgroundView.heightAnchor.constraint(equalTo: backgroundView.widthAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        ])
    }
    
    // MARK: - 公共方法
    
    /// 开始加载动画
    public func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    /// 停止加载动画
    public func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - 配置属性
    
    /// 自定义指示器颜色
    public var indicatorColor: UIColor {
        get { activityIndicator.color ?? .white }
        set { activityIndicator.color = newValue }
    }
    
    /// 自定义背景样式
    public func configureBackground(
        color: UIColor = .black,
        alpha: CGFloat = 0.5,
        cornerRadius: CGFloat = 10
    ) {
        backgroundView.backgroundColor = color.withAlphaComponent(alpha)
        backgroundView.layer.cornerRadius = cornerRadius
    }
}
