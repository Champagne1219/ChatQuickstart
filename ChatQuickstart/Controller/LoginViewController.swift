//
//  LoginViewController.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//

import UIKit
import OSLog
import HyphenateChat
import EaseChatUIKit
import SwiftFFDBHotFix

let LoginViewLogger = Logger(
    subsystem: "com.xieqiangbin.ChatQuickstart",
    category: "LoginViewController.debugging"
)

/// 登陆页视图控制器为确保隐私安全性和静态派发性能优化，定义该类无法被继承
final class LoginViewController: UIViewController {
    
    private var code: String = ""
    private var count: Int = 10
    var screenWidth: Double = 0.0
    var screenHeight: Double = 0.0
    
    @Storage(key: "ChatServerConfig", defaultValue: Dictionary<String, String>()) private var serverConfig: Dictionary<String, String>
    @Storage(key: "ChatUserToken", defaultValue: "") private var userToken: String
    @Storage(key: "ChatUserID", defaultValue: "") private var userId: String
    @Storage(key: "ChatUserPassword", defaultValue: "") private var userPassword: String
    @Storage(key: "ChatServerInfo", defaultValue: Dictionary<String, String>()) private var serverInfo: Dictionary<String, String>
    
    // MARK: - 懒加载定义UI属性
    /// 使用闭包来懒加载页面背景视图，只有首次真正访问时才进行初始化，而非创建时就进行初始化
    private lazy var background: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    /// App登陆状态展示
    private lazy var appName: UILabel = {
        let label = UILabel(frame: CGRect(x: 30, y: 187, width: self.screenWidth - 60, height: 35))
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        label.text = "ChatDemo   未登陆"
        label.textColor = .systemGray
        return label
    }()
    
