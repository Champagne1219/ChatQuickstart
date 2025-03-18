//
//  MusicPlayer.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//
import AVFoundation
import OSLog

let MusicPlayerLogger = Logger(
    subsystem: "com.xieqiangbin.ChatQuickstart",
    category: "MusicPlayer.debugging"
)

public enum playState {
    case playing
    case pause
    case stop
    
    /// 通过有限状态机模式进行状态切换回调
    func stateChange(_ state: playState, _ handler: [()-> Void]) {
        switch (self, state) {
        case (.stop, .playing): handler[0]()
        case (.playing, .pause): handler[1]()
        case (.pause, .playing): handler[2]()
        case (.playing, .stop): handler[3]()
        case (.pause, .pause), (.pause, .stop), (.playing, .playing), (.stop, .pause), (.stop, .stop): break
        }
    }
}

class MusicPlayer: AVPlayer{
    public var url: URL?
    private var player: AVPlayer?
    /// 遵循协议的任何音乐播放视图控制器都可以（目前只设计了MusicPlayViewController）
    public var musicPalyerVC: Nextable?
    /// 单例模式，避免多个播放器
    public static var sharedInstance = MusicPlayer()
    private var playeItem: AVPlayerItem?
    
    private init(url: URL? = nil, player: AVPlayer? = nil) {
        self.url = url
        self.player = player
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        super.init()
    }
    
    public func setupPlayer(url: URL, musicPlayerVC: MusicPlayViewController) {
        /// 创建媒体资源并初始化播放器
        if self.player == nil {
            self.musicPalyerVC = musicPlayerVC
            self.url = url
            let playItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: playItem)
            /// 注册音乐播放结束监听通知
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: AVPlayerItem.didPlayToEndTimeNotification, object: playItem)
            playAction()
        } else {
            self.playAnotherAction(url: url)
        }
        
    }
    
    func playAction() {
        self.player?.play()
    }
    
    func pauseAction() {
        self.player?.pause()
    }
    
    func playAnotherAction(url: URL) {
        if self.player?.rate != 0.0 {
            self.pauseAction()
        }
        let playerItem = AVPlayerItem(url: url)
        self.player?.replaceCurrentItem(with: playerItem)
        playAction()
    }
    
    @objc func playerDidFinishPlaying(notification: Notification) {
        MusicPlayerLogger.info("当前音乐播放结束,即将播放下一首歌")
        /// 更新监听关联对象
        NotificationCenter.default.removeObserver(self)
        self.musicPalyerVC?.nextAction()
        if let playItem = playeItem {
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: AVPlayerItem.didPlayToEndTimeNotification, object: playItem)
        }
    }
    
    deinit {
        /// 移除监听，防止内存泄漏
        NotificationCenter.default.removeObserver(self)
    }
    
}
