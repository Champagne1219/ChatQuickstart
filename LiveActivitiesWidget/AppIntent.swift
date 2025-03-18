//
//  AppIntent.swift
//  LiveActivitiesWidget
//
//  Created by 谢强彬
//

import AppIntents
import WidgetKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public struct ToggleFavoriteIntent: AppIntent {
    
    public init() {}
    
    public static var title: LocalizedStringResource = "切换收藏状态"
    
    @Parameter(title: "收藏")
    var isFavorite: Bool
    
    init(isFavorite: Bool) {
        self.isFavorite = isFavorite
    }
    
    public func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .toggleFavorite, object: isFavorite)
        return .result()
    }
    
}

// 播放/暂停 Intent
struct TogglePlaybackIntent: AppIntent {
    init() {}
    
    static var title: LocalizedStringResource = "切换播放状态"
    @Parameter(title: "歌曲ID")
    var songName: String
    
    init(songName: String) {
        self.songName = songName
    }
    
    func perform() async throws -> some IntentResult {
        print("点击！！！！！")
        
        NotificationCenter.default.post(name: .togglePlayback, object: songName)
        return .result()
    }
}

// 切歌 Intent
struct SkipSongIntent: AppIntent {
    init() {}
    
    static var title: LocalizedStringResource = "切歌"
    @Parameter(title: "方向")
    var direction: Int
    
    init(direction: Int) {
        self.direction = direction
    }
    
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .skipSong, object: direction)
        return .result()
    }
}
