//
//  MusicPlayViewController.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//

import UIKit
import AVFoundation
import ActivityKit
import OSLog

let MusicPlayViewLogger = Logger(
    subsystem: "com.xieqiangbin.ChatQuickstart",
    category: "MusicPlayViewController.debugging"
)

class MusicPlayViewController: UIViewController, Nextable{
    public var musicModelList: [MusicModel]
    public var currentIndex: Int
    private var currentMusic: MusicModel
    
    private var musicPlayer: MusicPlayer
    private var state: playState = .stop
    /// 播放状态读写队列
    private var stateQueue = DispatchQueue(label: "com.ChatQuickstart.state.queue")
    /// 播放状态切换时触发的回调闭包数组
    private var stateHandler: [()->Void] = []
    
    private var musicPlayActivity: Activity<MusicPlayAttributes>? = nil
    
    private let rotationAnimationKey = "rotationAnimation"
    
    init(musicModelList: [MusicModel], currentIndex: Int) {
        self.musicModelList = musicModelList
        self.currentIndex = currentIndex
        self.currentMusic = musicModelList[currentIndex]
        self.musicPlayer = MusicPlayer.sharedInstance
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 视图消失按钮(需要扩大响应区域)
    public lazy var dismissButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 20, y: 60, width: 30, height: 20))
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return button
    }()
    
    /// 音乐播放旋转海报
    public lazy var musicPoster: UIImageView = {
        let poster = UIImageView(frame: CGRect(x: 70, y: 130, width: 300, height: 300))
        poster.layer.cornerRadius = poster.frame.width / 2
        poster.layer.masksToBounds = true
        poster.contentMode = .scaleAspectFill
        return poster
    }()
    
    /// 歌名
    public lazy var songName: UILabel = {
        let label = UILabel(frame: CGRect(x: 30, y: musicPoster.frame.maxY + 30, width: 370, height: 30))
        label.font = UIFont(name: "PingFangSC-Medium", size: 25)
        return label
    }()
    
    /// 歌手
    public lazy var singer: UILabel = {
        let label = UILabel(frame: CGRect(x: 30, y: songName.frame.maxY + 10, width: 370, height: 24))
        label.font = UIFont(name: "PingFangSC", size: 20)
        return label
    }()
    
    /// 播放进度条控件
    public lazy var playerSlider: UISlider = {
        let slider = UISlider(frame: CGRect(x: 30, y: singer.frame.maxY + 40, width: 370, height: 5))
        slider.minimumValue = 0
        slider.setThumbImage(UIImage(systemName: "circlebadge.fill"), for: .normal)
        return slider
    }()
    
    /// 当前播放进度时间
    public lazy var currentTime: UILabel = {
        let label = UILabel(frame: CGRect(x: 30, y: playerSlider.frame.maxY + 20, width: 60, height: 20))
        label.font = UIFont(name: "PingFangSC", size: 15)
        return label
    }()
    
    /// 完整播放时间
    public lazy var totalTime: UILabel = {
        let label = UILabel(frame: CGRect(x: 340, y: playerSlider.frame.maxY + 20, width: 60, height: 20))
        label.font = UIFont(name: "PingFangSC", size: 15)
        return label
    }()
    
    /// 上一首
    public lazy var previousButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 85, y: playerSlider.frame.maxY + 70, width: 40, height: 40))
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tag = -1
        button.setImage(UIImage(systemName: "backward.end.fill"), for: .normal)
        button.addTarget(self, action: #selector(switchAction), for: .touchUpInside)
        return button
    }()
    
    /// 下一首
    public lazy var nextButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 290, y: playerSlider.frame.maxY + 70, width: 40, height: 40))
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tag = 1
        button.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        button.addTarget(self, action: #selector(switchAction), for: .touchUpInside)
        return button
    }()
    
    /// 播放暂停按钮
    public lazy var playButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 180, y: playerSlider.frame.maxY + 60, width: 60, height: 60))
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        button.addTarget(self, action: #selector(pauseResumeAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.stateHandler.append(contentsOf: [self.startHandler, self.pauseHandler, self.resumeHandler, self.stopHandler])
        self.musicInfoSet()
        self.themeSet()
        self.view.addSubViews([dismissButton, songName, singer, playerSlider, currentTime, totalTime, previousButton, nextButton, playButton, musicPoster])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let url = self.currentMusic.audioFileUrl {
            self.musicPlayer.setupPlayer(url: url, musicPlayerVC: self)
            self.stateSetter(state: .playing)
        }
    }
    
    func musicInfoSet() {
        self.musicPoster.image = UIImage(named: currentMusic.posterStr)
        self.songName.text = currentMusic.songName
        self.singer.text = currentMusic.singer
        self.playerSlider.maximumValue = Float(currentMusic.duration)
        self.currentTime.text = "00:00"
        self.totalTime.text = currentMusic.durationFormatted
        self.playButton.isSelected = true
    }
    
    func themeSet(color: UIColor = .systemBlue) {
        self.dismissButton.tintColor = color
        self.songName.textColor = color
        self.singer.textColor = color.withAlphaComponent(0.5)
        self.playerSlider.tintColor = color
        self.currentTime.textColor = color.withAlphaComponent(0.5)
        self.totalTime.textColor = color.withAlphaComponent(0.5)
        self.previousButton.tintColor = color
        self.nextButton.tintColor = color
        self.playButton.tintColor = color
        self.playButton.layer.borderColor = color.cgColor
    }
    
    func stateSetter(state: playState) {
        self.state.stateChange(state, stateHandler)
        self.stateQueue.async{
            self.state = state
        }
    }
    
    func nextAction() {
        self.currentIndex = (self.currentIndex + self.musicModelList.count + 1) % (self.self.musicModelList.count)
        self.currentMusic = self.musicModelList[self.currentIndex]
        DispatchQueue.main.async {
            self.stateSetter(state: .stop)
            self.musicInfoSet()
            if let url = self.currentMusic.audioFileUrl {
                self.musicPlayer.playAnotherAction(url: url)
            }
            self.stateSetter(state: .playing)
        }
    }
    
    @objc func dismissAction() {
        self.dismiss(animated: true)
    }
    
    @objc func switchAction(sender: UIButton) {
        self.currentIndex = (self.currentIndex + self.musicModelList.count + sender.tag) % (self.self.musicModelList.count)
        self.currentMusic = self.musicModelList[self.currentIndex]
        DispatchQueue.main.async {
            self.stateSetter(state: .stop)
            self.musicInfoSet()
            if let url = self.currentMusic.audioFileUrl {
                self.musicPlayer.playAnotherAction(url: url)
            }
            self.stateSetter(state: .playing)
        }
    }
    
    @objc func pauseResumeAction() {
        self.playButton.isSelected.toggle()
        switch playButton.isSelected {
        case true:
            self.stateSetter(state: .playing)
            self.musicPlayer.playAction()
        case false:
            self.stateSetter(state: .pause)
            self.musicPlayer.pauseAction()
        }
    }
    
    func startHandler() {
        startRotaion()
        openIsland()
        updateIsland()
    }
    
    func pauseHandler() {
        pauseRotaion()
        closeIsland()
    }
    
    func resumeHandler() {
        resumeRotaion()
        openIsland()
    }
    
    func stopHandler() {
        stopRotaion()
        closeIsland()
    }
    
    func startRotaion() {
        MusicPlayViewLogger.info("海报开始旋转")
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = NSNumber(value: Double.pi*2)
        rotationAnimation.duration = 10
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.infinity
        self.musicPoster.layer.add(rotationAnimation, forKey: self.rotationAnimationKey)
    }
    
    func pauseRotaion() {
        MusicPlayViewLogger.info("海报暂停旋转")
        let pauseTime = self.musicPoster.layer.convertTime(CACurrentMediaTime(), from: nil)
        self.musicPoster.layer.speed = 0.0
        self.musicPoster.layer.timeOffset = pauseTime
    }
    
    func resumeRotaion() {
        MusicPlayViewLogger.info("海报恢复旋转")
        let pausedTime = musicPoster.layer.timeOffset
        self.musicPoster.layer.speed = 1.0
        self.musicPoster.layer.timeOffset = 0.0
        self.musicPoster.layer.beginTime = 0.0
        let timeSincePause = musicPoster.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        self.musicPoster.layer.beginTime = timeSincePause
    }
    
    func stopRotaion() {
        MusicPlayViewLogger.info("海报取消旋转")
        self.musicPoster.layer.removeAnimation(forKey: self.rotationAnimationKey)
    }
    
    func openIsland() {
        let initialContentState = MusicPlayAttributes.ContentState(isFavorite: self.currentMusic.isFavorite, currentProgress: self.currentMusic.durationFormatted, isPlaying: self.state == .playing ? true : false)
        let activityAttributes = MusicPlayAttributes(songName: self.currentMusic.songName, musicPosterStr: self.currentMusic.posterStr, totalDuration: self.currentMusic.durationFormatted, singer: self.currentMusic.singer)
        do {
            musicPlayActivity = try Activity.request(attributes: activityAttributes, content: ActivityContent<MusicPlayAttributes.ContentState>(state: initialContentState, staleDate: nil))
            MusicPlayViewLogger.info("已经打开灵动岛，当前正在播放\(self.currentMusic.songName)")
        } catch(let error) {
            MusicPlayViewLogger.error("Error requesting music play Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateIsland() {
        let updateMusicPlayStatus = MusicPlayAttributes.ContentState(isFavorite: self.currentMusic.isFavorite, currentProgress: self.currentMusic.durationFormatted, isPlaying: self.state == .playing ? true : false)
        Task{
            await musicPlayActivity?.update(ActivityContent<Activity<MusicPlayAttributes>.ContentState>(state: updateMusicPlayStatus, staleDate: nil))
            MusicPlayViewLogger.info("灵动岛已经更新")
        }
    }
    
    func closeIsland() {
        Task {
            await musicPlayActivity?.end(ActivityContent<MusicPlayAttributes.ContentState>(state: MusicPlayAttributes.ContentState(isFavorite: self.currentMusic.isFavorite, currentProgress: self.currentMusic.durationFormatted, isPlaying: self.state == .playing ? true : false), staleDate: nil), dismissalPolicy: .immediate)
            musicPlayActivity = nil
            MusicPlayViewLogger.info("灵动岛已经关闭")
        }
    }
    
}
