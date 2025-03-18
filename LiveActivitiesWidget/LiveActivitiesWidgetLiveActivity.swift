//
//  LiveActivitiesWidgetLiveActivity.swift
//  LiveActivitiesWidget
//
//  Created by 谢强彬
//

import ActivityKit
import WidgetKit
import SwiftUI

/// 实时活动组件
@main
struct LiveActivitiesWidgetLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        /// 锁屏状态通知栏视图（高度超过160会被系统截断）
        ActivityConfiguration(for: MusicPlayAttributes.self) { context in
            VStack {
                HStack {
                    if let image = context.attributes.compressImage() {
                        image.scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    Spacer()
                }.padding(.vertical, 10)
                    .padding(.leading, 10)
                HStack{
                    Text("\(context.state.currentProgress!)")
                    Text("\(context.attributes.totalDuration)")
                }
                .padding(.bottom, 10)
            }
            .activityBackgroundTint(Color.black.opacity(0.2))
            .activitySystemActionForegroundColor(Color.white)
        }
        /// 灵动岛视图
        dynamicIsland: { context in
            /// 扩展型灵动岛视图(左、右、中间、底部)
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Spacer()
                        if let image = context.attributes.compressImage() {
                            image.scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        Spacer()
                    }
                    .padding(.leading, 15)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Button(intent: ToggleFavoriteIntent(isFavorite: true)) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                    }.buttonStyle(.plain)
                    
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(context.attributes.songName)")
                                .font(.system(size: 20))
                                .foregroundStyle(.blue)
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        HStack {
                            Spacer()
                            Text("\(context.attributes.singer)")
                                .font(.system(size: 10))
                                .foregroundStyle(.blue)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    
                        HStack {
                            Button(intent: SkipSongIntent(direction: 1)) {
                                Image(systemName: "backward.fill")
                                    .font(.system(size: 20))
                            }.buttonStyle(.plain)
                            Spacer()
                            Button(intent: TogglePlaybackIntent(songName: context.attributes.songName)) {
                                Image(systemName: context.state.isPlaying ? "play.fill" : "pause.fill")
                                    .font(.system(size: 20))
                            }.buttonStyle(.plain)
                            Spacer()
                            Button(intent: SkipSongIntent(direction: -1)) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 20))
                            }.buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                }
            }
            /// 左侧紧凑灵动岛视图
            compactLeading: {
                if let image = context.attributes.compressImage() {
                    image.resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
            /// 右侧紧凑灵动岛视图
            compactTrailing: {
            }
            /// 最小型灵动岛视图
            minimal: {
                if let image = context.attributes.compressImage() {
                    image.resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.blue)
        }
    }
}
