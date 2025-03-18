//
//  DataManager.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//
import Foundation

// MARK: - 自定义泛型属性包装器，封装UserDefaults的本地持久化存储
@propertyWrapper
struct Storage<T> {
    private let key: String
    private let defaultValue: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

// MARK: - 创建本地持久化存储数据的单例对象，供全局调用
final public class DataManager {
    static let shared = DataManager()
    
    private init() { }
    
    // 用户外观模式
    @Storage(key: "ChatDarkMode", defaultValue: false)
    var darkMode: Bool
    
    // 用户语言偏好
    @Storage(key: "ChatPreferencesLanguage", defaultValue: "zh-Hans")
    var language: String
}

public let AppKey: String = "1114250213193379#demo"
