//
//  SceneDelegate.swift
//  ChatQuickstart
//
//  Created by 谢强彬 on 2025/2/13.
//

import UIKit
import OSLog

let SceneLogger = Logger(
    subsystem: "com.xieqiangbin.ChatQuickstart",
    category: "SceneDelegate.debugging"
)

// 屏幕宽度为440，高度为874
// 顶部安全高度：62， 底部安全高度：34，tabBar高度：49

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    /* iOS13.0+以上的版本，定义导航栏控制器是需要在Scenedelegate中实现的 */
    // 因为iOS13+中的AppDelegate已经移除了window字段，即使手动创建也无法关联，所以需要在SceneDelegate中创建以保证每个独立的场景拥有独立的UIWindow
    // AppDelegate 不再直接管理窗口和视图层次结构，而是专注于全局应用级别的生命周期事件
    // SceneDelegate 用于管理独立场景的生命周期事件
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        SceneLogger.info("当前场景会话正在被创建...")
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 初始化记录聊天外观模式
        DataManager.shared.darkMode = window?.traitCollection.userInterfaceStyle == .dark ? true : false
        
        // 创建窗口
        window = UIWindow(windowScene: windowScene)
        window?.frame = UIScreen.main.bounds
        
        // 创建UITabBarController对象才可以使用viewControllers属性管理选项卡
        let tabBarController = UITabBarController()
        
        // 创建两个独立的视图控制器
        let musicVC = MusicListViewController()
        let loginVC = LoginViewController()
        let landVC = LandViewController()
        
        // 设置每个视图控制器的标题和图标
        musicVC.tabBarItem = UITabBarItem(title: "音乐", image: UIImage(systemName: "music.note.list"), tag: 0)
        landVC.tabBarItem = UITabBarItem(title: "登陆", image: UIImage(systemName: "person.circle"), tag: 1)
        
        tabBarController.viewControllers = [musicVC, loginVC]
        
        // 创建 UINavigationController，并将根视图控制器设置为tabBarController
        let navigationController = UINavigationController(rootViewController: tabBarController)
        
        // 设置窗口的根视图控制器为 navigationController
        window?.rootViewController = navigationController
        
        // 显示窗口
        window?.makeKeyAndVisible()
    }
    
    // 外观模式切换
    private func switchTheme() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            DataManager.shared.darkMode.toggle()
            let currentMode: UIUserInterfaceStyle = DataManager.shared.darkMode ? .dark : .light
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = currentMode
            }
            SceneLogger.info("用户切换外观模式至\(currentMode == .dark ? "深色模式" : "浅色模式")")
        }
    }
    
    /* 当场景被系统释放时调用 */
    func sceneDidDisconnect(_ scene: UIScene) {
        SceneLogger.info("场景会话正在被系统释放...")
    }
    
    /* 当场景从非活跃状态转变为活跃状态时调用 */
    func sceneDidBecomeActive(_ scene: UIScene) {
        SceneLogger.info("应用程序正在由非活跃态进入活跃态...")
    }
    
    /* 当场景从活跃状态转变为非活跃状态时调用 */
    // 非活跃状态：收到通知、系统弹窗、控制中心、应用内模态视图、多窗口切换、设备锁定
    func sceneWillResignActive(_ scene: UIScene) {
        SceneLogger.info("当前场景会话正在由活跃状态跃迁至非活跃状态...")
    }
    
    /* 当场景从后台转变为前台时调用 */
    func sceneWillEnterForeground(_ scene: UIScene) {
        SceneLogger.info("当前场景会话正在由后台状态跃迁至前台状态...")
    }
    
    /* 当场景从前台转变为后台时调用 */
    func sceneDidEnterBackground(_ scene: UIScene) {
        SceneLogger.info("当前场景会话正在由前台状态跃迁至后台状态...")
    }
    
    
}

