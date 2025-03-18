//
//  MusicListViewController.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//

import UIKit
import OSLog

class MusicListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var screenWidth: Double = 0.0
    private var screenHeight: Double = 0.0
    private var musicModelList: [MusicModel] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: (self.screenWidth - 200)/2, y: 100, width: 200, height: 40))
        label.text = "我的本地歌单"
        label.textColor = .white
        label.font = UIFont(name: "PingFangSC-Medium", size: 25)
        return label
    }()
    
    private lazy var musicList: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: titleLabel.frame.maxY + 40, width: view.frame.width, height: view.frame.height - titleLabel.frame.maxY - 40), style: .plain)
        tableView.register(MusicCell.self, forCellReuseIdentifier: "MusicCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMusicModel()
        self.screenWidth = self.view.frame.width
        self.screenHeight = self.view.frame.height
        self.musicList.dataSource = self
        self.musicList.delegate = self
        self.view.addSubViews([titleLabel, musicList])
    }
    
    func loadMusicModel()  {
        if let posterStr = Bundle.main.path(forResource: "Sara_Smile", ofType: "jpg"),
           let audioStr = Bundle.main.path(forResource: "Sara_Smile", ofType: "m4a") {
            let audioUrl = URL(fileURLWithPath: audioStr)
            let music1 = MusicModel(songName: "Sara Smile", singer: "Daryl Hall & John Oates", isFavorite: false, audioFileUrl: audioUrl, posterStr: posterStr, duration: 45.0)
            self.musicModelList.append(contentsOf: [music1])
        }
        if let posterStr = Bundle.main.path(forResource: "Oops", ofType: "jpg"),
           let audioStr = Bundle.main.path(forResource: "Oops", ofType: "m4a") {
            let audioUrl = URL(fileURLWithPath: audioStr)
            let music1 = MusicModel(songName: "Oops", singer: "Little Mix & Charlie Puth", isFavorite: false, audioFileUrl: audioUrl, posterStr: posterStr, duration: 45.0)
            self.musicModelList.append(contentsOf: [music1])
        }
        if let posterStr = Bundle.main.path(forResource: "Vincent", ofType: "jpg"),
           let audioStr = Bundle.main.path(forResource: "Vincent", ofType: "m4a") {
            let audioUrl = URL(fileURLWithPath: audioStr)
            let music1 = MusicModel(songName: "Vincent", singer: "Ellie Goulding", isFavorite: false, audioFileUrl: audioUrl, posterStr: posterStr, duration: 45.0)
            self.musicModelList.append(contentsOf: [music1])
        }
        if let posterStr = Bundle.main.path(forResource: "再见深海", ofType: "jpg"),
           let audioStr = Bundle.main.path(forResource: "再见深海", ofType: "m4a") {
            let audioUrl = URL(fileURLWithPath: audioStr)
            let music1 = MusicModel(songName: "再见深海", singer: "唐汉霄", isFavorite: false, audioFileUrl: audioUrl, posterStr: posterStr, duration: 45.0)
            self.musicModelList.append(contentsOf: [music1])
        }
        if let posterStr = Bundle.main.path(forResource: "就是哪吒", ofType: "jpg"),
           let audioStr = Bundle.main.path(forResource: "就是哪吒", ofType: "m4a") {
            let audioUrl = URL(fileURLWithPath: audioStr)
            let music1 = MusicModel(songName: "就是哪吒", singer: "唐汉霄", isFavorite: false, audioFileUrl: audioUrl, posterStr: posterStr, duration: 45.0)
            self.musicModelList.append(contentsOf: [music1])
        }
        if let posterStr = Bundle.main.path(forResource: "乐园游梦记", ofType: "jpg"),
           let audioStr = Bundle.main.path(forResource: "乐园游梦记", ofType: "m4a") {
            let audioUrl = URL(fileURLWithPath: audioStr)
            let music1 = MusicModel(songName: "乐园游梦记", singer: "三Z-STUDIO/HOYO-MiX", isFavorite: false, audioFileUrl: audioUrl, posterStr: posterStr, duration: 45.0)
            self.musicModelList.append(contentsOf: [music1])
        }
    }
    
    /// 设置单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicModelList.count
    }
    
    /// 配置单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as? MusicCell else {
            fatalError("")
        }
        if !musicModelList.isEmpty {
            let music = musicModelList[indexPath.row]
            cell.musicIndexLabel.text = "\(indexPath.row + 1)"
            cell.musicNameLabel.text = music.songName
            cell.singerLabel.text = music.singer
            cell.favoriteButton.isSelected = music.isFavorite
            cell.durationLabel.text = music.durationFormatted
            cell.musicPhoto.image = UIImage(contentsOfFile: music.posterStr)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let musicPlayVC = MusicPlayViewController(musicModelList: self.musicModelList, currentIndex: indexPath.row)
        musicPlayVC.modalPresentationStyle = .fullScreen
        musicPlayVC.modalTransitionStyle = .coverVertical
        present(musicPlayVC, animated: true)
    }

}
