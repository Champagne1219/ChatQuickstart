//
//  AppDelegate.swift
//  ChatQuickstart
//
//  Created by 谢强彬 on 2025/2/13.
//

import UIKit
import OSLog

let AppLogger = Logger(
    subsystem: "com.xieqiangbin.ChatQuickstart",
    category: "AppDelegate.debugging"
)

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppLogger.info("全局应用级别初始化执行中...")
        // 通过环信即时通信IM管理后台注册应用中的 App Key
        /// let options: EMOptions = EMOptions(appkey: "1114250213193379#demo")
        // APNs推送证书名称只能在初始化时进行设定，App运行期间不可以修改，暂定为nil
        /// options.apnsCertName = nil
        // Client 类是 chat 的入口，在调用任何其他方法前，需要先调用该方法创建一个 Client 实例
        /// EMClient.shared().initializeSDK(with: options)
        
        /// 灵动岛控件监听
        NotificationCenter.default.addObserver(self, selector: #selector(handleTogglePlagback(_:)), name: .togglePlayback, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSkipSong(_:)), name: .skipSong, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleToogleLike(_:)), name: .toggleFavorite, object: nil)
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    /* 当一个新的场景会话正在被创建时，系统会调用这个方法，主要用于新创建的场景选择合适的配置 */
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        AppLogger.info("新的场景会话正在创建...")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    /* 当用户丢弃场景会话时，系统会调用这个方法 */
    // Note: 如果在应用程序已经创建但还未运行时某些场景会话被丢弃，那么应用在正式启动完成后会调用此方法
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        AppLogger.info("已创建的场景会话正在销毁...")
    }
    
    @objc func handleToogleLike(_ notification: Notification) {
        print("用户在灵动岛上点击了收藏/取消")
    }
    
    @objc func handleTogglePlagback(_ notification: Notification) {
        print("用户在灵动岛上点击了暂停/播放")
    }
    
    @objc func handleSkipSong(_ notification: Notification) {
        print("用户在灵动岛上点击了切歌")
    }

}

