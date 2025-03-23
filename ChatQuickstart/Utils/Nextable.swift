//
//  Nextable.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//

public protocol Nextable {
    /// 将更新监听对象的任务作为完成回调，避免异步操作导致数据不一致，从而丢失新的监听注册
    func nextAction(completion: @escaping () -> Void)
}

extension Nextable {
    /// 自动切换下一首歌曲播放
    func nextAction(completion: @escaping () -> Void) {
        print("Nextable协议方法的默认实现")
    }
}
