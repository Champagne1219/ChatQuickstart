//
//  MobileRequest.swift
//  ChatQuickstart
//
//  Created by 谢强彬
//

import Foundation
import EaseChatUIKit
import KakaJSON

public class MobileError: Error, Convertible {
    var code: String?
    var message: String?
    
    required public init() { }
    
    // 实现协议方法来规定Model键映射规则
    public func kj_modelKey(from property: Property) -> any ModelPropertyKey {
        property.name
    }
}

public enum MobileBusinessApi {
    case login(Void)                               // 登陆
    case deregister(String)                        // 注销账号
    case verificationCode(String)                  // 发送验证码
    case refreshIMToken(Void)                      // 刷新 IM Token
    case autoDestroyGroup(String)                  // 自动解散群组
    case fetchGroupAvatar(String)                  // 获取群头像
    case fetchRTCToken(String,String)              // 获取 RTC Token
    case addFriendByPhoneNumber(String,String)     // 通过手机号添加好友
    case mirrorCallUserIdToChatUserId(String)      // 映射通话用户 ID
}

public class MobileBusinessRequest {
    public static let shared = MobileBusinessRequest()
    @Storage(key: "ChatUserToken", defaultValue: ChatClient.shared().accessUserToken ?? "") private var token
    @Storage(key: "ChatServerConfig", defaultValue: Dictionary<String, String>()) private var serverConfig
    
    /// 告知编译器允许调用者忽略方法的返回值而不产生警告
    // Swift网络请求封装
    @discardableResult
    public func sendRequest<T: Convertible>(method: MobileRequestHTTPMethod, uri: String, params: Dictionary<String, Any>, callBack: @escaping ((T?, Error?) -> Void)) -> URLSessionTask? {
        print(params)
        /// 指定客户端期望接收的数据格式、认证令牌、客户端发送请求体的数据格式
        let headers = ["Accept": "application/json", "Authorization": self.token, "Content-Type": "application/json"]
        let task = MobileRequest.shared.constructRequest(method: method, uri: uri, params: params, headers: headers) { data, response, error in
            DispatchQueue.main.async {
                /// 成功响应处理
                if error == nil, response?.statusCode ?? 0 == 200 {
                    /// 因为model会与UI控件绑定，所以模型解析也需要在主线程中完成，避免多线程访问冲突
                    callBack(model(from: data?.chat.toDictionary() ?? [:], type: T.self) as? T,error)
                } else {
                    /// 错误处理
                    if error == nil {
                        let errorMap = data?.chat.toDictionary() ?? [:]
                        let someError = MobileError()
                        someError.message = errorMap["errorInfo"] as? String
                        someError.code = "\((errorMap["code"] as? Int) ?? response!.statusCode)"
                        /// 401状态为身份验证失败，通过通知全局触发登陆跳转
                        if let code = errorMap["code"] as? String, code == "401" {
                            NotificationCenter.default.post(name: Notification.Name("BackLogin"), object: nil)
                        }
                        callBack(nil, someError)
                    } else {
                        callBack(nil, error)
                    }
                }
            }
        }
        return task
    }
    
    @discardableResult
    public func sendRequest(method: MobileRequestHTTPMethod, uri: String, params: Dictionary<String, Any>, callBack: @escaping ((Dictionary<String, Any>?, Error?) -> Void)) -> URLSessionTask? {
        let headers = ["Accept" : "application/json", "Authorization" : "Bearer" + self.token, "Content-Type" : "application/json"]
        let task = MobileRequest.shared.constructRequest(method: method, uri: uri, params: params, headers: headers) { data, response, error in
            if error == nil,response?.statusCode ?? 0 == 200 {
                callBack(data?.chat.toDictionary(),nil)
            } else {
                if error == nil {
                    let errorMap = data?.chat.toDictionary() ?? [:]
                    let someError = MobileError()
                    someError.message = errorMap["errorInfo"] as? String
                    someError.code = "\((errorMap["code"] as? Int) ?? response!.statusCode)"
                    if let code = errorMap["code"] as? String,code == "401" {
                        NotificationCenter.default.post(name: Notification.Name("BackLogin"), object: nil)
                    }
                    callBack(nil,someError)
                } else {
                    callBack(nil,error)
                }
            }
        }
        return task
    }
    
    @discardableResult
    public func sendPOSTRequest<U: Convertible> (uri: String, params: Dictionary<String, Any>, classType: U.Type, callBack: @escaping ((U?, Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .post, uri: uri, params: params, callBack: callBack)
    }
    
    @discardableResult
    func sendPOSTRequest(uri: String, params: Dictionary<String, Any>, callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .post, uri: uri, params: params, callBack: callBack)
    }
    
