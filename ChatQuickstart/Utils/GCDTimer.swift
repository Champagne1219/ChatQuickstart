//
//  GCDTimer.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//

import Foundation

// MARK: - 自定义GCDTimer协议所需要定义的方法（启动、暂停、取消）
public protocol GCDTimer {
    func resume()
    func suspend()
    func cancel()
}
// MARK: - 静态工厂模式创建定时器任务
public class GCDTimerMaker {
    static func exec(_ task: (() -> Void)?, interval: Int, repeats: Bool = true, async: Bool = true) -> GCDTimer? {
        
        /// 防止创建没有必要的空任务定时器
        guard let _ = task else { return nil }
        return TimerMaker(task,
                          deadline: .now(),
                          repeating: repeats ? .seconds(interval) : .never,
                          async: async)
    }
}

private class TimerMaker: GCDTimer {
    
    /// 枚举 Timer 运行状态
    enum TimerState {
        case running
        case stopped
        case suspended
    }
    
    private var state: TimerState = .stopped
    private var timer: DispatchSourceTimer?
    /// 通过队列的严格访问序列化实现读写线程安全
    private let stateQueue = DispatchQueue(label: "com.timer.state.queue")
    
    /// 通过定义便利初始化方法来“扩展”已有的初始化方法
    convenience init(_ exec: (() -> Void)?, deadline: DispatchTime, repeating interval: DispatchTimeInterval = .never, leeway: DispatchTimeInterval = .seconds(0), async: Bool = true){
        self.init()
        
        let queue = async ? DispatchQueue.global() : DispatchQueue.main
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: deadline, repeating: interval, leeway: leeway)
        timer?.setEventHandler(handler: exec)
    }
    
    /// 启动定时器
    func resume() {
        stateQueue.sync {
            guard state != .running else { return }
            state = .running
            timer?.resume()
        }
    }
    
    /// 暂停定时器
    func suspend() {
        stateQueue.sync {
            guard state != .suspended else { return }
            state = .suspended
            timer?.suspend()
        }
    }
    
    /// 停止并释放定时器
    func cancel() {
        stateQueue.sync {
            guard let timer = timer, state != .stopped else { return }
            state = .stopped
            if timer.isCancelled { return }
            // GCD定时器释放的条件：调用cancel方法，事件处理闭包必须完成
            //     1. cancel只是在GCD内部进行状态标记，停止调度新事件，但并不会立即销毁对象
            //     2. 系统会等待已提交的任务完成，并且没有强引用时GCD才会真正释放底层资源
            //   self.timer = nil可以释放强引用，但是GCD队列仍然强持有底层定时器资源，必须要调用底层API（cancel方法）来彻底释放底层资源，否则依然会因为底层资源的未释放导致内存泄漏
            timer.cancel()
            timer.setEventHandler(handler: nil)
            self.timer = nil
        }
    }
    
    deinit {
        self.cancel()
    }
}
