//
//  MusicPlayAttrbute.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//

// MARK: - 编译调试
/// 将视图控制器和扩展组件都希望调用，所以这个文件要同时要归属于主工程和组件工程，但是扩展文件的灵动岛数据模型必须定义的main入口，这样一来就会出现两个main入口，无法编译通过
/// 所以将这个文件从组件工程中剥离出来，并将它的Target Membership设置为主工程和组件工程，然后保持两个不同的工程main入口即可编译通过
/// info.plist需要设置Supported Live Activities

import Foundation
import ActivityKit
import SwiftUI

/// 灵动岛数据模型，需遵守ActivityAttributes协议
struct MusicPlayAttributes: ActivityAttributes {
    public typealias MusicPlayStatus = ContentState
    
    /// 动态数据，接收到推送时会更新的数据，自动根据json数据的key值进行解析并更新
    public struct ContentState : Codable, Hashable {
        var isFavorite: Bool?
        var currentProgress: String?
        var isPlaying: Bool
    }
    
    /// 静态数据，初始化后不再改变
    var songName: String
    var musicPosterStr: String
    var totalDuration: String
    var singer: String
    
    public func compressImage() -> Image? {
        if let originalImage = UIImage(named: self.musicPosterStr),
           let resizeImage = resizeImage(originalImage, targetSize: CGSize(width: 30, height: 30)),
           let compressData = compressImage(resizeImage),
           let compressImage = UIImage(data: compressData) {
            return Image(uiImage: compressImage)
        } else {
            return nil
        }
    }
    
    private func compressImage(_ image: UIImage, maxSizeKB: Int = 4) -> Data? {
        var compression: CGFloat = 1.0
        let maxCompression: CGFloat = 0.0
        let maxBytes = maxSizeKB * 1024
        
        var imageData: Data?
        
        repeat {
            imageData = image.jpegData(compressionQuality: compression)
            compression -= 0.1
        } while (imageData?.count ?? 0) > maxBytes && compression > maxCompression
        
        return imageData
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: targetSize)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        image.draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

// MARK: - 生命周期
/// Live Activity生命周期由ActivityKit管理：创建 -> 更新 -> 结束
/// 创建：activity = Activity.request(attributes: 静态数据, contentState: 动态数据)
/// 更新：activity.update(ActivityContent<自定义数据模型.ContentSate>(state: 动态数据, staleDate: nil))
/// 结束：activity.end(ActivityContent<自定义数据模型.ContentSate>(state: 动态数据, staleDate: nil), dimissalPolicy: 消失策略)
