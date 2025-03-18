//
//  MusicModel.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//
import Foundation
import UIKit
import AVFoundation

final class MusicModel {
    /// 歌名、歌手、收藏、本地音频路径、海报路径、音乐时长
    public var songName: String
    public var singer: String
    public var isFavorite: Bool
    public var audioFileUrl: URL?
    public var posterStr: String
    public var duration: TimeInterval
    
    /// 静态只读计算属性，播放时长格式化器
    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        return formatter
    }()
    
    public var durationFormatted: String {
        MusicModel.durationFormatter.string(from: self.duration) ?? "未知时长"
    }
    
    init(songName: String, singer: String, isFavorite: Bool, audioFileUrl: URL? = nil, posterStr: String = "", duration: TimeInterval = 0.0) {
        self.songName = songName
        self.singer = singer
        self.isFavorite = isFavorite
        self.audioFileUrl = audioFileUrl
        self.posterStr = posterStr
        self.duration = duration
    }
}