    @discardableResult
    func sendPOSTRequest(
        api: MobileBusinessApi,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .post, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// 根据指定api类型对URL路径进行构造封装
    func convertApi(api: MobileBusinessApi) -> String {
        var uri = "/inside/app"
        switch api {
        case .login(_):
            uri += "/user/login/V2"
        case .refreshIMToken(_):
            uri += "/user/token/refresh"
        case .deregister(let phoneNum):
            uri += "/user/\(phoneNum)"
        case .verificationCode(let phoneNum):
            uri += "/sms/send/"+phoneNum
        case .autoDestroyGroup(let groupId):
            var appKey = AppKey
            if let key = self.serverConfig["application"] {
                appKey = key
            }
            uri += "/group/\(groupId)?appkey=\(appKey.chat.urlEncoded)"
        case .fetchGroupAvatar(let groupId):
            uri += "/group/\(groupId)/avatarurl"
        case .fetchRTCToken(let channelId,let userId):
            uri = "/inside/token/rtc/channel/\(channelId)/user/\(userId)"
        case .addFriendByPhoneNumber(let phone, let userId):
            uri += "/user/\(phone)?operator=\(userId)"
        case .mirrorCallUserIdToChatUserId(let callUserId):
            uri = "/inside/agora/channel/mapper?channelName=\(callUserId)"
        }
        return uri
    }
}

public struct MobileRequestHTTPMethod: RawRepresentable, Equatable, Hashable {
    public static let connect = MobileRequestHTTPMethod(rawValue: "CONNECT")
    public static let delete = MobileRequestHTTPMethod(rawValue: "DELETE")
    public static let get = MobileRequestHTTPMethod(rawValue: "GET")
    public static let head = MobileRequestHTTPMethod(rawValue: "HEAD")
    public static let options = MobileRequestHTTPMethod(rawValue: "OPTIONS")
    public static let patch = MobileRequestHTTPMethod(rawValue: "PATCH")
    public static let post = MobileRequestHTTPMethod(rawValue: "POST")
    public static let put = MobileRequestHTTPMethod(rawValue: "PUT")
    public static let trace = MobileRequestHTTPMethod(rawValue: "TRACE")
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

@objc public class MobileRequest: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    public static var shared = MobileRequest()
    private var session: URLSession?
    private lazy var config: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type" : "application/json"]
        /// 设置服务器最大响应时间为10s，超时则抛出URLError.timeout
        config.timeoutIntervalForRequest = 10
        /// 强制忽略本地缓存，直接从源服务器请求最新数据
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return config
    }()
    
    override init() {
        super.init()
        self.session = URLSession(configuration: self.config, delegate: self, delegateQueue: .main)
    }
    
    @Storage(key: "ChatServerConfig", defaultValue:  Dictionary<String, String>()) private var serverConfig
    
    var host: String {
        /// 本地开发和服务器生产开发
        // 配置serverConfig地址为"https://192.168.0.101:300"
        if let restAddress = self.serverConfig["rest_server_address"], let enableDnsconfig = ChatUIKitClient.shared.option.option_chat.value(forKey: "enableDnsConfig") as? Bool, !enableDnsconfig {
            return restAddress
        } else {
            return ""
        }
    }
    
    /// 定义逃逸闭包用于执行异步回调（如果要进行UI更新需要手动切换至主线程）
    /// 回调闭包是异步编程的核心机制，所以要定义为逃逸闭包，用于在特定操作（网络请求、文件读写）完成后执行自定义逻辑
    // 构造网络请求并发送网络请求
    public func constructRequest(method: MobileRequestHTTPMethod, uri: String, params: Dictionary<String, Any>, headers: [String : String], callBack: @escaping ((Data?, HTTPURLResponse?, Error?) -> Void)) -> URLSessionTask? {
        guard let url = URL(string: self.host + uri) else { return nil }
        var urlRequest = URLRequest(url: url)
        if method == .put || method == .post {
            do {
                /// 请求参数字典格式转JSON格式
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
                print("request failed: \(error.localizedDescription)")
            }
        }
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        // Data（$0）、URLResponse($1)、Error($2)
        let task = self.session?.dataTask(with: urlRequest) {
            if $2 == nil {
                let response = ($1 as? HTTPURLResponse)
                callBack($0, response, $2)
                if response?.statusCode ?? 200 != 200 {
                    print("request failed")
                }
            } else {
                callBack(nil, nil, $2)
                print("request failed")
            }
        }
        task?.resume()
        return task
    }
}
