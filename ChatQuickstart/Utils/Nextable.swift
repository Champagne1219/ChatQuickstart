//
//  Nextable.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//

public protocol Nextable {
    func nextAction()
}

extension Nextable {
    /// 自动切换下一首歌曲播放
    func nextAction() {
        print("Nextable协议方法的默认实现")
    }
}