    /// 用户ID标签
    private lazy var userIdLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 50, y: self.appName.frame.maxY + 22.0, width: 70, height: 48))
        label.text = "用户ID"
        label.textColor = DataManager.shared.darkMode ? .white : .black
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        return label
    }()
    
    /// 用户ID输入框
    // TODO: CALayer设置圆角和边框会触发离屏渲染，注意优化
    private lazy var phoneNumber: UITextField = {
        let textField = UITextField(frame: CGRect(x: 130, y: self.appName.frame.maxY + 22.0, width: self.screenWidth - 160, height: 48))
        textField.font = UIFont(name: "PingFangSC-Medium", size: 16)
        textField.placeholder = "输入用户ID"
        textField.text = self.userId
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 48))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 12.0
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.delegate = self
        return textField
    }()
    
    /// 密码标签
    private lazy var passwordLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 50, y: self.phoneNumber.frame.maxY + 24.0, width: 70, height: 48))
        label.text = "密码"
        label.textColor = DataManager.shared.darkMode ? .white : .black
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        return label
    }()
    
    /// 密码输入框
    private lazy var password: UITextField = {
        let textField = UITextField(frame: CGRect(x: 130, y: self.phoneNumber.frame.maxY + 24.0, width: self.screenWidth - 160, height: 48))
        textField.font = UIFont(name: "PingFangSC-Medium", size: 16)
        textField.placeholder = "请输入密码"
        if self.userPassword != "" {
            textField.text = self.userPassword
        }
        textField.isSecureTextEntry = true
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 48))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 12.0
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.delegate = self
        return textField
    }()
    
    // TODO: - 可能存在事件响应链传递的问题
    /// 登陆按钮
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 30, y: self.password.frame.maxY + 24.0, width: self.screenWidth - 60, height: 48)
        button.layer.cornerRadius = 12.0
        button.layer.masksToBounds = true
        button.setTitle("登入 / 登出", for: .normal)
        button.setTitleColor(DataManager.shared.darkMode ? .white : .black, for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-semibold", size: 16)
        button.addTarget(self, action: #selector(login(_:)), for: [.touchUpInside, .touchDragExit])
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: [.touchDown, .touchDragEnter])
        return button
    }()
    
    /// 登陆区域容器
    private lazy var loginContainer: UIView = {
        let view = UIView(frame: CGRect(x: 30, y: self.password.frame.maxY + 24.0, width: self.screenWidth - 60, height: 48))
        view.backgroundColor = UIColor.systemBlue
        return view
    }()
    
    /// 同意按钮
    private lazy var agreenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: self.loginButton.frame.minX + 5, y: self.loginButton.frame.maxY + 16, width: 20, height: 20)
        button.setImage(UIImage(named: "unselected"), for: .normal)
        button.setImage(UIImage(named: "selected"), for: .selected)
        button.isSelected = false
        button.addTarget(self, action: #selector(agreenAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    /// 记住密码按钮
    private lazy var rememberButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: self.loginButton.frame.minX + 5, y: self.agreenButton.frame.maxY + 16, width: 20, height: 20)
        button.setImage(UIImage(named: "unselected"), for: .normal)
        button.setImage(UIImage(named: "selected"), for: .selected)
        button.isSelected = true
        button.addTarget(self, action: #selector(rememberAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    /// 记住密码标签
    private lazy var rememberLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: self.rememberButton.frame.maxX + 8.0, y: self.agreenButton.frame.maxY + 16.0, width: self.screenWidth - 90 - 4, height: 20))
        label.text = "记住密码"
        label.textColor = DataManager.shared.darkMode ? .white : .black
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    /// 创建条款文本视图
    private lazy var protocolContainer: UITextView = {
        let textView = UITextView(frame: CGRect(x: self.agreenButton.frame.maxX + 4.0, y: self.loginButton.frame.maxY + 10.0, width: self.screenWidth - 90 - 4, height: 58))
        
        let attributedString = NSMutableAttributedString()
        
        let text1 = "请勾选同意 "
        let text1Attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.white,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 5
                return style
            }()
        ]
        attributedString.append(NSAttributedString(string: text1, attributes: text1Attributes))
        
        let link1Text = "服务"
        let link1Attributes : [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor : UIColor.white,
            .underlineStyle : NSUnderlineStyle.single.rawValue,
            .underlineColor : UIColor.systemBlue,
            .link : URL(string: "https://www.easemob.com/terms/im")!,
            .paragraphStyle : {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 5
                return style
            }()
        ]
        attributedString.append(NSAttributedString(string: link1Text, attributes: link1Attributes))
        
        let text2 = " 和 "
        let text2Attributes = text1Attributes
        attributedString.append(NSAttributedString(string: text2, attributes: text2Attributes))
        
        let link2Text = "隐私政策"
        let link2Attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.systemBlue,
            .link: URL(string: "https://www.easemob.com/protocol")!,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 5
                return style
            }()
        ]
        attributedString.append(NSAttributedString(string: link2Text, attributes: link2Attributes))
        
        textView.attributedText = attributedString
        textView.isEditable = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    // MARK: - 定义加载视图的工厂方法
    public private(set) lazy var loadingView: LoadingView = {
        self.createLoading()
    }()
    
    @objc public func createLoading() -> LoadingView {
        LoadingView(frame: self.view.bounds)
    }
    
    // MARK: - 定时器属性创建
    private lazy var timer: GCDTimer? = {
        GCDTimerMaker.exec({
            self.timerFire()
        }, interval: 1, repeats: true)
    }()
    
    // MARK: - 当前视图控制器生命周期管理
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.window?.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenWidth = self.view.frame.width
        self.screenHeight = self.view.frame.height
        self.view.addSubviews(
            [self.background, self.appName, self.phoneNumber, self.password,  self.loginContainer, self.loginButton, self.agreenButton, self.protocolContainer, self.loadingView, self.passwordLabel, self.userIdLabel, self.rememberLabel, self.rememberButton])
        self.loadingView.isHidden = true
        self.setContainerShadow()
    }
    
    // MARK: - 动态派发方法定义
    /// 登陆按钮点击动画
    @objc private func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }
    
    /// 登陆按钮点击响应事件
    @objc private func login(_ sender: UIButton) {
        print("用户点击了登陆按钮")
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
        if self.agreenButton.isSelected == false {
            let alert = UIAlertController(
                title: "未经授权",
                message: "阅读完成后点击同意授权即可继续登陆",
                preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "去阅读", style: .default)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            self.loginWithPassword()
        }
        return
    }
    
    // "YWMtdxzzdO4uEe-5vjkgfxnDLPStw32vp0Hzq5ExBhB1T8p2HM0A7i4R75eMs9Yo9ERdAwMAAAGVGogUXjeeSAD6UlvfMwSFvKvbBw0EvYHRm1rSWhhX1L9SP66PHGoK9Q"
    
    /// 用户ID + 密码登陆
    private func loginWithPassword() {
        guard let userId = phoneNumber.text, !userId.isEmpty else { return }
        guard let password = password.text, !password.isEmpty else { return }
        EMClient.shared().login(withUsername: userId, password: password) { userId, err in
            if err == nil {
                self.userId = userId
                if self.rememberButton.isSelected {
                    self.userPassword = self.password.text ?? ""
                } else {
                    self.userPassword = ""
                }
                self.timer?.resume()
                DispatchQueue.main.async{
                    self.appName.text = "ChatDemo   已登陆"
                    self.appName.textColor = .systemGreen
                }
            } else {
                EMClient.shared().logout(true) { aError in
                    if aError == nil {
                        print("退出成功")
                        self.timer?.resume()
                        DispatchQueue.main.async{
                            self.appName.text = "ChatDemo   未登陆"
                            self.appName.textColor = .systemGray
                        }
                    } else {
                        print("退出失败")
                    }
                }
            }
        }
    }
    
    /// 同意条款
    @objc func agreenAction(sender: UIButton) {
        print("用户点击了同意")
        sender.isSelected.toggle()
    }
    
    /// 记住密码
    @objc func rememberAction(sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            print("用户选择记住密码")
        } else {
            print("用户选择忘记密码")
        }
    }
    
    // MARK: - 视图控制器成员方法实现
    /// 登陆视图容器阴影设置
    private func setContainerShadow() {
        self.loginContainer.layer.cornerRadius = 14
        self.loginContainer.layer.shadowRadius = 8
        self.loginContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.loginContainer.layer.shadowColor = UIColor.lightGray.cgColor
        self.loginContainer.layer.shadowOpacity = 1
    }
    
}

// MARK: - 扩展当前视图控制器遵守键盘输入协议的方法
extension LoginViewController: UITextFieldDelegate {
    
    /// 放弃“第一响应者”身份，当用户在键盘中点击Return键时将响应向下传递，从而隐藏键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// 全局监听屏幕触摸事件，强制隐藏键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    /// 用户输入处理
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    }
    
    /// 进行倒计时
    func timerFire() {
        /// 需要频繁强制切换主线程，所以可以加入当前线程判断
        if Thread.isMainThread {
            self.count -= 1
            if self.count <= 0 {
                self.timer?.suspend()
                self.getAgain()
            } else {
                self.startCountdown()
            }
        } else {
            DispatchQueue.main.async {
                self.count -= 1
                if self.count <= 0 {
                    self.timer?.suspend()
                    self.getAgain()
                } else {
                    self.startCountdown()
                }
            }
        }
    }
    
    private func startCountdown() {
        DispatchQueue.main.async {
            self.loginButton.isEnabled = false
        }
    }
    
    private func getAgain() {
        DispatchQueue.main.async {
            self.loginButton.isEnabled = true
            self.count = 10
        }
    }
}


// MARK: - 扩展UIView成员方法
extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach{
            addSubview($0)
        }
    }
}
